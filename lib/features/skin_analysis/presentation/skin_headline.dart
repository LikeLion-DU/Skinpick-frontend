import '../../../shared/enums/skin_type.dart';
import '../domain/entities/skin_analysis.dart';

/// 분석 하나의 제목. **결과(S05)와 인사이트(S10)가 같이 쓴다.**
///
/// 한쪽만 서버 문구를 보고 다른 쪽이 폴백까지 보면, 같은 분석이 한 탭 건너 다른
/// 이름으로 뜬다 — `label` 은 비어 올 수 있다고 계약에 적혀 있어서 상상이 아니다.
///
/// 서버 문구가 1순위다. 타입만이 아니라 오늘의 상태까지 조합돼 있어서
/// ("건성 · 붉은기") 앱이 더 얹을 것이 없다.
///
/// 문구가 없을 때만 타입 하나로 떨어진다. 그 타입도 세 군데를 순서대로 본다.
///
/// **`skinType` 이 없어서 뒤로 넘어가는 일은 지금은 없다** — 서버가 AI 원본이 아니라
/// 저장된 지표에서 매번 다시 만들어서 확장 필드가 없던 옛 기록에도 온다. 그래도
/// 체인을 남긴다. 계약이 바뀌었다고 옛 기록을 여는 순간 제목이 비어서는 안 된다.
/// 뒤 두 칸도 빌 수 있다 — 갭 카드는 사용자가 타입을 건너뛰면 없고, 자가 신고도
/// 마찬가지다. 그래서 마지막에 '오늘의 피부' 가 있다.
///
/// 폴백에만 '피부' 를 붙인다. 타입 하나면 "건성" 보다 "건성 피부" 가 제목처럼 읽힌다.
/// 서버 문구에는 붙이지 않는다 — 괄호로 끝나는 것이 있어 "…(수부지) 피부" 로 깨진다.
String skinHeadline(SkinAnalysis analysis, SkinType? declaredType) {
  final label = analysis.skinType?.label ?? '';
  if (label.isNotEmpty) return label;

  final type = analysis.skinType?.primary ??
      analysis.skinTypeGap?.observed ??
      declaredType;

  return type == null ? '오늘의 피부' : '${type.label} 피부';
}
