import 'dart:io';

import 'package:image_picker/image_picker.dart';

/// 촬영·갤러리 선택을 한 곳에 모은다.
///
/// 리사이즈·압축을 여기서 끝내는 이유 — 업로드 용량이 1/5 로 줄고, 서버의
/// 5MB 상한에 걸릴 일이 사라진다. 최신 폰 원본은 그냥 올리면 5MB 를 넘긴다. (PRD §9.4)
///
/// **웹에서는 이 클래스를 쓸 수 없다.** `image_picker` 는 웹에서 파일 경로가 없는
/// XFile 을 돌려주고, `dart:io` 의 File 은 웹 런타임에서 던진다. 웹 경로를 붙일 때는
/// XFile 또는 바이트를 그대로 넘기는 통로를 따로 낸다. (PRD §6.1)
class PhotoPicker {
  const PhotoPicker._();

  static final ImagePicker _picker = ImagePicker();

  static const double _maxEdge = 1024;
  static const int _quality = 80;

  static Future<File?> fromCamera() => _pick(ImageSource.camera);

  /// 갤러리는 게이트를 우회하는 탈출구다. 촬영이 막히는 조명에서
  /// 사용자를 가두지 않으려면 이 경로가 항상 열려 있어야 한다. (PRD §9.5)
  static Future<File?> fromGallery() => _pick(ImageSource.gallery);

  static Future<File?> _pick(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: _maxEdge,
      maxHeight: _maxEdge,
      imageQuality: _quality,
    );
    return picked == null ? null : File(picked.path);
  }
}
