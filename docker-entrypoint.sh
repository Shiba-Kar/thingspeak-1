#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /app/tmp/pids/server.pid

# Wait for database
echo "Checking database connection..."
until ruby -r mysql2 -e "
begin
  Mysql2::Client.new(
    host: ENV['DATABASE_HOST'] || 'db',
    username: ENV['DATABASE_USERNAME'] || 'thing',
    password: ENV['DATABASE_PASSWORD'] || 'speak',
    port: (ENV['DATABASE_PORT'] || 3306).to_i
  )
  exit 0
rescue => e
  exit 1
end
" 2>/dev/null; do
  echo "Database not ready yet, sleeping 3 seconds..."
  sleep 3
done

echo "Database is ready!"

# Check if tables exist
TABLES_COUNT=$(ruby -r mysql2 -e "
begin
  client = Mysql2::Client.new(
    host: ENV['DATABASE_HOST'] || 'db',
    username: ENV['DATABASE_USERNAME'] || 'thing',
    password: ENV['DATABASE_PASSWORD'] || 'speak',
    port: (ENV['DATABASE_PORT'] || 3306).to_i,
    database: ENV['DATABASE_NAME'] || 'thingspeak_production'
  )
  puts client.query('SHOW TABLES').count
rescue => e
  puts -1
end
" 2>/dev/null)

if [ -z "$TABLES_COUNT" ] || [ "$TABLES_COUNT" -eq "-1" ]; then
  echo "Database does not exist or cannot be accessed. Creating..."
  bundle exec rake db:create || true
  echo "Loading database schema..."
  bundle exec rake db:schema:load
elif [ "$TABLES_COUNT" -eq "0" ]; then
  echo "Database is empty. Loading schema..."
  bundle exec rake db:schema:load
else
  echo "Database exists with $TABLES_COUNT tables. Running migrations..."
  bundle exec rake db:migrate
fi

exec "$@"
