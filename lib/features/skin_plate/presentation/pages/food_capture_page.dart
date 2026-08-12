import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/utils/photo_picker.dart';
import '../providers/plate_notifier.dart';

/// S06 — 음식 촬영.
///
/// skinAnalysisId 를 보내지 않는다. 서버가 그 사용자의 최신 피부 분석을 자동으로
/// 쓴다(PRD §14.3 ⑦). 앱이 id 를 들고 다니면 홈에서 바로 들어온 경로에서
/// 그 값이 비어 있을 때를 또 처리해야 한다.
class FoodCapturePage extends ConsumerWidget {
  const FoodCapturePage({super.key});

  Future<void> _start(
      BuildContext context, WidgetRef ref, Future<File?> Function() pick) async {
    final image = await pick();
    if (image == null || !context.mounted) return;

    unawaited(ref.read(plateNotifierProvider.notifier).create(image));
    context.push(Routes.plateResult);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('음식 촬영')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('음식이 잘 보이도록 촬영해 주세요.', textAlign: TextAlign.center),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => _start(context, ref, PhotoPicker.fromCamera),
              icon: const Icon(Icons.camera_alt),
              label: const Text('촬영하기'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _start(context, ref, PhotoPicker.fromGallery),
              icon: const Icon(Icons.photo_library),
              label: const Text('갤러리에서 선택'),
            ),
          ],
        ),
      ),
    );
  }
}
