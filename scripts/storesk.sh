#!/usr/bin/env bash

# Required variables
# set these from the command line:
# export RENDER_API_KEY=<key>
# export RENDER_SERVICE_ID=<id> # from 'render services list' output
RENDER_API_KEY="${RENDER_API_KEY:?Missing RENDER_API_KEY}"
RENDER_SERVICE_ID="${RENDER_SERVICE_ID:?Missing RENDER_SERVICE_ID}"

# 1. Generate Django SECRET_KEY
SECRET_KEY=$(python -c 'import secrets; print("".join([secrets.choice("abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*(-_=+)") for _ in range(50)]))')

# 2. Fetch current env vars
ENV_VARS=$(curl -s -H "Authorization: Bearer $RENDER_API_KEY" \
  -H "Accept: application/json" \
  "https://api.render.com/v1/services/$RENDER_SERVICE_ID/env-vars")

# 3. Add or replace DJANGO_SECRET_KEY
UPDATED_ENV_VARS=$(echo "$ENV_VARS" | jq \
  --arg key "DJANGO_SECRET_KEY" \
  --arg value "$SECRET_KEY" \
  'map(select(.key != $key)) + [{ key: $key, value: $value }]')

# 4. Send PATCH to update env vars
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
  -X PATCH "https://api.render.com/v1/services/$RENDER_SERVICE_ID/env-vars" \
  -H "Authorization: Bearer $RENDER_API_KEY" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d "$UPDATED_ENV_VARS")

# 5. Check result
if [[ "$RESPONSE" == "200" ]]; then
  echo "✅ DJANGO_SECRET_KEY successfully set."
else
  echo "❌ Failed to update env vars. HTTP status: $RESPONSE"
  echo "Data sent:"
  echo "$UPDATED_ENV_VARS" | jq
fi


curl -s -H "Authorization: Bearer $RENDER_API_KEY" \
     -H "Accept: application/json" \
     https://api.render.com/v1/services/$RENDER_SERVICE_ID/env-vars | jq
