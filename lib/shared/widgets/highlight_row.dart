import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../features/skin_analysis/domain/entities/skin_analysis.dart';
import '../enums/highlight_status.dart';

/// 피부 요약 하이라이트 한 줄. 서버가 만든 `label` 을 그대로 쓴다.
///
/// 피부 결과 화면(S05)과 음식 결과 화면(S07)이 같이 쓴다. 음식 점수의 근거를
/// 보여 주는 자리라 두 화면이 같은 문장을 같은 색으로 그려야 한다.
///
/// 모르는 상태값은 파서가 [HighlightStatus.warn] 으로 떨어뜨린다. 여기서 색을
/// 초록으로 주면 그 낙하가 "괜찮다"로 뒤집힌다 — 주의색을 유지한다.
class HighlightRow extends StatelessWidget {
  const HighlightRow({super.key, required this.highlight});

  final Highlight highlight;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (highlight.status) {
      HighlightStatus.good => (AppColors.good, Icons.check_circle),
      HighlightStatus.warn => (AppColors.caution, Icons.info),
      HighlightStatus.caution => (AppColors.bad, Icons.warning),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              highlight.label,
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFF494949), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
