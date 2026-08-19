#!/usr/bin/env bash
# 런처 아이콘 재생성. 설정은 pubspec.yaml 의 `flutter_launcher_icons:` 에 있다.
#
#   tools/gen_icons.sh
#
# 생성기를 맨손으로 부르지 마라. 0.14.4 가 뒤처리를 두 가지 남긴다.
#
#  1. `ios/Runner.xcodeproj/project.pbxproj` 에서 `ASSETCATALOG_COMPILER_` 로
#     시작하는 키를 헐겁게 치환해, 아이콘과 무관한
#     `..._GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES` 세 줄을 `= AppIcon` 으로
#     바꿔 놓는다. 그대로 두면 애셋 심볼 생성이 꺼진 채 조용히 따라 들어간다.
#  2. `Contents.json` 을 한 줄로 밀어 쓴다. 그러면 다음에 아이콘을 바꿀 때
#     diff 가 통째로 한 줄이 되어 리뷰가 불가능해진다. Xcode 도 첫 편집에서
#     어차피 다시 펼친다.
set -euo pipefail
cd "$(dirname "$0")/.."

dart run flutter_launcher_icons

git checkout ios/Runner.xcodeproj/project.pbxproj

CATALOG=ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json
python3 - "$CATALOG" <<'PY'
import json, sys, io
path = sys.argv[1]
with open(path, encoding='utf-8') as handle:
    catalog = json.load(handle)
# Xcode 서식: 2칸 들여쓰기에 콜론 양쪽 공백.
text = json.dumps(catalog, indent=2, separators=(',', ' : '), ensure_ascii=False)
io.open(path, 'w', encoding='utf-8').write(text + '\n')
PY

echo "아이콘 재생성 완료. git status 로 바뀐 파일을 확인할 것."
