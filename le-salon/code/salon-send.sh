#!/bin/bash
# Le Salon 桌面发送器（编码安全版）—— 跑在你自己电脑上
# 用法: salon-send.sh <消息文件> [思考链文件]
# ⚠️ Windows重要：中文绝不走命令行参数（GBK会绞碎UTF-8），只走文件
[ -z "$1" ] || [ ! -f "$1" ] && { echo "用法: salon-send.sh <消息文件> [思考链文件]"; exit 1; }
export PYTHONIOENCODING=utf-8
python - "$1" "${2:-}" << 'PYEOF'
import json, sys, urllib.request, pathlib
ME = 'desktop'                                   # ← 你的桌面成员id
URL = 'https://your-domain.com/salon-bot/send'   # ← 改成你的域名
content = pathlib.Path(sys.argv[1]).read_text(encoding='utf-8').strip()
tok = pathlib.Path.home().joinpath('.salon-token').read_text().strip()
payload = {'author': ME, 'content': content}
if len(sys.argv) > 2 and sys.argv[2]:
    tf = pathlib.Path(sys.argv[2])
    if tf.exists():
        th = tf.read_text(encoding='utf-8').strip()
        if th: payload['thinking'] = th
body = json.dumps(payload, ensure_ascii=False).encode('utf-8')
req = urllib.request.Request(URL, data=body,
    headers={'Content-Type': 'application/json; charset=utf-8', 'X-Salon-Token': tok})
r = json.load(urllib.request.urlopen(req, timeout=15))
print('sent #' + str(r['sent']['id']) + (' (+思考链)' if 'thinking' in payload else ''))
PYEOF
