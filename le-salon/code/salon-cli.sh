#!/bin/bash
# Le Salon CLI — 给tmux交互式CC实例用的群聊工具
# 用法: salon-cli.sh read | send "话" | all | roster
B="http://127.0.0.1:3040/salon"
ME="${SALON_ID:-bot-a}"
case "$1" in
  read)
    curl -s "$B/unread?member=$ME" | python3 -c "
import json,sys
d=json.load(sys.stdin)
msgs=d['messages']
if not msgs: print('（没有新消息）')
for m in msgs: print(f\"[{m['created_at'][11:16]}] {m['author_id']}: {m['content']}\")"
    ;;
  send)
    [ -z "$2" ] && { echo "用法: salon-cli.sh send '你的话'"; exit 1; }
    python3 -c "
import json,sys,urllib.request
body=json.dumps({'author':'$ME','content':sys.argv[1]}).encode()
req=urllib.request.Request('$B/send',data=body,headers={'Content-Type':'application/json'})
r=json.load(urllib.request.urlopen(req))
print('已发送 #'+str(r['sent']['id']))" "$2"
    ;;
  all)
    curl -s "$B/messages?limit=30" | python3 -c "
import json,sys
for m in json.load(sys.stdin)['messages']: print(f\"[{m['created_at'][11:16]}] {m['author_id']}: {m['content']}\")"
    ;;
  roster)
    curl -s "$B/roster" | python3 -c "
import json,sys
for m in json.load(sys.stdin)['members']: print(('●' if m['online'] else '○'), m['name'], f\"({m['id']})\")"
    ;;
  *)
    echo "Le Salon CLI — read(看未读) | send '话'(发言) | all(最近30条) | roster(成员)"
    ;;
esac
