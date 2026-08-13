import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/utils/photo_picker.dart';
import '../../data/datasources/face_gate.dart';
import '../../domain/entities/face_gate_result.dart';
import '../../domain/entities/skin_photo_set.dart';
import '../../domain/face_gate_config.dart';
import '../providers/skin_analysis_notifier.dart';

/// 정지 이미지 게이트만 쓸 때의 자리표시자.
///
/// [FaceGate.prepareSkinPhoto] 는 CameraDescription 을 보지 않는다(파일에서 다시
/// 검출한다). 카메라 목록을 못 얻는 기기에서도 갤러리 경로는 살아 있어야 하므로,
/// 게이트 생성을 카메라 열거 성공 여부에 묶지 않는다.
const _stillOnlyCamera = CameraDescription(
  name: 'still-only',
  lensDirection: CameraLensDirection.front,
  sensorOrientation: 0,
);

/// S03 — 피부 촬영.
///
/// **촬영은 3단계다.** 정면 → 왼쪽 → 오른쪽 순으로 각 단계에서 해당 방향의 게이트를
/// 통과해야 다음으로 넘어가고, 세 장이 다 모인 뒤에야 서버를 한 번 호출한다(PRD §9.5).
/// 단계마다 분석 API 를 부르면 결과가 세 개 나오고, 그중 무엇이 "오늘의 점수"인지
/// 정할 방법이 없다.
///
/// **우회 경로는 없다.** 촬영이든 갤러리든 게이트를 통과하지 못하면 업로드하지
/// 않는다. 게이트를 걸 수 없는 환경(웹·포맷 미지원)도 통과가 아니라 차단이다.
class SkinCapturePage extends ConsumerStatefulWidget {
  const SkinCapturePage({super.key});

  @override
  ConsumerState<SkinCapturePage> createState() => _SkinCapturePageState();
}

