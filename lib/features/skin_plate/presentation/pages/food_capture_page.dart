import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, debugPrint, defaultTargetPlatform, kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/capture_shutter.dart';
import '../../../../core/camera/camera_error_message.dart';
import '../../../../core/utils/photo_picker.dart';
import '../../../../core/widgets/camera_preview_box.dart';
import '../../data/datasources/food_gate.dart';
import '../../domain/entities/food_detection.dart';
import '../../domain/food_gate_config.dart';
import '../../domain/food_gate_rules.dart';
import '../providers/plate_notifier.dart';

/// S06 — 음식 촬영.
///
/// 프리뷰에서 "음식으로 보이는가" 만 온디바이스로 본다. **음식 종류·구성요소·
/// 영양성분은 촬영 후 서버의 OpenAI Vision 이 정한다.**
///
/// 얼굴 게이트와 달리 **촬영을 막지 않는다.** 이건 차단 장치가 아니라 촬영
/// 가이드다. 오탐 하나로 멀쩡한 음식 사진을 못 찍게 되면, 게이트가 없을 때보다
/// 나쁜 제품이 된다.
///
/// skinAnalysisId 를 보내지 않는다. 서버가 그 사용자의 최신 피부 분석을 자동으로
/// 쓴다(PRD §14.3 ⑦).
class FoodCapturePage extends ConsumerStatefulWidget {
  const FoodCapturePage({super.key});

  @override
  ConsumerState<FoodCapturePage> createState() => _FoodCapturePageState();
}

