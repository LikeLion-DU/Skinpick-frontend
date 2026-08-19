import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_theme.dart';

/// AI 문장 한 덩이를 담는 카드. 홈·기록·리포트가 같은 껍데기를 쓴다.
///
/// **문장은 서버가 기록을 저장할 때 만들어 둔 것이다.** 앱은 받아서 그리기만
/// 한다 — 여기서 문장을 자르거나 이어 붙이면 규칙이 두 곳에 생긴다.
///
/// 제목만 화면마다 다르다(홈 "AI 오늘의 한마디", 기록 "오늘의 AI 코멘트").
/// 그 한 단어 때문에 카드를 세 벌로 그리면 반짝임 아이콘 크기부터 어긋난다.
class AiCommentCard extends StatelessWidget {
  const AiCommentCard({
    super.key,
    required this.title,
    required this.comment,
  });

  final String title;
  final String comment;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(17, 19, 17, 19),
      decoration: BoxDecoration(
        color: AppColors.surfaceCardWarm,
        borderRadius: BorderRadius.circular(AppTheme.floatingCardRadius),
        boxShadow: const [AppTheme.floatingCardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/ai_sparkle.svg',
                width: 18.8,
                height: 18.8,
              ),
              const SizedBox(width: 5),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accentStrong,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            comment,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              height: 19 / 11,
              color: AppColors.bodyInk,
            ),
          ),
        ],
      ),
    );
  }
}
