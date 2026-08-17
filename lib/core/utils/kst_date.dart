/// 서버는 날짜를 **KST 달력일**로만 다룬다. 앱이 기기 시간대로 "오늘"을 세면
/// UTC 기기에서 오늘 아침 기록이 어제로 잡히고, 자정 무렵에는 하루가 통째로 밀린다.
///
/// 계산을 한 곳에 둔다 — 같은 식을 화면마다 다시 쓰면 한 곳만 고쳐지는 날이 온다.
library;

/// KST 기준 오늘. **자정으로 잘라서** 돌려준다.
///
/// 자르지 않으면 그 값은 실제보다 9시간 앞선 순간이라, 자정인 다른 날짜와
/// 절대 시각으로 비교될 때 하루가 어긋난다.
DateTime todayKst() {
  final nowKst = DateTime.now().toUtc().add(const Duration(hours: 9));
  return DateTime(nowKst.year, nowKst.month, nowKst.day);
}

/// 달력일 더하기. `Duration(days: n)` 을 쓰지 않는 이유는 그것이 정확히 24n
/// 시간이라, 서머타임이 있는 시간대의 기기에서 자정이 전날 23시로 떨어지기
/// 때문이다 — 조회 구간이 하루 어긋난다.
DateTime addDays(DateTime date, int days) =>
    DateTime(date.year, date.month, date.day + days);

/// 같은 달력일인지. 시·분이 달라도 같은 날이면 true 다.
bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// 서버의 `ISO.DATE` 바인딩이 받는 형식. `toIso8601String()` 은 시각까지 붙어
/// 400 을 낸다.
String isoDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

/// 요일 한 글자. BEST DAY 카드와 그래프 축이 쓴다.
/// `DateTime.weekday` 는 월요일이 1 이다.
const _weekdayNames = ['월', '화', '수', '목', '금', '토', '일'];

String weekdayLabel(DateTime date) => _weekdayNames[date.weekday - 1];
