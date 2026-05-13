#!/bin/bash
set -e

# Rails サーバー起動時に server.pid が残っていると起動できないため削除
rm -f /app/tmp/pids/server.pid

bundle exec rails db:migrate

exec "$@"
