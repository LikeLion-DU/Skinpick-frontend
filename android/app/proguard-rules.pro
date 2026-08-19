# ML Kit 을 릴리스 축소(R8)에서 지킨다.
#
# 증상: 릴리스 빌드에서만 얼굴 검출이 0개 — 화면은 멀쩡한데 프레임마다
# `E ImageError: Getting Image failed (NullPointerException)` 이 남는다.
# 디버그에서는 같은 코드·같은 기기(갤럭시 S25)에서 정상이라 코드에서 원인을
# 찾게 되는 종류의 실패다 (2026-08-19 실기기 로그로 확인).
#
# 원인: R8 이 ML Kit 계열 클래스를 지우거나 이름을 바꾸면서 플러그인의
# InputImage 변환이 깨진다. 얼굴 게이트와 음식 라벨링이 같이 죽는다.
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.odml.image.** { *; }
# usage.txt(릴리스 mapping 산출물)에서 실제로 깎인 것으로 확인된 패키지.
-keep class com.google.android.gms.internal.mlkit_common.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_face.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_common.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_image_labeling.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_image_labeling_bundled.** { *; }

# Flutter 플러그인 브리지(자바 쪽). 메서드 채널로 받은 맵을 InputImage 로
# 바꾸는 변환기가 여기 있다 — 위 로그의 NPE 가 이 안에서 났다.
-keep class com.google_mlkit_commons.** { *; }
-keep class com.google_mlkit_face_detection.** { *; }
-keep class com.google_mlkit_image_labeling.** { *; }
