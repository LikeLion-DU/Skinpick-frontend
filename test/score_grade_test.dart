import 'package:flutter_test/flutter_test.dart';
import 'package:skinplate/shared/enums/score_grade.dart';

/// 시안에 적힌 점수와 배지가 실제로 그렇게 짝지어지는지 고정한다.
/// 경계값을 나중에 조정하더라도 이 네 개는 시안에 그려진 사실이라 바뀌면 안 된다.
void main() {
  test('시안에 그려진 점수는 시안에 그려진 등급이 된다', () {
    expect(ScoreGrade.fromScore(92), ScoreGrade.good); // 연어 샐러드
    expect(ScoreGrade.fromScore(78), ScoreGrade.good); // 그릭요거트
    expect(ScoreGrade.fromScore(72), ScoreGrade.normal); // 홈 오늘의 점수
    expect(ScoreGrade.fromScore(58), ScoreGrade.caution); // 떡볶이
  });

  test('경계값에서 한 칸씩 갈린다', () {
    expect(ScoreGrade.fromScore(75), ScoreGrade.good);
    expect(ScoreGrade.fromScore(74), ScoreGrade.normal);
    expect(ScoreGrade.fromScore(60), ScoreGrade.normal);
    expect(ScoreGrade.fromScore(59), ScoreGrade.caution);
  });

  test('0 과 100 에서도 등급이 나온다 — 화면이 비지 않는다', () {
    expect(ScoreGrade.fromScore(0), ScoreGrade.caution);
    expect(ScoreGrade.fromScore(100), ScoreGrade.good);
  });
}