class _FoodCapturePageState extends ConsumerState<FoodCapturePage>
    with WidgetsBindingObserver {
  CameraController? _controller;
  FoodGate? _gate;

  /// 카메라 열기/닫기를 직렬화한다. inactive → resumed 가 연달아 오면
  /// 이전 dispose 가 끝나기 전에 initialize 가 돌아 "camera in use" 가 난다.
  Future<void> _cameraLock = Future<void>.value();

  final _window = FoodDetectionWindow();
  FoodDetectionState _state = FoodDetectionState.checking;
  FoodObservation _lastObservation = FoodObservation.empty;

  bool _analyzing = false;
  DateTime _lastAnalyzed = DateTime.fromMillisecondsSinceEpoch(0);

  bool _busy = false;
  bool _disposed = false;

  /// 프리뷰를 못 여는 환경(웹·권한 거부·카메라 없음). 촬영 경로는 그대로 열려 있다.
  String? _cameraError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _runCamera(_openCamera);
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    // 라벨러를 먼저 닫으면 아직 날아오던 프레임이 닫힌 라벨러를 부른다.
    // 카메라를 먼저 다 닫고, 그 뒤에 닫는다.
    _runCamera(_closeCamera);
    _cameraLock = _cameraLock.whenComplete(() {
      _gate?.dispose();
      _gate = null;
    });
    super.dispose();
  }

  void _runCamera(Future<void> Function() op) {
    _cameraLock = _cameraLock.then((_) => op()).catchError((_) {});
  }

  /// 같은 줄에 세우되 **결과를 기다린다.**
  ///
  /// 촬영과 스트림 재개가 겹치면 CameraX 가 ImageAnalysis 를 두 번 바인딩하고
  /// "No supported surface combination" 로 화면을 덮는다. 얼굴 촬영에서 실제로
  /// 터진 결함이라 같은 방식으로 막는다 — `isStreamingImages` 는 네이티브
  /// 바인딩보다 먼저 바뀌어서 그 사이를 못 막는다.
  ///
  /// 실패해도 락은 이어져야 한다. 깨진 채로 두면 이후 카메라 작업이 전부 막힌다.
  Future<void> _lockCamera(Future<void> Function() op) {
    final running = _cameraLock.then((_) => op());
    _cameraLock = running.catchError((_) {});
    return running;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _runCamera(_closeCamera);
    } else if (state == AppLifecycleState.resumed) {
      _runCamera(() async {
        if (_controller == null) await _openCamera();
      });
    }
  }

  void _set(VoidCallback fn) {
    if (!mounted || _disposed) return;
    setState(fn);
  }

  Future<void> _openCamera() async {
    if (kIsWeb) {
      // 웹에는 ML Kit 이 없다. 안내만 접고 촬영 경로는 그대로 둔다.
      _set(() => _cameraError = '');
      return;
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _set(() => _cameraError = '사용할 수 있는 카메라가 없습니다.');
        return;
      }

      // 음식은 후면 카메라로 찍는다. 전면 전환 기능은 이 화면에 없다.
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      _gate?.dispose();
      _gate = foodGate(back);

      // 포맷을 여기서 고정한다. 양쪽을 yuv420 으로 통일하면 iOS 에서 ML Kit 이
      // 프레임을 못 읽는다.
      final controller = CameraController(
        back,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: defaultTargetPlatform == TargetPlatform.android
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );

      await controller.initialize();
      if (!mounted || _disposed) {
        await controller.dispose();
        return;
      }

      // _set 은 dispose 된 뒤라면 클로저를 통째로 버린다. 그 사이 이 화면이
      // 사라지면 _controller 가 null 로 남고, dispose 가 걸어둔 _closeCamera 는
      // null 을 보고 그냥 돌아가 카메라가 영영 안 닫힌다. 먼저 대입해 둔다.
      _controller = controller;
      await controller.startImageStream(_onFrame);
      _set(() {
        _cameraError = null;
      });
    } on Object catch (e) {
      // 권한 거부·플랫폼 예외에서도 화면이 죽지 않아야 한다.
      _set(() => _cameraError = cameraErrorMessage(e, '카메라를 열지 못했습니다.'));
    }
  }

  Future<void> _closeCamera() async {
    final controller = _controller;
    if (controller == null) return;
    _set(() => _controller = null);
    _controller = null;

    try {
      if (controller.value.isStreamingImages) {
        await controller.stopImageStream();
      }
    } on Object catch (_) {
      // 이미 끊긴 스트림이면 그만이다.
    }
    await controller.dispose();
  }

  /// 30fps 를 전부 넘기면 프리뷰가 끊기고 배터리만 먹는다.
  /// 간격을 두고, 앞 프레임 분석이 안 끝났으면 그냥 버린다.
  void _onFrame(CameraImage frame) {
    final gate = _gate;
    if (gate == null || _analyzing || _busy || _disposed) return;

    final now = DateTime.now();
    if (now.difference(_lastAnalyzed) < FoodGateConfig.analysisInterval) return;

    _analyzing = true;
    _lastAnalyzed = now;

    unawaited(gate.observe(frame).then((observation) {
      _window.add(observation.confidence);
      final next = _window.state;

      if (kDebugMode && next != _state) {
        // 상태가 바뀔 때만 찍는다. 프레임마다 찍으면 로그가 쓸모없어진다.
        debugPrint('[FoodDetection] label=${observation.topLabel ?? '-'} '
            'confidence=${observation.confidence?.toStringAsFixed(2) ?? '-'} '
            'state=${next.name}');
      }

      _set(() {
        _state = next;
        _lastObservation = observation;
      });
      // ML Kit 초기화·분석 실패는 이 프레임을 버리고 넘어간다. 상태는 그대로다.
    }).catchError((_) {}).whenComplete(() => _analyzing = false));
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (_busy) return;

    // 프리뷰가 없으면(웹·권한 거부) 기존 image_picker 경로로 찍는다.
    if (controller == null) {
      await _pick(PhotoPicker.fromCamera);
      return;
    }

    _set(() => _busy = true);
    try {
      late final XFile shot;
      await _lockCamera(() async {
        if (controller.value.isStreamingImages) {
          await controller.stopImageStream();
        }
        shot = await controller.takePicture();
      });
      if (!mounted || _disposed) return;
      await _start(shot);
    } on Object catch (e) {
      if (!mounted || _disposed) return;
      _runCamera(_resumeStream);
      _set(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(cameraErrorMessage(e, '촬영에 실패했습니다.'))),
      );
    }
  }

  Future<void> _pick(Future<XFile?> Function() pick) async {
    if (_busy) return;
    _set(() => _busy = true);
    try {
      final image = await pick();
      if (!mounted || _disposed) return;
      if (image == null) {
        _set(() => _busy = false);
        return;
      }
      await _start(image);
    } on Object catch (_) {
      _set(() => _busy = false);
    }
  }

  Future<void> _resumeStream() async {
    final controller = _controller;
    if (controller == null || _disposed) return;
    try {
      if (!controller.value.isStreamingImages) {
        await controller.startImageStream(_onFrame);
      }
    } on Object catch (_) {}
  }

  Future<void> _stopStream() async {
    final controller = _controller;
    if (controller == null) return;
    try {
      if (controller.value.isStreamingImages) {
        await controller.stopImageStream();
      }
    } on Object catch (_) {}
  }

  /// 기존 업로드 경로. 게이트가 붙어도 여기부터는 하나도 바뀌지 않는다.
  Future<void> _start(XFile image) async {
    // 갤러리로 들어온 경로는 스트림이 아직 돌고 있다. 안 멈추면 결과 화면에
    // 머무는 내내 150ms 마다 ML Kit 이 돌고, 돌아왔을 때 천장을 보고 계산한
    // notFood 가 배너에 남는다.
    await _lockCamera(_stopStream);
    // 분석만 한다. 기록은 결과 화면에서 사용자가 [기록에 저장하기] 를 눌러야 생긴다.
    // 여기서 돌아 나가면 서버에 아무것도 남지 않는다.
    unawaited(ref.read(plateNotifierProvider.notifier).analyze(image));

    _window.clear();
    _set(() {
      _busy = false;
      _state = FoodDetectionState.checking;
      _lastObservation = FoodObservation.empty;
    });

    if (!mounted || _disposed) return;
    // push 가 아니라 교체다. 찍고 나면 이 화면의 일은 끝났고, 결과에서 뒤로 가는
    // 사용자는 "촬영 이전 화면"으로 나가려는 것이지 카메라를 다시 보려는 게 아니다.
    // push 로 두면 결과 아래에 카메라가 살아 있다가 뒤로가기에 되살아난다.
    //
    // 다시 찍는 길은 결과 화면의 [다시 촬영] 하나로 모은다 — 명시적으로 고를 때만
    // 카메라가 뜬다.
    context.pushReplacement(Routes.plateResult);
  }

  /// 결과 화면에서 돌아왔을 때 프리뷰를 되살린다.
  void _ensureStreaming() {
    if (_disposed || _busy || kIsWeb) return;
    if (ModalRoute.of(context)?.isCurrent == false) return;
    final controller = _controller;
    if (controller == null || controller.value.isStreamingImages) return;
    _runCamera(_resumeStream);
  }

  /// 시안의 0.5x / 1x / 2x. 기기가 지원하는 범위로 잘라서 적용한다.
  double _zoom = 1.0;

  Future<void> _setZoom(double factor) async {
    final controller = _controller;
    if (controller == null) return;
    try {
      final min = await controller.getMinZoomLevel();
      final max = await controller.getMaxZoomLevel();
      final clamped = factor.clamp(min, max);
      await controller.setZoomLevel(clamped);
      _set(() => _zoom = factor);
    } on Object catch (_) {
      // 줌이 안 되는 기기면 그냥 둔다. 촬영이 먼저다.
    }
  }

  @override
  Widget build(BuildContext context) {
    _ensureStreaming();

    // 시안은 상태바까지 검은 전체 화면 카메라다. AppBar 대신 뒤로가기만 띄운다.
    return Scaffold(
      backgroundColor: Colors.black,
      body: _controller == null ? _noPreview() : _preview(),
    );
  }

  /// 프리뷰가 없어도 촬영은 된다 — 이 게이트는 차단 장치가 아니다.
  Widget _noPreview() {
    return SafeArea(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _cameraError == null || _cameraError!.isEmpty
                      ? '음식이 잘 보이도록 촬영해 주세요'
                      : _cameraError!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 32),
                Center(
                  child: CaptureShutter(enabled: !_busy, busy: _busy, onTap: () => _pick(PhotoPicker.fromCamera)),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: _busy ? null : () => _pick(PhotoPicker.fromGallery),
                  icon: const Icon(Icons.photo_library, color: Colors.white70),
                  label: const Text('갤러리에서 선택',
                      style: TextStyle(color: Colors.white70)),
                ),
              ],
            ),
          ),
          _BackButton(onTap: () => context.pop()),
        ],
      ),
    );
  }

  Widget _preview() {
    return Stack(
      fit: StackFit.expand,
      children: [
        CameraPreviewBox(_controller!),

        // 시안의 코너 브래킷 프레임. 촬영 영역을 안내만 하고 자르지는 않는다.
        // 게이트가 음식을 잡으면 초록으로 바뀐다 — 문구만으로는 프레임 안을 보고
        // 있는 사용자의 눈에 안 들어온다.
        Center(
          child: _BracketFrame(
              detected: _state == FoodDetectionState.foodDetected),
        ),

        if (kDebugMode)
          Positioned(top: 48, left: 8, child: _DebugOverlay(_lastObservation)),

        SafeArea(
          child: Stack(
            children: [
              _BackButton(onTap: () => context.pop()),

              // 안내 문구. 게이트 상태에 따라 문장이 바뀌지만 촬영은 항상 열려 있다.
              //
              // 예전에는 notFood 만 상태 문구를 쓰고 나머지는 고정 문구였다. 그래서
              // 음식을 잡은 순간에도 "잘 보이도록 촬영해 주세요"가 그대로 남아,
              // AI 가 알아봤는지 사용자가 알 수 없었다 — 셔터를 누를 확신이 안 선다.
              Align(
                alignment: const Alignment(0, -0.1),
                child: Padding(
                  padding: const EdgeInsets.only(top: 120),
                  child: _GuideBanner(state: _state),
                ),
              ),

              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ZoomChips(current: _zoom, onSelect: _setZoom),
                      const SizedBox(height: 26),
                      CaptureShutter(enabled: !_busy, busy: _busy, onTap: _capture),
                      const SizedBox(height: 14),
                      const Text(
                        '분석은 AI가 자동으로 진행해요!',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 전체 화면 카메라 위의 뒤로가기. AppBar 를 두면 시안의 몰입 프레임이 깨진다.
class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 8,
      left: 8,
      child: IconButton(
        onPressed: onTap,
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
      ),
    );
  }
}

/// 시안의 촬영 영역 브래킷 — 308px 사각의 네 모서리에 44px L 자.
/// 게이트가 음식을 잡았다는 것을 문구와 색 둘로 알린다.
///
/// 문구만 바꾸면 프레임 안을 들여다보는 사용자는 못 읽는다. 반대로 색만 바꾸면
/// 무슨 뜻인지 배워야 한다. 둘을 같이 바꾸면 어느 쪽을 보고 있든 전달된다.
class _GuideBanner extends StatelessWidget {
  const _GuideBanner({required this.state});

  final FoodDetectionState state;

  @override
  Widget build(BuildContext context) {
    final detected = state == FoodDetectionState.foodDetected;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: detected ? AppColors.good : Colors.transparent,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (detected) ...[
            const Icon(Icons.check_circle, size: 16, color: Colors.white),
            const SizedBox(width: 6),
          ],
          Text(
            state.guide,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _BracketFrame extends StatelessWidget {
  const _BracketFrame({required this.detected});

  final bool detected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 308,
      height: 308,
      child: CustomPaint(painter: _BracketPainter(detected: detected)),
    );
  }
}

class _BracketPainter extends CustomPainter {
  const _BracketPainter({required this.detected});

  final bool detected;

  static const _arm = 44.0;
  static const _stroke = 5.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = detected ? AppColors.good : Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    // 좌상 → 시계 방향. 각 모서리에서 가로·세로 한 획씩.
    canvas.drawPath(
        Path()
          ..moveTo(0, _arm)
          ..lineTo(0, 0)
          ..lineTo(_arm, 0),
        paint);
    canvas.drawPath(
        Path()
          ..moveTo(w - _arm, 0)
          ..lineTo(w, 0)
          ..lineTo(w, _arm),
        paint);
    canvas.drawPath(
        Path()
          ..moveTo(w, h - _arm)
          ..lineTo(w, h)
          ..lineTo(w - _arm, h),
        paint);
    canvas.drawPath(
        Path()
          ..moveTo(_arm, h)
          ..lineTo(0, h)
          ..lineTo(0, h - _arm),
        paint);
  }

  @override
  bool shouldRepaint(_BracketPainter oldDelegate) =>
      oldDelegate.detected != detected;
}


/// 0.5x / 1x / 2x. 현재 배율만 크고 밝게 — 시안 그대로다.
class _ZoomChips extends StatelessWidget {
  const _ZoomChips({required this.current, required this.onSelect});

  final double current;
  final ValueChanged<double> onSelect;

  @override
  Widget build(BuildContext context) {
    const factors = [0.5, 1.0, 2.0];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final factor in factors)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9),
            child: GestureDetector(
              onTap: () => onSelect(factor),
              child: Container(
                width: factor == current ? 45 : 32,
                height: factor == current ? 45 : 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.45),
                ),
                child: Center(
                  child: Text(
                    factor == 1.0 || factor == 2.0
                        ? '${factor.toInt()}x'
                        : '${factor}x',
                    style: TextStyle(
                      color: factor == current ? Colors.white : Colors.white70,
                      fontSize: factor == current ? 15 : 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// 라벨 후보 집합을 실기기에서 다듬을 때 쓴다. 릴리즈 빌드에는 나오지 않는다.
class _DebugOverlay extends StatelessWidget {
  const _DebugOverlay(this.observation);

  final FoodObservation observation;

  @override
  Widget build(BuildContext context) {
    final labels = observation.allLabels.take(5).join('\n');

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Text(
          'food=${observation.topLabel ?? '-'} '
          '${observation.confidence?.toStringAsFixed(2) ?? ''}\n'
          '${labels.isEmpty ? '(라벨 없음)' : labels}',
          style: const TextStyle(
              color: Colors.greenAccent, fontSize: 11, fontFamily: 'monospace'),
        ),
      ),
    );
  }
}
