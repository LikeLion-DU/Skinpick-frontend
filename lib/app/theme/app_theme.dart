import 'package:flutter/material.dart';

import 'app_colors.dart';

/// 시안이 라이트 한 벌뿐이라 다크 테마를 만들지 않는다.
/// 다크를 흉내내면 색 대비를 우리가 지어내게 되고, 그건 디자인이 아니다.
class AppTheme {
  const AppTheme._();

  /// pubspec 의 family 이름과 반드시 같아야 한다. 오타가 나도 앱은 죽지 않고
  /// 조용히 시스템 폰트로 떨어지므로, 문자열을 여기 한 번만 적는다.
  static const fontFamily = 'Pretendard';

  /// 시안의 버튼·입력창 모서리가 전부 같은 곡률이다.
  static const _radius = 8.0;

  /// 시안 프레임에서 읽은 값. 카드가 버튼보다 아주 조금 더 둥글다.
  static const cardRadius = 9.0;

  /// 오렌지 히어로 위에 떠 있는 카드. 곡률이 훨씬 크고 그림자를 쓴다.
  ///
  /// [cardRadius] 와 합치지 않는다 — 흰 배경 위 카드는 테두리로 면을 나누고
  /// 히어로 위 카드는 그림자로 뜬다. 곡률까지 같게 하면 뜬 느낌이 사라진다.
  static const floatingCardRadius = 24.0;

  /// 히어로 위 카드의 그림자. 시안 값 `0 0 15.3 rgba(0,0,0,0.25)` 그대로다.
  static const floatingCardShadow = BoxShadow(
    color: Color(0x40000000),
    blurRadius: 15.3,
  );

  /// 오렌지 히어로 위 흰 글자에 붙는 번짐. 시안이 모든 히어로 텍스트에 건다 —
  /// 그라디언트가 아래로 밝아지는 구간에서 흰 글자가 배경에 묻히는 것을 막는다.
  static const heroTextShadow = Shadow(
    color: Color(0xFFFF4D00),
    blurRadius: 13.6,
  );

  /// 화면 좌우 여백. 시안은 제목이 32, 카드가 34 로 2px 어긋나 있는데
  /// 의도로 보기 어려워 32 로 맞춘다. 지적이 나오면 이 값만 바꾸면 된다.
  static const pagePadding = 32.0;

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      // fromSeed 가 만든 조합색은 시안과 다르다. 화면에 실제로 쓰이는
      // 자리만 골라 시안 값으로 덮는다. 나머지는 Material 기본값으로 둬도
      // 눈에 띄지 않는다 — 덮지 않은 색이 보이면 그건 시안에 없는 UI 다.
      primary: AppColors.primary,
      surface: AppColors.background,
      error: AppColors.bad,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      // 여기 한 줄이 앱 전체의 폰트를 정한다. 화면마다 fontFamily 를 적지 마라 —
      // 하나라도 빠뜨리면 그 화면만 시스템 폰트로 나오고, 한글은 그 차이가 크다.
      fontFamily: fontFamily,
      // 크기·굵기는 시안 프레임에서 읽은 값이다. 시안이 Bold 보다 SemiBold 를
      // 훨씬 자주 쓴다 — 제목까지 SemiBold 다.
      textTheme: const TextTheme(
        // 화면 제목. "안녕하세요, 스킨픽님"
        titleLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        // 구역 제목. "오늘의 기록"
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        // 제목 아래 안내 문구
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
        // 카드 안쪽 보조 문구
        bodySmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w400,
          color: AppColors.textOnCard,
          height: 1.35,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          // 조건을 못 채운 버튼은 시안에서 회색으로 잠겨 있다. 이걸 테마에
          // 두지 않으면 화면마다 disabled 색을 따로 칠하다가 서로 달라진다.
          disabledBackgroundColor: AppColors.disabled,
          disabledForegroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.background,
        // 시안이 힌트와 테두리에 회색 계단(Gray-mid · Gray-Light)을 쓴다.
        // 예전 `outline`(#898888)은 테두리가 너무 진해 입력창이 눌린 것처럼 보였다.
        hintStyle: const TextStyle(color: AppColors.grayMid, fontSize: 15),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: const BorderSide(color: AppColors.grayLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: const BorderSide(color: AppColors.grayLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
