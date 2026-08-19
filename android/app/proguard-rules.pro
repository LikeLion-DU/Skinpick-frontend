# ML Kit 얼굴·음식 검출을 R8 이 지우지 못하게 한다.
#
# `flutter build apk --release` 는 코드 축소를 켠다(빌드 뒤 build/app/outputs/mapping/
# 이 생기면 켜진 것이다). ML Kit 은 네이티브·리플렉션으로 묶여 있어서 keep 규칙이
# 없으면 R8 이 내부 클래스를 통째로 지우고, google_mlkit_commons 의 InputImage
# 변환이 **프레임마다** NullPointerException 을 던진다.
#
# **증상이 원인을 안 가리킨다.** skin_capture_page 의 catchError 가 그 예외를
# 삼켜서 화면에는 아무 신호가 없다 — 셔터만 꺼진 채 안내 문구가 그대로 멈춰 있어
# 자세나 조명 문제로 오진하게 된다. 디버그 빌드에서는 재현되지 않는다.
#
# 확인법: `adb logcat | grep -c ImageError` — 정상이면 0 이다.
# (2026-08-19 실측: 규칙 없는 릴리스는 15초에 50건, 디버그는 0건)
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.mlkit_** { *; }
-keep class com.google_mlkit_commons.** { *; }
-keep class com.google_mlkit_face_detection.** { *; }
-keep class com.google_mlkit_image_labeling.** { *; }

# ML Kit 이 선택적으로 참조하는 클래스들. 없어도 동작하지만 경고가 빌드를 멈춘다.
-dontwarn com.google.mlkit.**
-dontwarn com.google.android.gms.internal.mlkit_**