class _SkinCapturePageState extends ConsumerState<SkinCapturePage>
    with WidgetsBindingObserver {
  static const _stages = [
    FacePhotoType.front,
    FacePhotoType.left,
    FacePhotoType.right,
  ];

  CameraController? _controller;

  /// 프리뷰가 안 열려도 정지 이미지 게이트에는 쓸 수 있어서 따로 들고 있는다.
  FaceGate? _gate;

  /// 카메라 열기/닫기를 직렬화한다. inactive → resumed 가 연달아 오면
  /// 이전 dispose 가 끝나기 전에 initialize 가 돌아 "camera in use" 가 난다.
  Future<void> _cameraLock = Future<void>.value();

  int _stageIndex = 0;
  final Map<FacePhotoType, XFile> _shots = {};

  FaceGateResult? _result;

  /// 연속 통과 프레임 수. 자동 촬영은 이 값이 임계치에 닿을 때만 눌린다.
  int _okStreak = 0;

  bool _analyzing = false;
  DateTime _lastAnalyzed = DateTime.fromMillisecondsSinceEpoch(0);

  bool _busy = false;
  bool _disposed = false;

  /// 게이트에 막혀 업로드하지 못했을 때 화면에 남기는 문구.
  String? _blockedGuide;

  /// 카메라를 못 여는 환경(웹·권한 거부·카메라 없음).
  String? _cameraError;

  FacePhotoType get _stage => _stages[_stageIndex];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // 카메라 열거가 실패해도 갤러리 경로는 살아 있어야 한다.
    if (!kIsWeb) _gate = faceGate(_stillOnlyCamera);
    _runCamera(_openCamera);
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    // 검출기를 먼저 닫으면 아직 날아오던 프레임이 닫힌 검출기를 부른다.
    // 카메라를 다 닫은 뒤에 닫는다.
    _cameraLock = _cameraLock.whenComplete(() {
      _gate?.dispose();
      _gate = null;
    });
    _runCamera(_closeCamera);
    super.dispose();
  }

  /// 카메라 작업을 하나씩 줄 세운다.
  void _runCamera(Future<void> Function() op) {
    _cameraLock = _cameraLock.then((_) => op()).catchError((_) {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 백그라운드에서 카메라를 붙들고 있으면 다른 앱이 카메라를 못 열고,
    // 돌아왔을 때 프리뷰가 검은 화면으로 남는다.
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
      // 웹에는 ML Kit 이 없다. 게이트를 걸 수 없으므로 촬영 경로를 열지 않는다.
      _set(() => _cameraError = '이 브라우저에서는 피부 촬영을 지원하지 않습니다.\n앱에서 진행해 주세요.');
      return;
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _set(() => _cameraError = '사용할 수 있는 카메라가 없습니다.');
        return;
      }

      final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      // 실제 카메라를 알게 됐으니 센서 방향을 아는 게이트로 바꿔 단다.
      _gate?.dispose();
      _gate = faceGate(front);

      // 포맷을 여기서 고정한다. 양쪽을 yuv420 으로 통일하면 밝기 계산은 편해지지만
      // iOS 에서 ML Kit 이 프레임을 못 읽어 검출이 0개가 된다. (설계서 §2.12.2)
      final controller = CameraController(
        front,
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

      await controller.startImageStream(_onFrame);
      _set(() {
        _controller = controller;
        _cameraError = null;
      });
    } on Object catch (e) {
      // CameraException 만 잡으면 권한 거부·플랫폼 예외에서 화면이 빈 채로 멈춘다.
      _set(() => _cameraError = _messageOf(e, '카메라를 열지 못했습니다.'));
    }
  }

  Future<void> _closeCamera() async {
    final controller = _controller;
    if (controller == null) return;
    // 프리뷰가 사라졌다는 걸 화면에 알려야 한다. 안 그러면 폐기된 컨트롤러를
    // 들고 있는 CameraPreview 가 다음 리페인트에서 "used after being disposed" 로 죽는다.
    _set(() => _controller = null);
    _controller = null;

    try {
      if (controller.value.isStreamingImages) {
        await controller.stopImageStream();
      }
    } on Object catch (_) {
      // 이미 끊긴 스트림을 멈추려다 나는 예외는 무시한다.
    }
    await controller.dispose();
  }

  /// 프레임마다 ML Kit 을 호출하면 프리뷰가 눈에 띄게 끊긴다.
  /// 간격을 두고, 앞 프레임 분석이 안 끝났으면 그냥 버린다.
  void _onFrame(CameraImage frame) {
    final gate = _gate;
    if (gate == null || _analyzing || _busy || _disposed) return;

    final now = DateTime.now();
    if (now.difference(_lastAnalyzed) < FaceGateConfig.analysisInterval) return;

    _analyzing = true;
    _lastAnalyzed = now;

    unawaited(gate
        .check(frame, _stage)
        .then((result) {
          _set(() {
            _result = result;
            _okStreak = result is FaceGateOk ? _okStreak + 1 : 0;
          });
          // 조건이 잠깐 맞은 게 아니라 유지되고 있을 때만 셔터를 누른다.
          if (_okStreak >= FaceGateConfig.autoCaptureStableFrames && !_busy) {
            unawaited(_capture());
          }
        })
        // 버퍼·메타데이터가 어긋나면 processImage 가 던진다. 300ms 마다 반복되므로
        // 잡지 않으면 미처리 비동기 예외가 계속 쌓인다.
        .catchError((_) {})
        .whenComplete(() => _analyzing = false));
  }

  Future<void> _capture() async {
    final controller = _controller;
    final gate = _gate;
    if (controller == null || gate == null || _busy) return;

    _set(() {
      _busy = true;
      _blockedGuide = null;
    });

    try {
      if (controller.value.isStreamingImages) {
        await controller.stopImageStream();
      }
      final shot = await controller.takePicture();

      // 프리뷰의 faceRect 를 크롭에 쓰지 않는다. 사진에서 한 번 더 검출한다.
      final prepared = await gate.prepareSkinPhoto(shot, photoType: _stage);
      if (!mounted || _disposed) return;

      if (prepared.file == null) {
        // 통과하지 못한 이미지는 올리지 않는다. 프리뷰로 돌아가 다시 잡게 한다.
        await _recover(_guideOf(prepared.gate));
        return;
      }

      await _accept(prepared.file!);
    } on Object catch (e) {
      // takePicture · ML Kit · 파일 IO · 이미지 디코딩 어디서든 던질 수 있다.
      // 하나라도 새어 나가면 _busy 가 선 채로 화면이 죽는다.
      await _recover(_messageOf(e, '촬영에 실패했습니다.'));
    }
  }

  /// 갤러리도 게이트를 지난다. 실시간 검사를 거치지 않은 경로라 4개 조건을 전부 본다.
  Future<void> _pickFromGallery() async {
    final gate = _gate;
    if (_busy) return;
    if (gate == null) {
      _set(() => _blockedGuide = '이 기기에서는 얼굴 검사를 할 수 없어 업로드할 수 없습니다.');
      return;
    }

    try {
      final picked = await PhotoPicker.fromGallery();
      if (picked == null || !mounted || _disposed) return;

      _set(() {
        _busy = true;
        _blockedGuide = null;
      });

      final prepared =
          await gate.prepareSkinPhoto(picked, photoType: _stage, fullGate: true);
      if (!mounted || _disposed) return;

      if (prepared.file == null) {
        await _recover(_guideOf(prepared.gate));
        return;
      }

      await _accept(prepared.file!);
    } on Object catch (e) {
      await _recover(_messageOf(e, '사진을 불러오지 못했습니다.'));
    }
  }

  /// 한 단계를 통과했다. 세 장이 다 모였으면 업로드하고, 아니면 다음 방향으로 넘어간다.
  Future<void> _accept(XFile file) async {
    _shots[_stage] = file;

    final photos = SkinPhotoSet.tryFrom(_shots);
    if (photos == null) {
      await _resumeStream();
      _set(() {
        _busy = false;
        _stageIndex++;
        _result = null; // 방향이 바뀌었으니 이전 판정은 버린다
        _blockedGuide = null; // 이전 단계의 실패 안내도 같이 버린다
        _okStreak = 0;
      });
      return;
    }

    await _start(photos);
  }

  /// 업로드하지 못했을 때 화면을 되살린다. 이걸 빠뜨리면 _busy 가 선 채로
  /// 촬영·갤러리 버튼이 영구 비활성이 되고 프리뷰도 멈춘 채로 남는다.
  Future<void> _recover(String guide) async {
    await _resumeStream();
    _set(() {
      _busy = false;
      _blockedGuide = guide;
      // 막힌 직후 남은 연속 카운트로 곧바로 다시 찍히면 같은 실패가 반복된다.
      _okStreak = 0;
    });
  }

  Future<void> _resumeStream() async {
    final controller = _controller;
    if (controller == null || _disposed) return;
    try {
      if (!controller.value.isStreamingImages) {
        await controller.startImageStream(_onFrame);
      }
    } on Object catch (_) {
      // 되살리지 못해도 갤러리 경로는 열려 있다.
    }
  }

  /// 기존 업로드 경로. 세 장을 한 요청으로 보낸다.
  Future<void> _start(SkinPhotoSet photos) async {
    // 기다리지 않고 넘어간다. analyze 는 첫 줄에서 로딩 상태를 세우므로
    // 다음 화면이 곧바로 로딩을 보여준다.
    unawaited(ref.read(skinAnalysisNotifierProvider.notifier).analyze(photos));

    // push 라 이 화면은 살아 있다. 로딩 화면에서 "다시 촬영" 으로 돌아오면
    // 처음(정면)부터 다시 찍게 한다 — 세 장이 한 벌이라 일부만 새로 찍을 수 없다.
    await context.push(Routes.skinLoading);
    if (!mounted || _disposed) return;

    await _resumeStream();
    _set(() {
      _busy = false;
      _blockedGuide = null;
      _result = null;
      _stageIndex = 0;
      _okStreak = 0;
      _shots.clear();
    });
  }

  String _guideOf(FaceGateResult gate) => switch (gate) {
        FaceGateBlocked(:final guide) => guide,
        _ => _unavailableGuide,
      };

  static const _unavailableGuide =
      '이 기기에서는 얼굴 검사를 할 수 없어 촬영할 수 없습니다.\n갤러리에서 선택해 주세요.';

  static String _messageOf(Object error, String fallback) =>
      error is CameraException ? (error.description ?? fallback) : fallback;

  static String _label(FacePhotoType type) => switch (type) {
        FacePhotoType.front => '정면',
        FacePhotoType.left => '왼쪽 얼굴',
        FacePhotoType.right => '오른쪽 얼굴',
      };

  static String _instruction(FacePhotoType type) => switch (type) {
        FacePhotoType.front => '정면을 바라봐 주세요',
        FacePhotoType.left => '고개를 왼쪽으로 돌려주세요',
        FacePhotoType.right => '고개를 오른쪽으로 돌려주세요',
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('피부 촬영  ${_stageIndex + 1}/${_stages.length}'),
      ),
      body: _controller == null ? _noPreview() : _preview(),
    );
  }

  /// 프리뷰를 못 여는 환경. 갤러리 경로는 게이트를 통과하면 열려 있다.
  Widget _noPreview() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _cameraError ?? '카메라를 준비하고 있습니다…',
            textAlign: TextAlign.center,
          ),
          if (_blockedGuide != null) ...[
            const SizedBox(height: 16),
            Text(_blockedGuide!, textAlign: TextAlign.center),
          ],
          if (_gate != null) ...[
            const SizedBox(height: 32),
            Text('${_label(_stage)} 사진을 선택해 주세요',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _busy ? null : _pickFromGallery,
              icon: const Icon(Icons.photo_library),
              label: const Text('갤러리에서 선택'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _preview() {
    final result = _result;
    final canCapture = result?.canCapture ?? false;

    // 지금 프레임의 판정이 항상 우선이다. 이 순서를 뒤집으면 이전 촬영 시도에서
    // 세운 문구가 남아, 체크리스트는 "방향" 이 틀렸다는데 안내는 "한 명의 얼굴만"
    // 이라고 말하는 화면이 된다.
    //
    // _blockedGuide 는 라이브 게이트가 통과인데 촬영만 실패한 경우를 설명한다.
    // 게이트를 걸 수 없는 프레임은 안내가 없으면 이유 없이 버튼만 꺼진 화면이 된다.
    final guide = switch (result) {
      FaceGateBlocked(:final guide) => guide,
      FaceGateUnavailable() => _unavailableGuide,
      _ => _blockedGuide,
    };

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: _StepIndicator(
            current: _stageIndex,
            labels: [for (final s in _stages) _label(s)],
          ),
        ),
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              CameraPreview(_controller!),
              // 어디에 얼굴을 두어야 하는지 형태로 보여준다. 문장만으로는
              // "조금 더 가까이" 가 얼마나 가까이인지 알 수 없다.
              _FaceGuide(passing: canCapture),
              if (kDebugMode && result?.debug != null)
                Positioned(top: 8, left: 8, child: _DebugOverlay(result!)),
              Positioned(
                top: 8,
                right: 8,
                child: _StageBadge(
                  label: _label(_stage),
                  instruction: _instruction(_stage),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: _Checklist(result),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (guide != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    guide,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              FilledButton.icon(
                onPressed: (canCapture && !_busy) ? _capture : null,
                icon: _busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.camera_alt),
                label: Text(_busy
                    ? '처리 중…'
                    : canCapture
                        // 조건이 맞으면 곧 자동으로 찍힌다. 버튼은 기다리기 싫은
                        // 사용자를 위한 수동 경로다.
                        ? '곧 자동으로 촬영됩니다 · 탭하면 바로 촬영'
                        : '조건을 맞추면 자동으로 촬영됩니다'),
              ),
              const SizedBox(height: 4),
              TextButton.icon(
                onPressed: _busy ? null : _pickFromGallery,
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

/// 지금 어느 방향을 찍어야 하는지. 3단계라 이게 없으면 사용자가 길을 잃는다.
class _StageBadge extends StatelessWidget {
  const _StageBadge({required this.label, required this.instruction});

  final String label;
  final String instruction;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600)),
            Text(instruction,
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

/// 조건 4개를 순서대로 보여준다. 판정이 첫 실패에서 멈추므로, 실패한 조건까지만
/// 확정으로 표시하고 그 뒤는 아직 모르는 상태로 남긴다.
class _Checklist extends StatelessWidget {
  const _Checklist(this.result);

  final FaceGateResult? result;

  static const _labels = ['얼굴 1명', '충분한 크기', '방향', '밝기 적절'];

  static int _failedAt(FaceGateReason reason) => switch (reason) {
        FaceGateReason.noFace || FaceGateReason.multipleFaces => 0,
        FaceGateReason.tooSmall => 1,
        FaceGateReason.wrongOrientation => 2,
        FaceGateReason.tooDark => 3,
      };

  @override
  Widget build(BuildContext context) {
    final current = result;
    if (current is FaceGateUnavailable || current == null) {
      return const SizedBox.shrink();
    }

    final failedAt = current is FaceGateBlocked ? _failedAt(current.reason) : null;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < _labels.length; i++)
              _row(
                _labels[i],
                failedAt == null
                    ? true
                    : (i < failedAt ? true : (i == failedAt ? false : null)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, bool? passed) {
    final (icon, color) = switch (passed) {
      true => (Icons.check, Colors.greenAccent),
      false => (Icons.close, Colors.redAccent),
      null => (Icons.remove, Colors.white38),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontSize: 13)),
        ],
      ),
    );
  }
}

/// 실기기에서 yaw 부호와 임계값을 맞출 때 쓴다. 릴리즈 빌드에는 나오지 않는다.
class _DebugOverlay extends StatelessWidget {
  const _DebugOverlay(this.result);

  final FaceGateResult result;

  @override
  Widget build(BuildContext context) {
    final debug = result.debug!;
    final verdict = switch (result) {
      FaceGateOk() => 'VALID',
      FaceGateBlocked(:final reason) => reason.name,
      FaceGateUnavailable() => 'UNAVAILABLE',
    };

    String num(double? v) => v == null ? '-' : v.toStringAsFixed(1);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Text(
          'Face: ${debug.faceCount}\n'
          'Yaw: ${num(debug.yaw)}  Pitch: ${num(debug.pitch)}  Roll: ${num(debug.roll)}\n'
          'Ratio: ${num(debug.faceHeightRatio == null ? null : debug.faceHeightRatio! * 100)}%\n'
          'Luma: ${debug.luminance ?? '-'}\n'
          '$verdict',
          style: const TextStyle(
              color: Colors.greenAccent, fontSize: 11, fontFamily: 'monospace'),
        ),
      ),
    );
  }
}

/// 얼굴을 어디에 두어야 하는지 보여주는 타원 가이드.
///
/// 통과 여부를 **색으로** 바꾼다 — 문장을 읽지 않아도 초록이면 된 것이고,
/// 그 상태를 유지하면 자동으로 찍힌다.
class _FaceGuide extends StatelessWidget {
  const _FaceGuide({required this.passing});

  final bool passing;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _FaceGuidePainter(passing));
}

