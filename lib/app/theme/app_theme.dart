import 'package:flutter/material.dart';

/// Material 3 seed 컬러 하나로 팔레트를 만든다.
/// PD 와이어프레임이 나오기 전까지 색을 손으로 정하지 않는다 —
/// 지금 정한 값은 어차피 전부 바뀐다.
class AppTheme {
  const AppTheme._();

  static const seed = Color(0xFF3DDC97);

  static ThemeData get light => ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        useMaterial3: true,
      );
}
