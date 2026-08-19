import 'package:flutter_test/flutter_test.dart';
import 'package:skinplate/core/utils/kst_date.dart';

void main() {
  group('mondayOf — 주간 리포트의 주 경계가 이 함수 하나로 정해진다', () {
    test('주중 어느 날이든 같은 주의 월요일로 온다', () {
      // 2026-08-19 는 수요일이다.
      expect(mondayOf(DateTime(2026, 8, 19)), DateTime(2026, 8, 17));
      expect(mondayOf(DateTime(2026, 8, 17)), DateTime(2026, 8, 17));
    });

    test('일요일은 다음 주가 아니라 그 주의 월요일이다', () {
      // weekday 가 7 이라 뺄셈을 틀리면 하루 뒤(다음 월요일)로 넘어간다 —
      // 일요일 저녁에 연 주간 리포트가 텅 빈 다음 주를 보여주게 된다.
      expect(mondayOf(DateTime(2026, 8, 23)), DateTime(2026, 8, 17));
    });

    test('월·연 경계를 넘어도 달력일로 계산된다', () {
      // 2026-01-01 은 목요일 — 월요일은 지난해 12월이다.
      expect(mondayOf(DateTime(2026, 1, 1)), DateTime(2025, 12, 29));
    });
  });
}
