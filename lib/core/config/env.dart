import 'package:flutter/foundation.dart';

/// 빌드 시점에 --dart-define 으로 주입한다.
///
///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api/v1
///
/// Android 에뮬레이터의 호스트는 10.0.2.2, iOS 시뮬레이터는 localhost다.
/// 이 한 줄 때문에 반나절을 잃는 팀이 매번 나온다.
class Env {
  const Env._();

  /// 로컬 개발 서버. debug · profile 의 기본값이다.
  static const String _localHost = 'http://10.0.2.2:8080/api/v1';

  /// 배포 서버 (PRD §9.6 "배포는 https").
  static const String _deployedHost = 'https://1-201-116-157.sslip.io/api/v1';

  /// **기본값을 빌드 모드로 가른다.** `--dart-define` 하나에 기대면, 그 플래그를
  /// 빠뜨린 릴리스 빌드가 실기기에서 `10.0.2.2` 를 찌른다 — 기기에는 그런 호스트가
  /// 없으니 모든 화면이 연결 오류로 뜨는데, 빌드는 성공했고 로그도 안 남아서
  /// "서버가 죽었나" 부터 의심하게 된다.
  ///
  /// 정의를 넘기면 여전히 그쪽이 이긴다. 실기기에 로컬 서버를 물려 볼 때
  /// `--dart-define=API_BASE_URL=http://<맥 IP>:8080/api/v1` 로 덮는다.
  ///
  /// **릴리스 빌드로 그걸 하려면 평문 예외가 따로 있어야 한다.** Android 릴리스는
  /// `android/app/src/main/res/xml/network_security_config.xml` 이 10.0.2.2 ·
  /// localhost · 127.0.0.1 만 허용해서 LAN IP 로 가는 http 를 OS 가 막는다 —
  /// 그 파일에 IP 한 줄을 더해야 한다(절차는 파일 주석에 있다). debug 는
  /// `src/debug` 오버레이가 전부 열어 두므로 이 정의만으로 된다.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: kReleaseMode ? _deployedHost : _localHost,
  );

  /// 서버 없이 UI만 확인할 때 사용하는 로컬 목업 모드.
  static const bool mockMode = bool.fromEnvironment('MOCK_MODE');

  static const Duration connectTimeout = Duration(seconds: 10);

  /// 서버 AI 타임아웃은 **경로마다 다르다** — 음식·문장 생성 25초,
  /// 피부 분석 28초(`application.yml` 의 `timeout-seconds` · `skin-timeout-seconds`).
  /// 429 를 한 번 재시도하면 최악이 피부 경로의 `0.1+2+28 ≈ 30.1초` 이므로 32초로 둔다.
  ///
  /// **여유가 2초도 안 된다.** 25초만 보고 이 값을 30 으로 "조이면" 피부 분석이
  /// 서버보다 먼저 포기한다. 서버가 32 를 전제로 28 을 잡았으므로, 줄이려면
  /// 백엔드와 같이 내려야 한다.
  ///
  /// 이 값이 서버보다 짧으면 서버는 살아서 GPT를 붙들고 있는데 앱만 포기한 상태가
  /// 되고, 사용자가 재시도를 누르면 같은 일이 반복된다. 서버보다 길되,
  /// 무제한(0)으로 두면 네트워크가 끊겼을 때 로딩 화면에서 못 빠져나온다. (PRD §17.2)
  static const Duration receiveTimeout = Duration(seconds: 32);
}
