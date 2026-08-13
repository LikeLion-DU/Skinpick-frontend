import 'package:image_picker/image_picker.dart';

/// 촬영·갤러리 선택을 한 곳에 모은다.
///
/// `dart:io` 의 File 이 아니라 XFile 을 돌려준다. 웹에는 파일 경로라는 개념이 없어서
/// File 을 쓰면 컴파일은 되고 런타임에 던진다 — 그 편이 더 나쁘다.
/// XFile 은 모바일에서는 경로를, 웹에서는 blob 을 감싸고 readAsBytes() 는 양쪽에서 같다.
///
/// 리사이즈·압축을 여기서 끝내는 이유 — 업로드 용량이 1/5 로 줄고, 서버의
/// 5MB 상한에 걸릴 일이 사라진다. 최신 폰 원본은 그냥 올리면 5MB 를 넘긴다. (PRD §9.4)
class PhotoPicker {
  const PhotoPicker._();

  static final ImagePicker _picker = ImagePicker();

  static const double _maxEdge = 1024;
  static const int _quality = 80;

  /// 모바일 브라우저에서는 파일 선택 창이 곧바로 카메라를 연다.
  /// 그래서 웹에서도 이 경로로 촬영이 된다. (PRD §6.1)
  static Future<XFile?> fromCamera() => _pick(ImageSource.camera);

  /// 갤러리는 게이트를 우회하는 탈출구다. 촬영이 막히는 조명에서
  /// 사용자를 가두지 않으려면 이 경로가 항상 열려 있어야 한다. (PRD §9.5)
  static Future<XFile?> fromGallery() => _pick(ImageSource.gallery);

  static Future<XFile?> _pick(ImageSource source) => _picker.pickImage(
        source: source,
        maxWidth: _maxEdge,
        maxHeight: _maxEdge,
        imageQuality: _quality,
      );
}
