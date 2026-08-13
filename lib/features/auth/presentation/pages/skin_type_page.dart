import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../shared/enums/skin_type.dart';
import '../providers/auth_notifier.dart';

/// S01c — 피부 타입 선택.
///
/// 이 값은 **점수 계산에 들어가지 않는다.** 자가 신고값이 점수에 개입하면
/// "같은 사진 두 번 찍어도 같은 점수"라는 주장에 사용자 입력이라는 변수가 하나 더
/// 끼어든다. 쓰이는 곳은 S05 의 갭 카드 하나뿐이다. (PRD §4.4.1)
class SkinTypePage extends ConsumerStatefulWidget {
  const SkinTypePage({super.key});

  @override
  ConsumerState<SkinTypePage> createState() => _SkinTypePageState();
}

class _SkinTypePageState extends ConsumerState<SkinTypePage> {
  SkinType? _selected;
  bool _busy = false;
  String? _error;

  Future<void> _submit() async {
    final selected = _selected;
    if (selected == null) return;

    setState(() {
      _busy = true;
      _error = null;
    });

    final failure =
        await ref.read(authNotifierProvider.notifier).updateSkinType(selected);

    if (!mounted) return;

    if (failure != null) {
      setState(() {
        _busy = false;
        _error = failure.message;
      });
      return;
    }
    context.go(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('피부 타입'),
        actions: [
          // 건너뛰기는 API 를 호출하지 않는 것이다. declared_skin_type 이 NULL 로
          // 남아야 "아직 안 정함"과 "잘 모르겠어요(UNKNOWN)"가 구분된다.
          TextButton(
            onPressed: _busy ? null : () => context.go(Routes.home),
            child: const Text('건너뛰기'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('평소 본인 피부는 어떻다고 생각하세요?',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text('오늘 측정 결과와 비교해서 알려드릴게요.'),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final type in SkinType.selectable)
                  ChoiceChip(
                    label: Text(type.label),
                    selected: _selected == type,
                    onSelected: _busy
                        ? null
                        : (_) => setState(() => _selected = type),
                  ),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const Spacer(),
            FilledButton(
              onPressed: (_busy || _selected == null) ? null : _submit,
              child: const Text('다음'),
            ),
          ],
        ),
      ),
    );
  }
}