class _FaceGuidePainter extends CustomPainter {
  const _FaceGuidePainter(this.passing);

  final bool passing;

  @override
  void paint(Canvas canvas, Size size) {
    final oval = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.46),
      width: size.width * 0.68,
      height: size.height * 0.56,
    );

    // 타원 바깥만 어둡게 깔면 "안"이 어디인지 설명 없이 보인다.
    canvas.drawPath(
      Path()
        ..addRect(Offset.zero & size)
        ..addOval(oval)
        ..fillType = PathFillType.evenOdd,
      Paint()..color = Colors.black.withValues(alpha: 0.35),
    );

    canvas.drawOval(
      oval,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = passing ? 5 : 3
        ..color = passing ? Colors.greenAccent : Colors.white70,
    );
  }

  @override
  bool shouldRepaint(_FaceGuidePainter oldDelegate) =>
      oldDelegate.passing != passing;
}

/// 정면 → 왼쪽 → 오른쪽 진행 상태. 3단계라 지금 몇 번째인지가 보여야 한다.
class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.current, required this.labels});

  final int current;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          if (i > 0)
            Container(
              width: 28,
              height: 2,
              margin: const EdgeInsets.only(bottom: 18),
              color: i <= current ? scheme.primary : scheme.outlineVariant,
            ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dot(scheme, i),
              const SizedBox(height: 4),
              Text(
                labels[i],
                style: TextStyle(
                  fontSize: 12,
                  color: i == current ? scheme.primary : scheme.outline,
                  fontWeight: i == current ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _dot(ColorScheme scheme, int i) {
    final done = i < current;
    final active = i == current;
    final filled = done || active;

    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? scheme.primary : Colors.transparent,
        border: Border.all(
          color: filled ? scheme.primary : scheme.outlineVariant,
          width: 2,
        ),
      ),
      child: done
          ? Icon(Icons.check, size: 16, color: scheme.onPrimary)
          : Text(
              '${i + 1}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: active ? scheme.onPrimary : scheme.outline,
              ),
            ),
    );
  }
}
