/// 빌드 시점에 --dart-define 으로 주입한다.
///
///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api/v1
///
/// Android 에뮬레이터의 호스트는 10.0.2.2, iOS 시뮬레이터는 localhost다.
/// 이 한 줄 때문에 반나절을 잃는 팀이 매번 나온다.
class Env {
  const Env._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080/api/v1',
  );

  /// 서버 없이 UI만 확인할 때 사용하는 로컬 목업 모드.
  static const bool mockMode = bool.fromEnvironment('MOCK_MODE');

  static const Duration connectTimeout = Duration(seconds: 10);

  /// 서버 AI 타임아웃이 25초(단발, 재시도 없음)다. 429 를 한 번 재시도하면
  /// 최악 `0.1+2+25 ≈ 27초` 이므로 32초로 둔다.
  ///
  /// 이 값이 서버보다 짧으면 서버는 살아서 GPT를 붙들고 있는데 앱만 포기한 상태가
  /// 되고, 사용자가 재시도를 누르면 같은 일이 반복된다. 서버보다 길되,
  /// 무제한(0)으로 두면 네트워크가 끊겼을 때 로딩 화면에서 못 빠져나온다.
  ///
  /// 피부 분석이 3장이 되면서 서버 타임아웃이 18 → 25초로 올라갔다. 앱을 25초로
  /// 두면 서버와 같은 값이라 앱이 먼저 포기할 수 있다. (PRD §17.2)
  static const Duration receiveTimeout = Duration(seconds: 32);
}
