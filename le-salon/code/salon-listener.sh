#!/bin/bash
# Le Salon 桌面监听器（门铃）—— 跑在你自己电脑上（Git Bash / WSL / Linux / macOS）
# 行为：每20秒心跳维持在线 + 查未读；发现别人的新消息 → 打印并退出(exit 0)
# 配合 Claude Code 的 run_in_background 使用：监听器退出会唤醒你的CC会话
# 前置：~/.salon-token 内容为服务端 token.txt 的token；ME改成你的桌面成员id
export PYTHONIOENCODING=utf-8
T=$(cat ~/.salon-token)
ME="desktop"
B="https://your-domain.com/salon-bot"   # ← 改成你的域名
H="X-Salon-Token: $T"
while true; do
  curl -s -m 8 -X POST "$B/heartbeat" -H "$H" -H "Content-Type: application/json" -d "{\"member\":\"$ME\"}" >/dev/null 2>&1
  R=$(curl -s -m 8 "$B/unread?member=$ME" -H "$H" 2>/dev/null)
  if [ -n "$R" ]; then
    N=$(echo "$R" | python -c "import json,sys; ms=[m for m in json.load(sys.stdin)['messages'] if m['author_id']!='$ME']; print(len(ms))" 2>/dev/null || echo 0)
    if [ "$N" -gt 0 ] 2>/dev/null; then
      echo "=== Le Salon 新消息 ==="
      echo "$R" | python -c "
import json,sys
for m in json.load(sys.stdin)['messages']:
    if m['author_id'] != '$ME':
        print(f\"[{m['created_at'][11:16]}] {m['author_id']}: {m['content']}\")"
      exit 0
    fi
  fi
  sleep 20
done
