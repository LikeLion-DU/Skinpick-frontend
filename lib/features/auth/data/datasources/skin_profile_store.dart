import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/entities/skin_profile.dart';

/// 설문(고민·생활 습관)의 기기 저장소.
///
/// 서버에 컬럼이 없어서 여기 둔다. secure storage 를 쓰는 이유는 새 의존성을
/// 들이지 않기 위해서다 — 토큰 저장에 이미 쓰고 있다. 백엔드 필드가 생기면
/// 이 파일이 통째로 원격 저장으로 바뀐다.
///
/// 실패는 전부 삼킨다. 설문 저장이 안 됐다고 온보딩을 막으면, 부가 정보가
/// 핵심 흐름을 인질로 잡는 꼴이 된다.
class SkinProfileStore {
  const SkinProfileStore(this._storage);

  final FlutterSecureStorage _storage;

  static const _key = 'skin_profile.v1';

  Future<void> save(SkinProfile profile) async {
    try {
      await _storage.write(key: _key, value: jsonEncode(profile.toJson()));
    } on Object catch (_) {}
  }

  Future<SkinProfile> load() async {
    try {
      final raw = await _storage.read(key: _key);
      if (raw == null) return const SkinProfile();
      return SkinProfile.fromJson(jsonDecode(raw) as Map<String, Object?>);
    } on Object catch (_) {
      return const SkinProfile();
    }
  }
}
