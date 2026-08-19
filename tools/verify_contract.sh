#!/usr/bin/env bash
# 배포 후 계약 검증. 새 필드가 실제로 오는지 실서버 응답으로 확인한다.
#
#   tools/verify_contract.sh                      # 배포 서버
#   BASE=http://localhost:8080/api/v1 tools/...   # 로컬 서버
#
# 픽스처를 다시 뜨려면 이 스크립트가 저장한 /tmp/skinplate-contract/*.json 을
# test/fixtures/*_live.json 으로 옮긴다.
set -euo pipefail

BASE="${BASE:-https://1-201-116-157.sslip.io/api/v1}"
EMAIL="${EMAIL:-test@skinplate.app}"
PASSWORD="${PASSWORD:-test1234!}"
OUT=/tmp/skinplate-contract
mkdir -p "$OUT"

TOKEN=$(curl -s -m 20 -X POST "$BASE/auth/login" -H 'Content-Type: application/json' \
  -d "{\"email\":\"$EMAIL\",\"password\":\"$PASSWORD\"}" \
  | python3 -c 'import sys,json; print(json.load(sys.stdin)["data"]["accessToken"])')

get() { curl -s -m 25 "$BASE$1" -H "Authorization: Bearer $TOKEN" -o "$OUT/$2.json"; }

TO=$(python3 -c 'import datetime; print(datetime.date.today())')
FROM=$(python3 -c 'import datetime; print(datetime.date.today() - datetime.timedelta(days=13))')

get "/skin/analyses/latest"                  skin
get "/plates?from=$FROM&to=$TO"              plates
get "/reports/weekly?from=$FROM&to=$TO"      weekly
get "/auth/me"                               me

# 일일 리포트는 **기록이 있는 날**로 물어야 한다. 오늘이 빈 날이면 배열이 전부
# 비어서 계약 누락과 구분되지 않는다 — 새 필드가 안 오는 것과 값이 없는 것은 다르다.
RECORDED=$(python3 - "$OUT" <<'PY2'
import json, pathlib, sys
days = (json.loads((pathlib.Path(sys.argv[1]) / 'plates.json').read_text())
        .get('data') or {}).get('days') or []
print(max((day['date'] for day in days), default=''))
PY2
)
if [ -z "$RECORDED" ]; then
  echo "  기록이 하나도 없어 일일 리포트를 검증할 수 없다 — 한 끼 저장 후 다시 돌린다."
  exit 2
fi
echo "  일일 리포트 기준일: $RECORDED"
get "/reports/daily?date=$RECORDED"          daily

python3 - "$OUT" <<'PY'
import json, sys, pathlib

out = pathlib.Path(sys.argv[1])
def data(name):
    body = json.loads((out / f'{name}.json').read_text())
    return body.get('data') or {}

rows = []
def check(label, ok, detail=''):
    rows.append((label, ok, detail))

skin = data('skin')
check('skin.grade', skin.get('grade') is not None, str(skin.get('grade')))
check('skin.careFocus[]', bool(skin.get('careFocus')),
      ','.join(f['label'] for f in skin.get('careFocus') or []))
check('skin.careMessage', bool(skin.get('careMessage')))
check('skin.metricDetails[].level',
      all(m.get('level') for m in skin.get('metricDetails') or [{}]))

days = data('plates').get('days') or []
day = days[0] if days else {}
plate = (day.get('plates') or [{}])[0]
check('plates day.grade', day.get('grade') is not None, str(day.get('grade')))
check('plates plate.grade', plate.get('grade') is not None, str(plate.get('grade')))
check('plates highlightTags[]', 'highlightTags' in plate,
      ','.join(plate.get('highlightTags') or []))

daily = data('daily')
nutrients = daily.get('skinNutrients') or []
check('daily.skinNutrients[3]', len(nutrients) == 3,
      ','.join(n['label'] for n in nutrients))
concerns = daily.get('concerns') or [{}]
check('daily concern.message', any(c.get('message') for c in concerns))
check('daily concern.tags[]', any(c.get('tags') for c in concerns))
meals = daily.get('meals') or [{}]
check('daily meal.grade', all(m.get('grade') for m in meals))
check('daily meal.highlightTags[]', any('highlightTags' in m for m in meals))

weekly = data('weekly')
best, worst = weekly.get('bestDay') or {}, weekly.get('worstDay') or {}
check('weekly bestDay.plateIds[]', bool(best.get('plateIds')), str(best.get('plateIds')))
check('weekly worstDay.plateIds[]', bool(worst.get('plateIds')), str(worst.get('plateIds')))
trend = (weekly.get('dailyScores') or [{}])[0]
check('weekly 추이엔 plateIds 없음', 'plateIds' not in trend)

check('me.declaredSkinType 읽힘', 'skinConcerns' in data('me'))

width = max(len(r[0]) for r in rows)
failed = 0
for label, ok, detail in rows:
    mark = 'PASS' if ok else 'FAIL'
    failed += 0 if ok else 1
    print(f'  {mark}  {label.ljust(width)}  {detail}')
print()
print(f'  {len(rows) - failed}/{len(rows)} 통과' + ('' if not failed else f' — {failed}건 실패'))
sys.exit(1 if failed else 0)
PY
