import '../../../../core/result/result.dart';
import '../entities/skin_analysis.dart';
import '../entities/skin_insight.dart';
import '../entities/skin_photo_set.dart';

abstract interface class SkinRepository {
  /// 얼굴 사진 세 장을 한 요청으로 올리고 분석 결과 하나를 받는다. (multipart)
  Future<Result<SkinAnalysis>> analyze(SkinPhotoSet photos);

  /// 홈 화면(S02)의 "오늘의 Skin Score" 카드용. 없으면 Success(null).
  Future<Result<SkinAnalysis?>> getLatest();

  Future<Result<SkinAnalysis>> getById(int id);

  /// 개인화 인사이트(S10). 없으면 서버가 그 자리에서 만들어 준다(get-or-create).
  /// 첫 호출은 AI 를 기다리므로 오래 걸린다.
  Future<Result<SkinInsight>> getInsight(int skinAnalysisId);
}
