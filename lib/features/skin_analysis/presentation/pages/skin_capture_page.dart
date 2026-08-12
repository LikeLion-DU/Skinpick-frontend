import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/utils/photo_picker.dart';
import '../providers/skin_analysis_notifier.dart';

/// S03 — 피부 촬영.
///
/// 지금은 `image_picker` 로 촬영·갤러리만 연결한다. 실시간 프리뷰와 ML Kit 얼굴
/// 게이트는 Day 5~6 작업이다(PRD §9.5). 게이트가 없어도 플로우는 끊기지 않는다 —
/// 얼굴이 아닌 사진이면 서버가 FACE_NOT_DETECTED 를 돌려주고 재촬영을 안내한다.
class SkinCapturePage extends ConsumerWidget {
  const SkinCapturePage({super.key});

  Future<void> _start(
      BuildContext context, WidgetRef ref, Future<File?> Function() pick) async {
    final image = await pick();
    if (image == null || !context.mounted) return;

    // 기다리지 않고 넘어간다. analyze 는 첫 줄에서 로딩 상태를 세우므로
    // 다음 화면이 곧바로 로딩을 보여준다.
    unawaited(ref.read(skinAnalysisNotifierProvider.notifier).analyze(image));
    context.push(Routes.skinLoading);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('피부 촬영')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '밝은 곳에서 얼굴이 정면으로 보이게 촬영해 주세요.',
              textAlign: TextAlign.center,
            ),
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
