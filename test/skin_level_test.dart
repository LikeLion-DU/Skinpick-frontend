import 'dart:math' as math;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skinplate/shared/enums/skin_level.dart';

/// 총점 등급은 **앱 전체에서 한 벌**이어야 한다.
///
/// 예전에는 앱이 75/60 경계(ScoreGrade)를 쓰고 서버는 80/60/40/20 경계를 써서,
/// 같은 68점이 홈에서는 "보통", 리포트에서는 "좋음"으로 떴다. 실기기에서 잡힌
/// 사고다. 그 뒤로 앱이 서버 경계를 옮겨 적어 두었는데, 그것도 결국 표가 두 벌인
/// 것이라 **이제는 앱에 경계표가 아예 없다** — 점수를 보내는 응답이 등급도 함께
/// 보내고 앱은 그 문자열만 읽는다.
///
/// 그래서 이 파일이 지키는 것은 두 가지다. 앱이 점수에서 등급을 다시 매기지
/// 않는다는 것, 그리고 5단계를 3단계 라벨로 접는 규칙이 한 곳에만 있다는 것.
void main() {
  test('앱에는 점수→등급 표가 없다 — 서버가 매긴 것만 읽는다', () {
    // 이 테스트는 코드가 아니라 **소스**를 본다. 등급을 점수에서 내는 함수가
    // 다시 생기면(=경계표가 두 벌이 되면) 여기서 먼저 걸린다.
    final source = File('lib/shared/enums/skin_level.dart').readAsStringSync();

    expect(source, isNot(contains('fromScore')));
    for (final boundary in ['20', '40', '60', '80']) {
      expect(source, isNot(contains('score <= $boundary')),
          reason: '경계 $boundary 이 앱으로 돌아왔다');
    }
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

  group('서버 문자열을 그대로 읽는다', () {
    test('서버 enum 이름 다섯 개를 모두 안다', () {
      // 서버 SkinLevel 의 이름이다. 하나라도 못 읽으면 그 등급의 배지가 사라진다.
      for (final wire in ['SEVERE', 'CAUTION', 'NORMAL', 'GOOD', 'EXCELLENT']) {
        expect(SkinLevel.fromJson(wire), isNotNull, reason: wire);
      }
      expect(SkinLevel.values, hasLength(5));
    });

    test('모르는 등급은 null 이다 — 아무 등급으로나 떨어뜨리지 않는다', () {
      expect(SkinLevel.fromJson('PERFECT'), isNull);
      expect(SkinLevel.fromJson(null), isNull);
    });
  });

  group('상태 칩 글자 — 저시력 사용자가 읽을 수 있어야 한다', () {
    /// WCAG 상대 휘도.
    double luminance(Color color) {
      double channel(double raw) => raw <= 0.03928
          ? raw / 12.92
          : math.pow((raw + 0.055) / 1.055, 2.4).toDouble();
      return 0.2126 * channel(color.r) +
          0.7152 * channel(color.g) +
          0.0722 * channel(color.b);
    }

    double contrast(Color a, Color b) {
      final high = math.max(luminance(a), luminance(b));
      final low = math.min(luminance(a), luminance(b));
      return (high + 0.05) / (low + 0.05);
    }

    test('칩 글자가 배경 대비 4.5:1 을 넘는다', () {
      // 등급을 글자로 읽으라고 넣은 칩이다. 12px w600 은 "큰 글자"가 아니라
      // AA 기준이 4.5:1 이고, accentColor 를 그대로 쓰면 1.9~3.2:1 밖에 안 나온다.
      for (final level in SkinLevel.values) {
        expect(
          contrast(level.chipTextColor, level.tintColor),
          greaterThanOrEqualTo(4.5),
          reason: '${level.name} 칩 글자가 배경에 묻힌다',
        );
      }
    });

    test('등급마다 배경이 다르다 — 두 벌로 접으면 보통과 주의가 같아진다', () {
      final tints = {for (final level in SkinLevel.values) level.label: level.tintColor};

      expect(tints.values.toSet(), hasLength(tints.length),
          reason: '접힌 등급끼리 배경이 같으면 칩이 등급을 구분하지 못한다');
    });
  });
}
