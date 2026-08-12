import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 401 을 만났다는 사실만 전달하는 신호.
///
/// 인터셉터가 AuthNotifier 를 직접 부르면 프로바이더 의존이
/// DioClient → AuthNotifier → AuthRepository → DioClient 로 순환한다.
/// 신호를 아무것도 의존하지 않는 잎 노드로 빼서 그 고리를 끊는다.
class UnauthorizedSignal extends Notifier<int> {
  @override
  int build() => 0;

  void fire() => state = state + 1;
}

final unauthorizedSignalProvider =
    NotifierProvider<UnauthorizedSignal, int>(UnauthorizedSignal.new);
