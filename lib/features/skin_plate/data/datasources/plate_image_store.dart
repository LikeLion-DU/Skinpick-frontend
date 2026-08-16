import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

/// 기록된 음식 사진을 **기기 안에만** 남긴다. 서버·CDN 에 올리지 않는다.
///
/// 저장 시점은 `POST /plates/records` 가 201 을 준 **뒤**다. 분석만 하고 나간 사진은
/// 디스크에 남지 않는다.
///
/// 수명 — 앱을 다시 켜도 남고, 앱을 지우면 같이 사라지고, 기기를 바꾸면 따라가지
/// 않는다. 캐시 디렉터리가 아니라 documents 를 쓰는 이유가 첫 번째다.
///
/// ponytail: 지우는 길은 [delete] 하나다 — 기록을 삭제할 때만 부른다. 오래된 파일을
/// 주기적으로 걷어내는 것은 없다. 하루 세 끼면 1년에 1000장쯤이라 아직 문제가 아니고,
/// 계정 전환이 잦아지거나 용량이 걸리면 그때 청소를 붙인다.
///
/// ponytail: `dart:io` 라 웹에서는 컴파일되지 않는다. 이 저장소에는 아직 `web/` 이
/// 없어서 지금 깨지는 것은 없다. 웹을 켤 때는 face_gate 처럼 조건부 import 로
/// 스텁을 물려야 한다 — 저장이 안 되는 것뿐이라 화면은 아이콘으로 떨어진다.
class PlateImageStore {
  const PlateImageStore._();

  /// 사진이 없으면 화면이 음식 아이콘으로 대체한다. 여기서 예외를 던지지 않는다.
  static Future<Directory> directory() async {
    final documents = await getApplicationDocumentsDirectory();
    final plates = Directory('${documents.path}/plates');
    // 동기 API 를 쓰면 저장 버튼을 누른 직후 UI 스레드가 파일시스템을 기다린다.
    if (!await plates.exists()) await plates.create(recursive: true);
    return plates;
  }

  /// ponytail: 파일명이 서버 `plateId` 뿐이라 계정이나 백엔드 환경이 바뀌면
  /// 어긋난다 — DB 를 초기화해 id 가 1부터 다시 매겨지면 예전 끼니의 사진이 새
  /// 기록 옆에 붙는다. 사용자 단위로 디렉터리를 나누면(`plates/{userId}/`) 계정
  /// 전환은 막히지만 DB 초기화는 여전하다. 시연 계정 하나로 쓰는 동안은 겪지 않고,
  /// 겪는 순간이 오면 그때는 앱 데이터를 지우는 게 더 빠르다.
  static File fileFor(Directory directory, int plateId) =>
      File('${directory.path}/$plateId.jpg');

  /// JPEG 로 변환해서 쓴다.
  ///
  /// 확장자만 `.jpg` 로 붙이면 내용과 어긋난다 — 갤러리에서 온 사진은 원본 포맷이고,
  /// image_picker 의 `imageQuality` 도 JPEG 를 보장하지 않는다(알파 채널이 있으면
  /// PNG 로 압축한다). 이미 있는 flutter_image_compress 로 네이티브 인코딩한다.
  /// 순수 Dart 인코더를 쓰면 저장 버튼을 누른 직후 메인 아이솔레이트가 멈춘다.
  ///
  /// **실패해도 기록은 유지한다.** 서버 저장(201)이 끝난 뒤라 되돌릴 방법이 없고,
  /// "저장 실패"라고 안내하면 서버에는 기록이 남아 있는 모순이 된다. 재시도도 하지
  /// 않는다 — 원인이 대개 디스크 부족이라 다시 해도 같고, 히스토리는 음식명·점수·
  /// 시각으로 이미 완결돼 있다.
  static Future<bool> save(int plateId, Uint8List bytes) async {
    try {
      final jpeg = await FlutterImageCompress.compressWithList(
        bytes,
        // 상한이지 강제 리사이즈가 아니다. 플러그인은 `min(w/minWidth, h/minHeight)`
        // 가 1 이하면 원본 크기를 유지한다 — 지금 촬영 해상도(1280x720·PhotoPicker
        // 1024)에서는 아무것도 줄이지 않고 포맷만 바꾼다. 프리셋을 올리면 그때부터
        // 여기서 줄어든다.
        minWidth: 1024,
        minHeight: 1024,
        quality: 85,
        format: CompressFormat.jpeg,
      );
      // 이 플러그인은 실패를 예외가 아니라 빈 리스트로 돌려줄 때가 있다.
      // 그대로 쓰면 0바이트 .jpg 가 남아 히스토리에 깨진 이미지가 뜬다.
      if (jpeg.isEmpty) return false;

      await fileFor(await directory(), plateId).writeAsBytes(jpeg, flush: true);
      return true;
    } on Object catch (_) {
      return false;
    }
  }

  /// 기록을 지울 때 사진도 같이 지운다.
  ///
  /// **실패해도 삼킨다.** 서버 기록은 이미 사라졌으므로 여기서 오류를 올리면
  /// "삭제 실패"라고 안내하면서 목록에서는 사라진 모순이 된다. 남은 파일은
  /// 아무 화면도 참조하지 않는 고아라 다음 설치까지 조용히 자리만 차지한다.
  static Future<void> delete(int plateId) async {
    try {
      final file = fileFor(await directory(), plateId);
      if (await file.exists()) await file.delete();
    } on Object catch (_) {
      // 무시한다 — 위 주석 참고.
    }
  }
}
