import 'dart:io';

import '../../../../core/result/result.dart';
import '../entities/skin_analysis.dart';

abstract interface class SkinRepository {
  /// 얼굴 사진을 업로드하고 분석 결과를 받는다. (multipart)
  Future<Result<SkinAnalysis>> analyze(File image);

  /// 홈 화면(S02)의 "오늘의 Skin Score" 카드용. 없으면 Success(null).
  Future<Result<SkinAnalysis?>> getLatest();

  Future<Result<SkinAnalysis>> getById(int id);
}
