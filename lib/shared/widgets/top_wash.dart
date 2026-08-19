import 'package:flutter/material.dart';

/// 화면 위쪽에 옅게 깔리는 오렌지 물. 마이페이지 · 리포트 · 피부 결과가 쓴다.
///
/// 홈의 히어로([HeroWash])와 다르다 — 저쪽은 단색 오렌지 위에 흰 글자를 얹고,
/// 이쪽은 **검은 글자 뒤에 깔리는 배경**이라 알파가 0.16 까지만 올라간다.
///
/// 시안은 이 판을 프레임보다 174~191 위에서 시작해 379~396 높이로 깔고 68.5% 에서
/// 투명해진다. 화면에 보이는 구간만 옮기면 시작 알파가 0.5 가 아니라 0.16 이다.
/// 세 화면의 값이 미세하게 다른데(시작 위치 17px 차이) 한 벌로 맞춘다 —
/// 화면을 넘길 때 같은 물이 다른 진하기로 보이면 그게 더 눈에 띈다.
///
/// **`Stack` 안에서만 쓴다.** `Positioned` 를 돌려주므로 다른 곳에 넣으면
/// 런타임에 죽는다.
class TopWash extends StatelessWidget {
  const TopWash({super.key});

  @override
  Widget build(BuildContext context) {
    return const Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 205,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x2AFF7D40), Color(0x00FF7D40)],
            stops: [0, 0.42],
          ),
        ),
        child: SizedBox.expand(),
      ),
    );
  }
}
