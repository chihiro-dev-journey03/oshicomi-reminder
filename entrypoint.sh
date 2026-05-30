#!/bin/bash
set -e

# Rails サーバー起動時に server.pid が残っていると起動できないため削除
rm -f /app/tmp/pids/server.pid

# sidekiqコンテナでは db:migrate をスキップする
if [ -z "$SKIP_MIGRATE" ]; then
  bundle exec rails db:migrate
fi

if [ -z "$SKIP_ASSETS" ]; then
  bundle exec rails tailwindcss:build
  bundle exec rails assets:precompile
fi

exec "$@"
