import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, debugPrint, defaultTargetPlatform, kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show DeviceOrientation, SystemChrome;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
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

    // ML Kit 에 넘기는 회전 보정이 세로 기준이다. 가로로 돌리면 90도 어긋난
    // 프레임이 들어가 라벨이 엉킨다. 이 화면에서만 세로로 고정한다.
    unawaited(SystemChrome.setPreferredOrientations(
        const [DeviceOrientation.portraitUp]));

    _runCamera(_openCamera);
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    unawaited(SystemChrome.setPreferredOrientations(DeviceOrientation.values));

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
      _set(() => _cameraError =
          e is CameraException ? (e.description ?? '카메라를 열지 못했습니다.') : '카메라를 열지 못했습니다.');
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
      if (controller.value.isStreamingImages) {
        await controller.stopImageStream();
      }
      final shot = await controller.takePicture();
      if (!mounted || _disposed) return;
      await _start(shot);
    } on Object catch (e) {
      if (!mounted || _disposed) return;
      _runCamera(_resumeStream);
      _set(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e is CameraException
            ? (e.description ?? '촬영에 실패했습니다.')
            : '촬영에 실패했습니다.'),
      ));
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
    await _stopStream();
    // 분석만 한다. 기록은 결과 화면에서 사용자가 [기록에 저장하기] 를 눌러야 생긴다.
    // 여기서 돌아 나가면 서버에 아무것도 남지 않는다.
    unawaited(ref.read(plateNotifierProvider.notifier).analyze(image));

    // 결과 화면에서 뒤로 돌아왔을 때를 대비해 넘기기 전에 정리한다.
    // (로딩·결과 화면이 pushReplacement 를 쓰면 push 의 완료 future 가 오지 않는다)
    _window.clear();
    _set(() {
      _busy = false;
      _state = FoodDetectionState.checking;
      _lastObservation = FoodObservation.empty;
    });

    if (!mounted || _disposed) return;
    context.push(Routes.plateResult);
  }

  /// 결과 화면에서 돌아왔을 때 프리뷰를 되살린다.
  void _ensureStreaming() {
    if (_disposed || _busy || kIsWeb) return;
    if (ModalRoute.of(context)?.isCurrent == false) return;
    final controller = _controller;
    if (controller == null || controller.value.isStreamingImages) return;
    _runCamera(_resumeStream);
  }

  @override
  Widget build(BuildContext context) {
    _ensureStreaming();

    return Scaffold(
      appBar: AppBar(title: const Text('음식 촬영')),
      body: _controller == null ? _noPreview() : _preview(),
    );
  }

  /// 프리뷰가 없어도 촬영은 된다 — 이 게이트는 차단 장치가 아니다.
  Widget _noPreview() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _cameraError == null || _cameraError!.isEmpty
                ? '음식이 잘 보이도록 촬영해 주세요.'
                : _cameraError!,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: _busy ? null : () => _pick(PhotoPicker.fromCamera),
            icon: const Icon(Icons.camera_alt),
            label: const Text('촬영하기'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _busy ? null : () => _pick(PhotoPicker.fromGallery),
            icon: const Icon(Icons.photo_library),
            label: const Text('갤러리에서 선택'),
          ),
        ],
      ),
    );
  }

  Widget _preview() {
    return Column(
      children: [
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              CameraPreviewBox(_controller!),
              if (kDebugMode)
                Positioned(top: 8, left: 8, child: _DebugOverlay(_lastObservation)),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: _StateBanner(_state),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 상태와 무관하게 항상 누를 수 있다. 오탐 때문에 촬영을 막지 않는다.
              FilledButton.icon(
                onPressed: _busy ? null : _capture,
                icon: _busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.camera_alt),
                label: Text(_busy ? '처리 중…' : '촬영'),
              ),
              const SizedBox(height: 4),
              TextButton.icon(
                onPressed: _busy ? null : () => _pick(PhotoPicker.fromGallery),
                icon: const Icon(Icons.photo_library),
                label: const Text('갤러리에서 선택'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 상태를 색과 문장으로 보여준다. 촬영을 막지 않으므로 경고 톤은 약하게 둔다.
class _StateBanner extends StatelessWidget {
  const _StateBanner(this.state);

  final FoodDetectionState state;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (state) {
      FoodDetectionState.foodDetected => (Icons.check_circle, Colors.greenAccent),
      FoodDetectionState.notFood => (Icons.info_outline, Colors.orangeAccent),
      FoodDetectionState.checking => (Icons.search, Colors.white70),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                state.guide,
                style: TextStyle(color: color, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
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
