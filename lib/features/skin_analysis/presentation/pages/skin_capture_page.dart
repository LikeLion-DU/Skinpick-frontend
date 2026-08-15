import 'dart:async';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show DeviceOrientation, SystemChrome;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/photo_picker.dart';
import '../../../../core/widgets/camera_preview_box.dart';
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

  final Map<FacePhotoType, XFile> _shots = {};

  /// 지금 찍어야 하는 단계. 모아둔 장수에서 유도한다 —
  /// 따로 증가시키면 두 번 더해져 _stages 범위를 넘는 순간 화면이 죽는다.
  int get _stageIndex =>
      math.min(_shots.length, _stages.length - 1);

  FaceGateResult? _result;

  /// 연속 통과 프레임 수. 자동 촬영은 이 값이 임계치에 닿을 때만 눌린다.
  int _okStreak = 0;

  /// 촬영이 막힌 뒤 자동 촬영을 잠시 멈춰 두는 시각.
  DateTime _autoCaptureNotBefore = DateTime.fromMillisecondsSinceEpoch(0);

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

    // ML Kit 에 넘기는 회전 보정은 세로로 든 상태를 전제로 한다. 가로로 돌리면
    // 90도 어긋난 프레임이 들어가 검출이 0개가 되고, 얼굴이 화면에 뻔히 보이는데도
    // "얼굴을 찾을 수 없어요" 에서 영구히 막힌다. 이 화면에서만 세로로 고정한다.
    unawaited(SystemChrome.setPreferredOrientations(
        const [DeviceOrientation.portraitUp]));

    // 카메라 열거가 실패해도 갤러리 경로는 살아 있어야 한다.
    if (!kIsWeb) _gate = faceGate(_stillOnlyCamera);

    // **여기서 카메라를 열지 않는다.** 안내 화면은 build 만 가로막을 뿐이라,
    // 스트림이 돌고 있으면 사용자가 문구를 읽는 동안 _onFrame 이 자동 촬영을
    // 눌러 세 장이 조용히 찍히고 로딩 화면으로 넘어간다. [촬영하기] 를 누른
    // 뒤에 연다.
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    unawaited(SystemChrome.setPreferredOrientations(DeviceOrientation.values));

    // 검출기를 먼저 닫으면 아직 날아오던 프레임이 닫힌 검출기를 부른다.
    // 카메라를 먼저 다 닫고, 그 뒤에 검출기를 닫는다.
    _runCamera(_closeCamera);
    _cameraLock = _cameraLock.whenComplete(() {
      _gate?.dispose();
      _gate = null;
    });
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
        // 안내 화면에서 앱을 다녀오면 여기로 온다. _intro 를 안 보면 그 경로로
        // 카메라가 열려 initState 에서 막은 자동 촬영이 되살아난다.
        if (!_intro && _controller == null) await _openCamera();
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

      // _set 은 dispose 된 뒤라면 클로저를 통째로 버린다. 그 사이 이 화면이
      // 사라지면 _controller 가 null 로 남고, dispose 가 걸어둔 _closeCamera 는
      // null 을 보고 그냥 돌아가 카메라가 영영 안 닫힌다. 먼저 대입해 둔다.
      _controller = controller;
      await controller.startImageStream(_onFrame);
      _set(() {
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
          if (_okStreak >= FaceGateConfig.autoCaptureStableFrames &&
              !_busy &&
              DateTime.now().isAfter(_autoCaptureNotBefore)) {
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

    // 피커를 열기 **전에** 잠근다. 열어 놓고 잠그면 그 사이 프리뷰가 계속 돌아
    // 자동 촬영이 끼어들고, 사용자가 정면으로 고른 사진이 다음 단계(왼쪽) 기준으로
    // 판정된다. 단계도 여기서 고정해 둔다.
    final stage = _stage;
    _set(() {
      _busy = true;
      _blockedGuide = null;
    });

    try {
      final picked = await PhotoPicker.fromGallery();
      if (!mounted || _disposed) return;
      if (picked == null) {
        // 사용자가 취소했다. 잠금만 풀고 프리뷰를 되살린다 — 쿨다운은 걸지 않는다.
        // 걸면 이미 자세를 잡고 있던 사용자가 이유 없이 3초를 기다린다.
        await _resumeStream();
        _set(() {
          _busy = false;
          _blockedGuide = null;
        });
        return;
      }

      final prepared =
          await gate.prepareSkinPhoto(picked, photoType: stage, fullGate: true);
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
      _result = null;
      _okStreak = 0;
      // 프리뷰는 통과인데 정지 이미지에서만 막히는 경우가 있다 — 프리뷰는 fast,
      // 업로드 관문은 accurate 라 흔들린 사진에서 갈린다. 쿨다운이 없으면
      // 0.9초마다 촬영·디코딩을 반복하면서 사용자는 손쓸 수 없는 안내만 본다.
      _autoCaptureNotBefore = DateTime.now().add(const Duration(seconds: 3));
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

    // **push 의 완료를 기다려 정리하지 않는다.** 로딩 화면은 성공하면
    // pushReplacement 로 결과 화면을 띄우는데, go_router 는 교체된 라우트의
    // completer 를 완료시키지 않아서 그 await 가 영원히 끝나지 않는다. 기다렸다가
    // 정리하면 _busy 가 선 채로 남아, 결과에서 뒤로 왔을 때 "처리 중…" 에
    // 버튼이 전부 꺼진 화면이 된다.
    //
    // 세 장을 넘긴 시점에 이 화면의 일은 끝났다. 지금 정리해 두면 어느 경로로
    // 돌아오든 처음(정면)부터 다시 찍을 수 있는 상태다.
    await _stopStream();
    _set(() {
      _busy = false;
      _blockedGuide = null;
      _result = null;
      _okStreak = 0;
      _shots.clear();
    });

    if (!mounted || _disposed) return;
    context.push(Routes.skinLoading);
  }

  Future<void> _stopStream() async {
    final controller = _controller;
    if (controller == null) return;
    try {
      if (controller.value.isStreamingImages) {
        await controller.stopImageStream();
      }
    } on Object catch (_) {
      // 이미 끊긴 스트림이면 그만이다.
    }
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

  /// 결과 화면에서 뒤로 돌아왔을 때 프리뷰를 되살린다.
  ///
  /// push 의 완료 future 를 쓸 수 없어서(위 _start 주석) 라우트가 다시 최상단이
  /// 되었는지를 build 에서 본다. 스트림이 살아나면 조건이 더 이상 맞지 않으므로
  /// 매 프레임 호출되지 않는다.
  void _ensureStreaming() {
    if (_disposed || _busy || kIsWeb) return;
    if (ModalRoute.of(context)?.isCurrent == false) return;
    final controller = _controller;
    if (controller == null || controller.value.isStreamingImages) return;
    _runCamera(_resumeStream);
  }

  /// 카메라를 열기 전에 무엇을 왜 찍는지 먼저 말한다(시안의 촬영 안내 화면).
  bool _intro = true;

  @override
  Widget build(BuildContext context) {
    if (_intro) return _introView();

    _ensureStreaming();

    return Scaffold(
      backgroundColor: Colors.black,
      body: _controller == null ? _noPreview() : _preview(),
    );
  }

  /// 촬영 안내. 시안 그대로 — 제목·부제·[촬영하기]·[넘어가기].
  Widget _introView() {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text('피부 진단을 위해\n얼굴 촬영을 도와드릴게요',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Text('정확한 분석을 위해 정면, 좌측, 우측 사진을\n촬영해주세요.',
                  style: Theme.of(context).textTheme.bodyMedium),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  setState(() => _intro = false);
                  _runCamera(_openCamera);
                },
                child: const Text('촬영하기'),
              ),
              const SizedBox(height: 12),
              // 시안은 두 버튼이 같은 오렌지다. 그대로 두면 어느 쪽이 주 동작인지
              // 안 보이지만, 디자이너의 선택이라 따른다.
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('넘어가기'),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
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

    return Stack(
      fit: StackFit.expand,
      children: [
        CameraPreviewBox(_controller!),
        // 어디에 얼굴을 두어야 하는지 형태로 보여준다. 문장만으로는
        // "조금 더 가까이" 가 얼마나 가까이인지 알 수 없다.
        _FaceGuide(passing: canCapture),
        if (kDebugMode && result?.debug != null)
          Positioned(top: 100, left: 8, child: _DebugOverlay(result!)),
        SafeArea(
          child: Stack(
            children: [
              // 시안의 상단 제목. 방향 안내는 타원 안 문구가 맡는다.
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 44, 32, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '피부 진단을 위해\n얼굴 촬영을 도와드릴게요',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '정확한 분석을 위해 정면, 좌측, 우측 사진을 촬영해주세요.  '
                      '(${_stageIndex + 1}/${_stages.length})',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 11, height: 1.4),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                child: IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_ios_new,
                      color: Colors.white, size: 20),
                ),
              ),

              // 타원 중앙의 방향 안내 — "정면을 바라봐주세요".
              Align(
                alignment: const Alignment(0, -0.12),
                child: Text(
                  _instruction(_stage),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 왜 안 찍히는지 말해 준다. 이유 없이 잠긴 셔터는 고장으로 읽힌다.
                      if (guide != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(guide,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12)),
                        )
                      else if (canCapture && !_busy)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Text('곧 자동으로 촬영됩니다 · 탭하면 바로 촬영',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                        ),
                      _CaptureShutter(
                        enabled: canCapture && !_busy,
                        busy: _busy,
                        onTap: _capture,
                      ),
                      TextButton(
                        onPressed: _busy ? null : _pickFromGallery,
                        child: const Text('갤러리에서 선택',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 12)),
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

/// 시안의 셔터 — 흰 원 + 오렌지 링. 게이트를 통과해야 켜진다.
class _CaptureShutter extends StatelessWidget {
  const _CaptureShutter({
    required this.enabled,
    required this.busy,
    required this.onTap,
  });

  final bool enabled;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 78,
        height: 78,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: enabled ? AppColors.primary : Colors.white38,
            width: 5,
          ),
        ),
        padding: const EdgeInsets.all(6),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: enabled ? Colors.white : Colors.white54,
          ),
          child: busy
              ? const Padding(
                  padding: EdgeInsets.all(18),
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : null,
        ),
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
    // 시안 비율 — 프레임 402 에 타원 306×390, 세로 중심은 위쪽 47%.
    final oval = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.47),
      width: size.width * 0.76,
      height: size.height * 0.45,
    );

    // 타원 바깥만 어둡게 깔면 "안"이 어디인지 설명 없이 보인다.
    canvas.drawPath(
      Path()
        ..addRect(Offset.zero & size)
        ..addOval(oval)
        ..fillType = PathFillType.evenOdd,
      Paint()..color = Colors.black.withValues(alpha: 0.45),
    );

    canvas.drawOval(
      oval,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = passing ? 3 : 1.5
        ..color = passing ? Colors.greenAccent : Colors.white,
    );

    // 시안의 방위점 4개 — 상·하·좌·우.
    final dot = Paint()..color = passing ? Colors.greenAccent : Colors.white;
    for (final point in [
      oval.topCenter,
      oval.bottomCenter,
      oval.centerLeft,
      oval.centerRight,
    ]) {
      canvas.drawCircle(point, 5.5, dot);
    }
  }

  @override
  bool shouldRepaint(_FaceGuidePainter oldDelegate) =>
      oldDelegate.passing != passing;
}


