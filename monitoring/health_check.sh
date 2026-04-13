#!/bin/bash

# Configuration
URL="https://bucheongoyangijanggun.com"
WEBHOOK_URL="https://discord.com/api/webhooks/1493060974716915734/9YV8NT_P4XpmyrlLmEKuou4_s-xtc7-RRz1qxAtFMN_CXKIU8IWURbOvrDcX2Y0him0M"

# Check the site status
HTTP_STATUS=$(curl -o /dev/null -s -w "%{http_code}" "$URL")

if [ "$HTTP_STATUS" -ne 200 ]; then
  echo "Site is DOWN (HTTP $HTTP_STATUS). Sending alert..."
  
  # Prepare Discord message
  MESSAGE="🚨 **부천 고양이 장군 서버 다운 알림** 🚨\nURL: $URL\n상태: $HTTP_STATUS\n시간: $(date)"
  
  # Send to Discord
  curl -H "Content-Type: application/json"        -X POST        -d "{\"content\": \"$MESSAGE\"}"        "$WEBHOOK_URL"
else
  echo "Site is UP (HTTP $HTTP_STATUS)."
fi
