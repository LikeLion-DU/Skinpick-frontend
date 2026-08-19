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

# **패키지를 열거하지 않는다.** 처음에는 usage.txt 에서 읽은 이름을 하나씩 적었는데
# 두 군데가 빗나갔다. `mlkit_vision_image_labeling` 은 **존재하지 않는 패키지**여서
# (실제 이름은 `mlkit_vision_label_*`) 규칙이 0개에 매치됐고 음식 라벨링은 그대로
# 깎이고 있었다. `mlkit_vision_face.**` 는 `.**` 가 뒤에 점을 요구해서 형제인
# `mlkit_vision_face_bundled` 를 못 잡았다 — 이 앱이 쓰는 것이 그 번들 모델이다.
#
# `_**` 는 언더스코어 변형까지 덮어서 mlkit_common · vision_face · face_bundled ·
# vision_common · label_bundled · label_custom_bundled · internal_vkp · linkfirebase
# 가 한 줄에 들어온다. 플러그인이 내부 패키지 이름을 바꿔도 따라간다.
-keep class com.google.android.gms.internal.mlkit_** { *; }
-keep class com.google.android.libraries.vision.** { *; }
-keep class com.google.android.gms.vision.** { *; }

# Flutter 플러그인 브리지(자바 쪽). 메서드 채널로 받은 맵을 InputImage 로
# 바꾸는 변환기가 여기 있다 — 위 로그의 NPE 가 이 안에서 났다.
-keep class com.google_mlkit_commons.** { *; }
-keep class com.google_mlkit_face_detection.** { *; }
-keep class com.google_mlkit_image_labeling.** { *; }

# keep 범위를 넓히면 선택적 의존성의 미해결 참조가 딸려 온다. R8 full mode 는
# 그걸 경고가 아니라 빌드 실패로 처리한다.
-dontwarn com.google.mlkit.**
-dontwarn com.google.android.gms.internal.mlkit_**
