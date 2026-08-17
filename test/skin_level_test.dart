import 'package:flutter_test/flutter_test.dart';
import 'package:skinplate/shared/enums/skin_level.dart';

/// 총점 등급은 **앱 전체에서 한 벌**이어야 한다.
///
/// 예전에는 앱이 75/60 경계(ScoreGrade)를 쓰고 서버는 80/60/40/20 경계를 써서,
/// 같은 68점이 홈에서는 "보통", 리포트에서는 "좋음"으로 떴다. 실기기에서 잡힌
/// 사고라 여기 경계값을 고정해 둔다.
///
/// **이 표는 서버 `SkinLevel.of(int)` 을 옮겨 온 것이다.** 서버가 경계를 바꾸면
/// 이 테스트가 먼저 깨져야 한다 — 그래야 두 곳이 조용히 갈리지 않는다.
void main() {
  group('경계값에서 한 칸씩 갈린다', () {
    test('81 부터 EXCELLENT, 80 은 아직 GOOD', () {
      expect(SkinLevel.fromScore(81), SkinLevel.excellent);
      expect(SkinLevel.fromScore(80), SkinLevel.good);
      expect(SkinLevel.fromScore(79), SkinLevel.good);
    });

    test('61 부터 GOOD, 60 은 NORMAL', () {
      expect(SkinLevel.fromScore(61), SkinLevel.good);
      expect(SkinLevel.fromScore(60), SkinLevel.normal);
      expect(SkinLevel.fromScore(59), SkinLevel.normal);
    });

    test('41 부터 NORMAL, 40 은 CAUTION', () {
      expect(SkinLevel.fromScore(41), SkinLevel.normal);
      expect(SkinLevel.fromScore(40), SkinLevel.caution);
      expect(SkinLevel.fromScore(39), SkinLevel.caution);
    });

    test('21 부터 CAUTION, 20 은 SEVERE', () {
      expect(SkinLevel.fromScore(21), SkinLevel.caution);
      expect(SkinLevel.fromScore(20), SkinLevel.severe);
      expect(SkinLevel.fromScore(19), SkinLevel.severe);
    });

    test('0 과 100 에서도 등급이 나온다 — 화면이 비지 않는다', () {
      expect(SkinLevel.fromScore(0), SkinLevel.severe);
      expect(SkinLevel.fromScore(100), SkinLevel.excellent);
    });
  });

  group('5단계를 3단계 한글 라벨로 접는다', () {
    test('EXCELLENT 와 GOOD 은 둘 다 좋음이다', () {
      expect(SkinLevel.excellent.label, '좋음');
      expect(SkinLevel.good.label, '좋음');
    });

    test('NORMAL 은 보통, CAUTION 과 SEVERE 는 주의다', () {
      expect(SkinLevel.normal.label, '보통');
      expect(SkinLevel.caution.label, '주의');
      expect(SkinLevel.severe.label, '주의');
    });

    test('같은 라벨이면 색과 표정도 같다 — 한쪽만 갈리면 화면이 거짓말을 한다', () {
      expect(SkinLevel.excellent.accentColor, SkinLevel.good.accentColor);
      expect(SkinLevel.excellent.faceIcon, SkinLevel.good.faceIcon);
      expect(SkinLevel.severe.accentColor, SkinLevel.caution.accentColor);
      expect(SkinLevel.severe.faceIcon, SkinLevel.caution.faceIcon);
    });

    test('isGood 은 좋음 구간에서만 참이다', () {
      expect(SkinLevel.excellent.isGood, isTrue);
      expect(SkinLevel.good.isGood, isTrue);
      expect(SkinLevel.normal.isGood, isFalse);
      expect(SkinLevel.caution.isGood, isFalse);
      expect(SkinLevel.severe.isGood, isFalse);
    });
  });

  group('서버가 준 등급과 점수에서 낸 등급이 같은 표를 지난다', () {
    test('리포트가 받은 grade 와 홈이 계산한 grade 가 일치한다', () {
      // 리포트는 서버가 보낸 문자열을, 홈·기록은 점수를 등급으로 바꾼다.
      // 두 경로가 같은 답을 내야 68점이 어느 화면에서나 "좋음"이다.
      const cases = <int, String>{
        92: 'EXCELLENT',
        68: 'GOOD',
        60: 'NORMAL',
        35: 'CAUTION',
        12: 'SEVERE',
      };

      for (final entry in cases.entries) {
        expect(
          SkinLevel.fromScore(entry.key),
          SkinLevel.fromJson(entry.value),
          reason: '${entry.key}점',
        );
      }
    });

    test('모르는 등급은 null 이다 — 아무 등급으로나 떨어뜨리지 않는다', () {
      expect(SkinLevel.fromJson('PERFECT'), isNull);
      expect(SkinLevel.fromJson(null), isNull);
    });
  });
}
