import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data' show Uint8List;
import 'dart:ui' show lerpDouble;

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
import '../../../../core/camera/camera_error_message.dart';
import '../../../../core/camera/preview_fit.dart';
import '../../../../core/utils/photo_picker.dart';
import '../../../../core/widgets/camera_preview_box.dart';
import '../../../../shared/widgets/ray_ring.dart';
import '../../../../shared/widgets/skin_mascot.dart';
import '../../data/datasources/face_gate.dart';
import '../../domain/captured_image_validator.dart';
import '../../domain/entities/face_gate_result.dart';
import '../../domain/entities/skin_photo_set.dart';
import '../../domain/face_gate_config.dart';
import '../../domain/face_gate_rules.dart' show CaptureReadiness, readinessOf;
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
  const SkinCapturePage({super.key, this.onboarding = false});

  /// 가입 직후 첫 진입인가. 이 화면의 안내(`_introView`)는 시안 그대로라 두 경로가
  /// 같은 것을 보여주지만, 두 버튼이 하는 일은 다르다 — 온보딩은 결과까지 간 뒤
  /// 프로필을 물어야 하고(플래그), 넘어가면 설문으로 보내야 한다.
  ///
  /// **안내 화면을 따로 만들지 않는다.** 예전에 그렇게 했다가 가입 사용자가 같은
  /// 안내를 두 번 봤다 — 여기 이미 있는 것을 못 보고 한 벌 더 만든 탓이다.
  final bool onboarding;

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

  /// 연속 통과 프레임 수. 셔터 활성화와 자동 촬영이 이 값 하나에 걸려 있다.
  int _okStreak = 0;

  /// 화면에 그리는 코 위치(프레임 좌표). 검출값을 그대로 그리면 300ms 마다
  /// 몇 픽셀씩 튀어서 가이드가 얼굴 위에서 떨린다. 이전 값과 섞어 따라가게 한다.
  Offset? _smoothNose;

  /// 가이드 곡선의 크기 기준이 되는 얼굴 높이(프레임 좌표). 같이 부드럽게 한다 —
  /// 이것만 튀면 곡선이 얼굴 위에서 커졌다 작아졌다 한다.
  double? _smoothFaceHeight;

  CaptureReadiness get _readiness => readinessOf(_result, _okStreak);

  /// 방금 찍어서 **사용자 확인을 기다리는** 사진. 있으면 프리뷰 대신 확인 화면을
  /// 그린다. [다음] 을 눌러야 `_accept` 로 넘어간다 — 찍자마자 다음 단계로
  /// 넘어가면 사용자는 자기가 무엇을 올렸는지 끝내 보지 못한다.
  _PendingShot? _pending;

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

  /// 카메라 작업을 하나씩 줄 세운다. 결과를 기다릴 필요가 없을 때 쓴다.
  void _runCamera(Future<void> Function() op) {
    _cameraLock = _cameraLock.then((_) => op()).catchError((_) {});
  }

  /// 같은 줄에 세우되 **결과를 기다린다.**
  ///
  /// 촬영·스트림 재개는 순서가 어긋나면 CameraX 가 use case 를 중복으로 바인딩하고
  /// "No supported surface combination" 로 화면을 덮는다. 실제로 그렇게 터졌다 —
  /// _recover 가 부른 startImageStream 이 끝나기 전에 rebuild 가 한 번 더 부르면,
  /// takePicture 가 남긴 IMAGE_CAPTURE 위에 ImageAnalysis 가 두 개 붙는다.
  /// `isStreamingImages` 는 그 사이를 못 막는다 — 네이티브 바인딩보다 먼저 바뀐다.
  ///
  /// 실패해도 락은 이어져야 한다. 한 번 깨진 채로 두면 이후 카메라 작업이 전부 막힌다.
  Future<void> _lockCamera(Future<void> Function() op) {
    final running = _cameraLock.then((_) => op());
    _cameraLock = running.catchError((_) {});
    return running;
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
      _set(() => _cameraError = cameraErrorMessage(e, '카메라를 열지 못했습니다.'));
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
  ///
  /// **확인 화면이 떠 있으면 아예 보지 않는다.** `_ensureStreaming` 에도 같은
  /// 조건이 있지만 그것만으로는 못 막는다 — 앱을 나갔다 오면 `_openCamera` 가
  /// 스트림을 무조건 다시 켠다. 그 경로로 프레임이 들어오면 사용자가 사진을
  /// 들여다보는 사이 자동 촬영이 눌려서, 보고 있던 사진이 엉뚱한 것으로 바뀐다.
  /// 카메라를 다시 여는 것 자체는 맞다 — [다시 촬영] 을 누를 때 프리뷰가 살아
  /// 있어야 한다. 막을 곳은 여기다.
  void _onFrame(CameraImage frame) {
    final gate = _gate;
    if (gate == null || _analyzing || _busy || _disposed || _pending != null) {
      return;
    }

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
            _smoothNose = _smoothedNose(result.nose);
            _smoothFaceHeight = _smoothedHeight(result.faceBox?.height);
          });
          // 조건이 잠깐 맞은 게 아니라 유지되고 있을 때만 셔터를 누른다.
          if (_readiness == CaptureReadiness.ready &&
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

  /// 이전 값과 섞어 떨림을 줄인다. 얼굴이 사라지면 바로 지운다 — 남은 가이드가
  /// 허공에서 천천히 녹아 없어지면 아직 잡고 있는 것처럼 보인다.
  ///
  /// 첫 프레임은 섞지 않는다. 앞이 null 인데 0 에서 보간하면 가이드가 매번
  /// 화면 좌상단에서 날아온다.
  Offset? _smoothedNose(Offset? next) {
    if (next == null) return null;
    final previous = _smoothNose;
    if (previous == null) return next;
    return Offset.lerp(previous, next, FaceGateConfig.faceBoxSmoothing)!;
  }

  double? _smoothedHeight(double? next) {
    if (next == null) return null;
    final previous = _smoothFaceHeight;
    if (previous == null) return next;
    return lerpDouble(previous, next, FaceGateConfig.faceBoxSmoothing);
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
      // 스트림 정지와 촬영을 한 덩어리로 잠근다. 둘 사이에 스트림 재개가 끼어들면
      // ImageAnalysis 가 두 번 바인딩된다.
      late final XFile shot;
      await _lockCamera(() async {
        if (controller.value.isStreamingImages) {
          await controller.stopImageStream();
        }
        shot = await controller.takePicture();
      });

      // 프리뷰의 faceRect 를 크롭에 쓰지 않는다. 사진에서 한 번 더 검출한다.
      final prepared = await gate.prepareSkinPhoto(shot, photoType: _stage);
      if (!mounted || _disposed) return;

      if (prepared.file == null) {
        // 통과하지 못한 이미지는 올리지 않는다. 프리뷰로 돌아가 다시 잡게 한다.
        await _recover(_guideOf(prepared.gate));
        return;
      }

      // 바이트를 지금 한 번만 읽는다. `Image.file` 은 `dart:io` 라 이 화면을
      // 웹에서 빌드할 수 없게 만들고, 매 rebuild 마다 다시 읽으면 확인 화면이
      // 깜빡인다.
      final bytes = await prepared.file!.readAsBytes();
      if (!mounted || _disposed) return;

      // **여기서 바로 다음 단계로 넘기지 않는다.** 사용자가 방금 찍힌 사진을
      // 보고 [다시 촬영] / [다음] 을 고른다. 스트림은 촬영하면서 이미 멈춰 있고
      // 확인 화면에서도 켜지 않는다 — 뒤에서 자동 촬영이 또 눌리면 사용자가
      // 보고 있던 사진이 조용히 다른 것으로 바뀐다.
      _set(() {
        _pending =
            _PendingShot(_stage, prepared.file!, bytes, prepared.checks);
        _busy = false;
      });
    } on Object catch (e) {
      // takePicture · ML Kit · 파일 IO · 이미지 디코딩 어디서든 던질 수 있다.
      // 하나라도 새어 나가면 _busy 가 선 채로 화면이 죽는다.
      await _recover(cameraErrorMessage(e, '촬영에 실패했습니다.'));
    }
  }

  /// 확인 화면에서 [다시 촬영]. 방금 찍은 사진을 버리고 프리뷰로 돌아간다.
  ///
  /// ponytail: 버린 파일을 지우지 않는다. 지우려면 `dart:io` 가 필요한데 이 화면은
  /// 웹에서도 빌드되어야 해서(`kIsWeb` 분기가 있다) import 하는 순간 웹 빌드가
  /// 깨진다. 임시 디렉터리에 100~200KB 짜리가 재촬영 횟수만큼 남을 뿐이고 OS 가
  /// 회수한다. 쌓이는 게 문제가 되면 FaceGate 에 삭제를 하나 열어 위임한다.
  Future<void> _retake() async {
    // **스트림을 되살리기 전에 상태를 먼저 지운다.** 순서를 뒤집으면 스트림이
    // 살아난 뒤 이 대입이 실행될 때까지 `_okStreak` 가 아직 3 이고 쿨다운도 이미
    // 지난 시각이라, 프레임 하나만 들어와도 그 자리에서 다시 촬영된다 —
    // "다시 찍겠다"고 누른 사람이 자세를 고칠 틈 없이 확인 화면을 다시 받는다.
    // 다른 재개 지점(_recover · _accept · _pickFromGallery)은 `_busy` 가 서 있어
    // 막히지만 여기는 `_capture` 가 이미 `_busy` 를 내려놓은 뒤다.
    _set(() {
      _pending = null;
      _result = null;
      _okStreak = 0;
      _smoothNose = null;
      _smoothFaceHeight = null;
      _blockedGuide = null;
      _autoCaptureNotBefore = DateTime.now().add(const Duration(seconds: 3));
    });

    await _lockCamera(_resumeStream);
  }

  /// 확인 화면에서 [다음].
  Future<void> _confirm() async {
    final confirmed = _pending;
    if (confirmed == null) return;
    _set(() {
      _pending = null;
      _busy = true;
    });
    // **`_stage` 가 아니라 찍을 때의 단계로 저장한다.** 둘은 지금 같지만 같다는
    // 보장이 없다 — `_stage` 는 모아둔 장수에서 유도하는 값이라, 확인 화면이 떠
    // 있는 동안 `_shots` 를 건드리는 경로가 하나라도 생기면 정면 사진이 왼쪽
    // 자리에 저장되어 그대로 업로드된다. 서버는 세 파트를 받을 뿐이라 안 보인다.
    await _accept(confirmed.stage, confirmed.file);
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
        await _lockCamera(_resumeStream);
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

      // 갤러리는 확인 화면을 거치지 않는다. 사용자가 방금 피커에서 그 사진을 직접
      // 골랐고, 이 경로는 4개 조건을 전부 다시 보는 fullGate 를 이미 통과했다.
      await _accept(stage, prepared.file!);
    } on Object catch (e) {
      await _recover(cameraErrorMessage(e, '사진을 불러오지 못했습니다.'));
    }
  }

  /// 한 단계를 통과했다. 세 장이 다 모였으면 업로드하고, 아니면 다음 방향으로 넘어간다.
  Future<void> _accept(FacePhotoType stage, XFile file) async {
    _shots[stage] = file;

    final photos = SkinPhotoSet.tryFrom(_shots);
    if (photos == null) {
      await _lockCamera(_resumeStream);
      _set(() {
        _busy = false;
        _result = null; // 방향이 바뀌었으니 이전 판정은 버린다
        _blockedGuide = null; // 이전 단계의 실패 안내도 같이 버린다
        _okStreak = 0;
        _smoothNose = null;
        _smoothFaceHeight = null;
      });
      return;
    }

    await _start(photos);
  }

  /// 업로드하지 못했을 때 화면을 되살린다. 이걸 빠뜨리면 _busy 가 선 채로
  /// 촬영·갤러리 버튼이 영구 비활성이 되고 프리뷰도 멈춘 채로 남는다.
  Future<void> _recover(String guide) async {
    await _lockCamera(_resumeStream);
    _set(() {
      _busy = false;
      _blockedGuide = guide;
      _result = null;
      _okStreak = 0;
      _smoothNose = null;
      _smoothFaceHeight = null;
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
    await _lockCamera(_stopStream);
    _set(() {
      _busy = false;
      _blockedGuide = null;
      _result = null;
      _okStreak = 0;
      _smoothNose = null;
      _smoothFaceHeight = null;
      _shots.clear();
    });

    if (!mounted || _disposed) return;
    // push 가 아니라 교체다. 세 장을 넘긴 시점에 이 화면의 일은 끝났고, 결과에서
    // 뒤로 가는 사용자는 "촬영 이전 화면"으로 나가려는 것이지 카메라를 다시 보려는
    // 게 아니다. push 로 두면 결과 아래에 카메라가 살아 있다가 뒤로가기에 되살아난다.
    //
    // 다시 찍는 길은 홈의 [다시 분석] 과 로딩 실패의 [다시 촬영하기] 뿐이다.
    context.pushReplacement(Routes.skinLoading);
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

  // "왼쪽" 은 언제나 **고개를 돌리는 방향**이다(사용자 기준). "왼쪽 얼굴(왼쪽 뺨)"
  // 이라고 쓰면 지시문·게이트 판정과 정반대가 된다 — 게이트는 왼쪽으로 돌린
  // 사진(오른쪽 뺨이 보임)을 통과시킨다.
  static String _label(FacePhotoType type) => switch (type) {
        FacePhotoType.front => '정면',
        FacePhotoType.left => '왼쪽으로 돌린 얼굴',
        FacePhotoType.right => '오른쪽으로 돌린 얼굴',
      };

  static String _instruction(FacePhotoType type) => switch (type) {
        FacePhotoType.front => '정면을 바라봐 주세요',
        FacePhotoType.left => '고개를 왼쪽으로 돌려주세요',
        FacePhotoType.right => '고개를 오른쪽으로 돌려주세요',
      };

  /// 화살표 힌트를 흘릴지. 판정 전(null)이거나 **방향이 문제일 때만** 참이다.
  bool get _needsTurn {
    final result = _result;
    return result == null ||
        (result is FaceGateBlocked &&
            result.reason == FaceGateReason.wrongOrientation);
  }

  /// 결과 화면에서 뒤로 돌아왔을 때 프리뷰를 되살린다.
  ///
  /// push 의 완료 future 를 쓸 수 없어서(위 _start 주석) 라우트가 다시 최상단이
  /// 되었는지를 build 에서 본다. 스트림이 살아나면 조건이 더 이상 맞지 않으므로
  /// 매 프레임 호출되지 않는다.
  void _ensureStreaming() {
    // 확인 화면이 떠 있으면 스트림을 되살리지 않는다. 뒤에서 자동 촬영이 눌리면
    // 사용자가 보고 있던 사진이 조용히 다른 것으로 바뀐다.
    if (_disposed || _busy || kIsWeb || _pending != null) return;
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

    final pending = _pending;
    return Scaffold(
      backgroundColor: Colors.black,
      body: pending != null
          ? _reviewView(pending)
          : (_controller == null ? _noPreview() : _preview()),
    );
  }

  /// 촬영 안내. 시안 그대로 — 제목·부제·[촬영하기]·[넘어가기].
  Widget _introView() {
    return Scaffold(
      body: SafeArea(
        // **스크롤 가능해야 한다.** 고정 300 짜리 고리와 버튼 두 개가 들어 있어서,
        // 작은 기기나 글자 크기를 키운 기기에서는 [촬영하기] 가 화면 밖으로
        // 밀린다 — 그러면 온보딩이 여기서 끝난다.
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
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
              const SizedBox(height: 32),
              // 시안은 이 자리에 마스코트를 방사 눈금 고리 안에 세운다. 촬영 중
              // 얼굴 가이드와 같은 고리라, 안내에서 본 자리에 얼굴을 넣게 된다.
              const Center(
                child: RayRing(
                  diameter: 300,
                  child: SkinMascot(size: 176),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // 로딩 화면이 이 플래그를 보고 분석을 기다리는 동안 프로필
                  // 설문을 얹는다. 촬영을 시작한 가입자만 켠다.
                  if (widget.onboarding) {
                    ref.read(onboardingCaptureProvider.notifier).state = true;
                  }
                  setState(() => _intro = false);
                  _runCamera(_openCamera);
                },
                child: const Text('촬영하기'),
              ),
              const SizedBox(height: 12),
              // 시안은 두 버튼이 같은 오렌지다. 그대로 두면 어느 쪽이 주 동작인지
              // 안 보이지만, 디자이너의 선택이라 따른다.
              ElevatedButton(
                // 가입자가 넘어가면 pop 은 홈이다 — 진단도 프로필도 없이 떨어지면
                // 음식 점수와 비교할 기준값이 하나도 없다. 설문은 보여준다. 다만
                // 강제하지 않는다(건너뛰기가 있는 full 모드) — 진단을 안 본
                // 사용자에게 "AI 진단을 보정해 달라"고 말할 근거가 아직 없다.
                onPressed: () => widget.onboarding
                    ? context.pushReplacement(Routes.skinType)
                    : context.pop(),
                child: const Text('넘어가기'),
              ),
              const SizedBox(height: 24),
            ],
          ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 방금 찍은 사진을 보여주고 사용자가 정하게 한다.
  ///
  /// **체크리스트는 관문이 아니다.** 경고가 있어도 [다음] 은 눌린다 — 이 사진을
  /// 쓸지는 사진을 직접 보고 있는 사람이 정한다. 여기서 막으면 프리뷰(`fast`)와
  /// 촬영본(`accurate`) 검출기가 갈릴 때 사용자가 빠져나갈 수 없게 된다.
  Widget _reviewView(_PendingShot shot) {
    final warnings =
        shot.checks.where((c) => c.state == PhotoCheckState.warn).toList();

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${_label(shot.stage)} 사진을 확인해 주세요',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                Text('${_stageIndex + 1}/${_stages.length}',
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 13)),
              ],
            ),
          ),
          // **사진과 항목은 스크롤에 넣고 버튼은 밖에 둔다.** 글자 크기를 키운
          // 기기에서 항목이 전부 경고로 뜨면 문구가 몇 줄씩 늘어나는데, 전부
          // 고정 높이로 쌓으면 Column 이 넘쳐 [다시 촬영]·[다음] 이 화면 밖으로
          // 밀린다 — 사용자가 확인 화면에서 나갈 방법이 없어진다.
          // (같은 유형을 피부 타입 카드에서 한 번 겪었다 — 3b15057)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ConstrainedBox(
                    // 세로로 긴 크롭이 화면을 다 먹지 않게 잡아 둔다. 항목이
                    // 한 줄도 안 보이면 확인 화면의 뜻이 없다.
                    constraints: BoxConstraints(
                        maxHeight: MediaQuery.sizeOf(context).height * 0.45),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      // 업로드되는 것과 **같은 이미지**다 — 얼굴만 잘라낸
                      // 결과물이라 프리뷰에서 보던 화면 전체와 다르게 보이는 게
                      // 정상이다.
                      child: Image.memory(shot.bytes, fit: BoxFit.contain),
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (final check in shot.checks) _CheckRow(check),
                  const SizedBox(height: 10),
                  // 확인 못 하는 것을 조용히 빼면 사용자는 목록이 전부인 줄 안다.
                  const Text(capturedPhotoBlindSpots,
                      style: TextStyle(
                          color: Colors.white38, fontSize: 11, height: 1.5)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 18),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _retake,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white38),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('다시 촬영'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    // 경고가 있어도 막지 않는다. 다만 주 동작으로 보이지는 않게
                    // 해서, 사용자가 무심코 넘기지 않도록 한 박자 세운다.
                    onPressed: _confirm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor:
                          warnings.isEmpty ? AppColors.primary : Colors.white24,
                    ),
                    child: Text(
                      _shots.length == _stages.length - 1 ? '분석 시작' : '다음',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
    final readiness = _readiness;
    // **한 프레임 통과로는 셔터를 켜지 않는다.** 고개를 돌리다 스쳐 지나가는
    // 순간에 조건이 맞을 수 있고, 그때 눌린 셔터는 자세를 잡기도 전에 다음
    // 단계로 넘겨 버린다. 0.9초(3프레임) 유지해야 켠다.
    final ready = readiness == CaptureReadiness.ready;

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
        _FaceGuide(passing: ready),
        // 얼굴을 네모로 감싸지 않는다. 네모는 "이 상자를 어디에 맞추지?" 를
        // 묻게 만드는데, 사용자가 알아야 하는 건 **어느 쪽으로 돌리느냐** 다.
        // 코를 기준으로 방향을 그리면 읽지 않아도 따라 하게 된다.
        if (_smoothNose != null &&
            _smoothFaceHeight != null &&
            result?.frameSize != null)
          _NoseGuideOverlay(
            nose: _smoothNose!,
            faceHeight: _smoothFaceHeight!,
            frame: result!.frameSize!,
            stage: _stage,
            readiness: readiness,
          ),
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 측면 단계에서는 문장보다 움직임이 빠르다. 단, **방향이
                    // 문제일 때만** 돌린다 — 거리·밝기로 막혔는데 화살표가 흐르면
                    // 사용자는 더 돌고, 각도가 커질수록 검출이 나빠진다.
                    // 자리는 항상 잡아 둔다. 임계각 근처에서 판정이 300ms 마다
                    // 진동하면 읽고 있는 문구가 같이 튄다.
                    if (_stage != FacePhotoType.front)
                      SizedBox(
                        height: 44,
                        child: _needsTurn
                            ? Center(
                                child: _TurnHint(
                                    toLeft: _stage == FacePhotoType.left))
                            : null,
                      ),
                    Text(
                      _instruction(_stage),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
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
                      else if (!_busy && ready)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Text('✓ 촬영 준비 완료 · 곧 자동으로 촬영됩니다',
                              style: TextStyle(
                                  color: Colors.greenAccent, fontSize: 12)),
                        )
                      // 조건은 맞았지만 아직 유지 중이다. 여기서 아무 말도 안 하면
                      // 안내가 사라진 채 버튼만 꺼져 있어서 고장으로 읽힌다.
                      else if (!_busy && readiness == CaptureReadiness.validating)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Text('좋아요 · 자세를 잠시 유지해주세요',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                        ),
                      _CaptureShutter(
                        enabled: ready && !_busy,
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





/// 확인 항목 한 줄. **`unknown` 은 ✓ 로 그리지 않는다** — 판단할 수단이 없는
/// 것을 통과로 보여주면 사용자는 확인받았다고 믿는다.
class _CheckRow extends StatelessWidget {
  const _CheckRow(this.check);

  final PhotoCheck check;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (check.state) {
      PhotoCheckState.ok => (Icons.check, Colors.greenAccent),
      PhotoCheckState.warn => (Icons.error_outline, AppColors.primary),
      PhotoCheckState.unknown => (Icons.remove, Colors.white38),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              // 경고면 무엇이 문제인지까지 말한다. 항목 이름만으로는 뭘 고쳐야
              // 할지 알 수 없다.
              check.note ??
                  (check.state == PhotoCheckState.unknown
                      ? '${check.label} — 확인할 수 없었어요'
                      : check.label),
              style: TextStyle(color: color, fontSize: 12, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

/// 확인을 기다리는 촬영본. 바이트까지 들고 있는 이유는 `_capture` 주석 참조.
class _PendingShot {
  const _PendingShot(this.stage, this.file, this.bytes, this.checks);

  final FacePhotoType stage;
  final XFile file;
  final Uint8List bytes;

  /// 촬영본 확인 항목. **막지 않는다** — 경고가 있어도 [다음] 은 눌린다.
  final List<PhotoCheck> checks;
}

/// 코를 기준으로 **어느 쪽으로 돌려야 하는지**를 그린다.
///
/// 얼굴을 네모로 감싸지 않는 이유가 있다. 네모는 "이 상자를 어디에 맞추지?" 를
/// 묻게 만드는데, 3단계 촬영에서 사용자가 실제로 알아야 하는 것은 위치가 아니라
/// **방향**이다. 코에 붙은 선과 호는 읽지 않아도 따라 하게 된다.
///
/// - 정면: 코를 지나는 세로 축. 얼굴을 이 축에 세우면 된다.
/// - 왼쪽·오른쪽: 돌려야 하는 쪽에 호를 그린다. 호가 있는 쪽이 코가 갈 방향이다.
///   방향은 `_TurnHint` 화살표와 같은 쪽이다 — 둘이 어긋나면 화면이 두 말을 한다.
///
/// 좌표는 이미 사용자 기준으로 뒤집혀 들어온다(`toUserSpace`). 여기서는 프리뷰가
/// `BoxFit.cover` 로 확대·절단한 만큼만 맞추면 된다 — 그걸 빼먹고 단순 비례로
/// 그리면 가이드가 얼굴에서 한쪽으로 밀린다.
class _NoseGuideOverlay extends StatelessWidget {
  const _NoseGuideOverlay({
    required this.nose,
    required this.faceHeight,
    required this.frame,
    required this.stage,
    required this.readiness,
  });

  /// 프레임 좌표의 코 위치.
  final Offset nose;

  /// 프레임 좌표의 얼굴 높이. 가이드 크기를 얼굴에 비례시키는 데만 쓴다 —
  /// 고정 픽셀로 그리면 멀리 있을 때 얼굴을 덮고 가까울 때 점처럼 작아진다.
  final double faceHeight;

  final Size frame;
  final FacePhotoType stage;
  final CaptureReadiness readiness;

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _NoseGuidePainter(nose, faceHeight, frame, stage, readiness),
      );
}

class _NoseGuidePainter extends CustomPainter {
  const _NoseGuidePainter(
      this.nose, this.faceHeight, this.frame, this.stage, this.readiness);

  final Offset nose;
  final double faceHeight;
  final Size frame;
  final FacePhotoType stage;
  final CaptureReadiness readiness;

  static const _colors = {
    CaptureReadiness.invalid: Colors.white70,
    CaptureReadiness.validating: AppColors.primary,
    CaptureReadiness.ready: Colors.greenAccent,
  };

  @override
  void paint(Canvas canvas, Size size) {
    final center = coverPointToWidget(nose, frame, size);
    final reach = faceHeight * coverScale(frame, size) * 0.5;
    final color = _colors[readiness]!;

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = color;

    // 코 자리. 가이드가 무엇에 붙어 있는지 한 점으로 못 박는다.
    canvas.drawCircle(center, 5, Paint()..color = color);

    switch (stage) {
      // 세로 축. 코 주변은 비워 둔다 — 선이 점을 뚫고 지나가면 어디가 기준인지
      // 오히려 흐려진다.
      case FacePhotoType.front:
        canvas.drawLine(Offset(center.dx, center.dy - reach),
            Offset(center.dx, center.dy - reach * 0.28), stroke);
        canvas.drawLine(Offset(center.dx, center.dy + reach * 0.28),
            Offset(center.dx, center.dy + reach), stroke);

      // 돌려야 하는 쪽에 호. 사용자 좌표라 왼쪽이 x 작은 쪽이다.
      case FacePhotoType.left:
        _arc(canvas, center, reach, stroke, size, toLeft: true);
      case FacePhotoType.right:
        _arc(canvas, center, reach, stroke, size, toLeft: false);
    }
  }

  /// 돌려야 하는 쪽에 괄호 하나를 세운다.
  ///
  /// **얼굴을 감싸지 않는다.** 처음에는 코를 중심으로 큰 호를 두 겹 그렸는데,
  /// 에뮬레이터에서 보니 가이드 타원과 겹쳐 방향이 아니라 잡음으로 읽혔다.
  /// 얼굴 옆에 하나만 세우는 쪽이 한눈에 들어온다.
  void _arc(Canvas canvas, Offset center, double reach, Paint stroke, Size size,
      {required bool toLeft}) {
    final sign = toLeft ? -1.0 : 1.0;
    final width = reach * 0.7;
    // 얼굴이 크면 호가 화면 높이를 넘어간다. 위아래로도 잘라 둔다.
    final height = math.min(reach * 1.6, size.height * 0.5);

    // **화면 안으로 잡아 둔다.** 얼굴이 가장자리에 있으면 그 옆자리는 화면 밖이라,
    // 안 잡으면 방향 표시가 통째로 사라진다 — 에뮬레이터에서 실제로 그랬다.
    // 방향을 알려주는 표시라 자리가 조금 밀려도 뜻은 그대로다.
    const margin = 16.0;
    final x = (center.dx + sign * reach * 0.6)
        .clamp(margin + width / 2, size.width - margin - width / 2)
        .toDouble();

    // 볼록한 쪽이 돌아갈 방향을 향한다. 캔버스 각도는 3시 방향이 0이고
    // 시계방향이 양수라, 6시에서 반 바퀴 돌면 왼쪽 반원이 그려진다.
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(x, center.dy), width: width, height: height),
      toLeft ? math.pi / 2 : -math.pi / 2,
      math.pi,
      false,
      stroke,
    );
  }

  @override
  bool shouldRepaint(_NoseGuidePainter oldDelegate) =>
      oldDelegate.nose != nose ||
      oldDelegate.faceHeight != faceHeight ||
      oldDelegate.frame != frame ||
      oldDelegate.stage != stage ||
      oldDelegate.readiness != readiness;
}

/// 측면 단계에서 고개를 어느 쪽으로 돌릴지 움직임으로 보여준다.
///
/// 거울 프리뷰 앞에서 "왼쪽으로" 라는 문장은 한 박자 늦게 읽힌다 —
/// 돌릴 방향으로 흘러가는 화살표는 읽지 않아도 따라 하게 된다.
class _TurnHint extends StatefulWidget {
  const _TurnHint({required this.toLeft});

  final bool toLeft;

  @override
  State<_TurnHint> createState() => _TurnHintState();
}

class _TurnHintState extends State<_TurnHint>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sweep = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _sweep.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final direction = widget.toLeft ? -1.0 : 1.0;
    return AnimatedBuilder(
      animation: _sweep,
      builder: (context, chevrons) {
        final progress = Curves.easeOut.transform(_sweep.value);
        return Opacity(
          opacity: 1.0 - progress,
          child: Transform.translate(
            offset: Offset(direction * 28 * progress, 0),
            child: chevrons,
          ),
        );
      },
      child: Icon(
        widget.toLeft
            ? Icons.keyboard_double_arrow_left
            : Icons.keyboard_double_arrow_right,
        color: Colors.white,
        size: 36,
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

    String num(double? v) => v == null ? '-' : v.toStringAsFixed(2);

    // 중앙에서 얼마나 벗어났는지(프레임 대비). 임계값을 실기기에서 맞출 때 쓴다.
    final box = debug.faceBox;
    final frame = debug.frameSize;
    final offset = box == null || frame == null || frame.isEmpty
        ? null
        : Offset((box.center.dx - frame.width / 2) / frame.width,
            (box.center.dy - frame.height / 2) / frame.height);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Text(
          'Face: ${debug.faceCount}\n'
          // 오버레이 좌표 변환이 통째로 이 값에 걸려 있다. 프레임이 세로로
          // 서서 오는지(720x1280) 가로로 누워서 오는지(1280x720)에 따라 코
          // 가이드가 얼굴에서 크게 어긋나는데, 화면에 안 띄우면 실기기에서
          // "어긋난다"는 것만 알고 왜인지는 못 본다.
          'Frame: ${frame == null ? '-' : '${frame.width.toInt()}x${frame.height.toInt()}'}\n'
          'Yaw: ${num(debug.yaw)}  Pitch: ${num(debug.pitch)}  Roll: ${num(debug.roll)}\n'
          'Ratio: ${num(debug.faceHeightRatio == null ? null : debug.faceHeightRatio! * 100)}%\n'
          'Off: ${num(offset?.dx)}, ${num(offset?.dy)}\n'
          'Nose: ${debug.nose == null ? '-' : '${debug.nose!.dx.toInt()},${debug.nose!.dy.toInt()}'}\n'
          'Eye: ${num(debug.eyeOpen)}  Luma: ${debug.luminance ?? '-'}\n'
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
    // **높이 비율(0.45)을 건드리지 마라.** 게이트는 얼굴 높이가 프레임의
    // 0.34~0.65 일 때 통과시킨다(`FaceGateConfig`). 이 타원이 그 구간 가운데를
    // 가리키도록 맞춰 놓은 값이라, 지름을 폭 기준으로 바꾸면 기기 화면비에 따라
    // 목표가 통과 구간 밖으로 밀린다 — 가이드에 얼굴을 맞췄는데 안 찍히는 화면이 된다.
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

    // 확정 시안이 흰 얇은 타원과 방위점 4개를 **오렌지 고리 + 방사 눈금**으로
    // 바꿨다. 통과했을 때 초록으로 바뀌는 것은 남긴다 — 시안에는 통과 상태가
    // 없지만, 색이 안 바뀌면 사용자가 언제 셔터를 눌러도 되는지 알 수 없다.
    final color = passing ? Colors.greenAccent : AppColors.primary;

    canvas.drawOval(
      oval,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = passing ? 4 : 3
        ..color = color,
    );

    // 눈금은 타원 둘레를 따라 세운다. 원 기준으로 그리면 세로로 긴 타원 옆에서
    // 눈금만 동그랗게 돌아 두 모양이 어긋난다.
    const tickCount = 44;
    final tick = Paint()
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = color;

    for (var index = 0; index < tickCount; index++) {
      final angle = 2 * math.pi * index / tickCount;
      final unit = Offset(math.cos(angle), math.sin(angle));
      final base = Offset(
        oval.center.dx + unit.dx * (oval.width / 2 + 7),
        oval.center.dy + unit.dy * (oval.height / 2 + 7),
      );
      final end = Offset(
        oval.center.dx + unit.dx * (oval.width / 2 + 21),
        oval.center.dy + unit.dy * (oval.height / 2 + 21),
      );
      canvas.drawLine(base, end, tick);
    }
  }

  @override
  bool shouldRepaint(_FaceGuidePainter oldDelegate) =>
      oldDelegate.passing != passing;
}


