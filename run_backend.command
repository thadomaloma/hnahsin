#!/bin/bash

set -Eeuo pipefail

project_dir="$(cd "$(dirname "$0")" && pwd)"
backend_dir="$project_dir/backend"
run_mode="${1:-run}"
log_file="$project_dir/thumal_quest_backend.log"
diagnostic_file="$project_dir/thumal_quest_backend_diagnostics.txt"

# Finder-launched Terminal windows may lack Homebrew paths. Append them so an
# active Ruby (mise, rbenv, asdf) keeps priority: vendored native gems are built
# against it and fail to load under a different Ruby build.
for candidate_path in /opt/homebrew/bin /usr/local/bin; do
  case ":$PATH:" in *":$candidate_path:"*) ;; *) [ -d "$candidate_path" ] && PATH="$PATH:$candidate_path" ;; esac
done

if ! ruby -e 'exit Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("3.3.0")' >/dev/null 2>&1; then
  for candidate_path in /opt/homebrew/opt/ruby/bin /usr/local/opt/ruby/bin; do
    if [ -d "$candidate_path" ]; then PATH="$candidate_path:$PATH"; fi
  done
fi

for candidate_path in /opt/homebrew/opt/postgresql@16/bin /usr/local/opt/postgresql@16/bin; do
  if [ -d "$candidate_path" ]; then PATH="$candidate_path:$PATH"; fi
done
export PATH

exec > >(tee "$log_file") 2>&1

fail_with_help() {
  message="$1"
  {
    echo "Hnahsin Editorial Studio diagnostic"
    echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "Mode: $run_mode"
    echo "Ruby: $(ruby --version 2>/dev/null || echo unavailable)"
    echo "Bundler: $(bundle --version 2>/dev/null || echo unavailable)"
    echo "PostgreSQL: $(pg_isready 2>/dev/null || echo unavailable)"
    echo "Failure: $message"
  } > "$diagnostic_file"
  echo ""
  echo "ERROR: $message"
  echo "Diagnostic file: $diagnostic_file"
  exit 1
}

case "$run_mode" in
  run|check|doctor|setup|staging-report) ;;
  *) fail_with_help "Mode hriat loh: $run_mode (run, check, doctor, setup, staging-report)." ;;
esac

echo "Hnahsin — Phase 4C Staging Validation"
echo "=========================================="

command -v ruby >/dev/null 2>&1 || fail_with_help "Ruby 3.3+ install hmasa rawh: brew install ruby"
ruby -e 'abort "Ruby 3.3+ is required" if Gem::Version.new(RUBY_VERSION) < Gem::Version.new("3.3.0")' || fail_with_help "Ruby 3.3+ is required."
command -v bundle >/dev/null 2>&1 || fail_with_help "Bundler install rawh: gem install bundler"

echo "Ruby: $(ruby --version)"
echo "Bundler: $(bundle --version)"

if [ "$run_mode" = "staging-report" ]; then
  cd "$project_dir"
  python3 scripts/phase4c_staging_gate.py
  exit 0
fi

if [ "$run_mode" = "doctor" ]; then
  command -v psql >/dev/null 2>&1 && psql --version || true
  command -v pg_isready >/dev/null 2>&1 && pg_isready || true
  exit 0
fi

cd "$backend_dir"
bundle check || bundle install

if [ -z "${DATABASE_URL:-}" ]; then
  command -v pg_isready >/dev/null 2>&1 || fail_with_help "PostgreSQL install/start rawh: brew install postgresql@16"
  pg_isready -q || fail_with_help "PostgreSQL is not accepting connections. Start it or set DATABASE_URL."
fi

bin/rails db:prepare

if [ "$run_mode" = "setup" ]; then
  bin/rails db:seed
  echo "Setup complete. Admin siam nan EDITORIAL_ADMIN_EMAIL leh EDITORIAL_ADMIN_PASSWORD set rawh."
  exit 0
fi

if [ "$run_mode" = "check" ]; then
  cd "$project_dir"
  python3 scripts/validate_phase4b.py
  python3 scripts/validate_phase4c.py
  cd "$backend_dir"
  bundle exec rubocop
  bundle exec brakeman --quiet --no-pager --exit-on-warn --exit-on-error
  bin/rails test
  bin/rails routes >/dev/null
  echo "PHASE 4C BACKEND CHECK PASSED"
  exit 0
fi

# Studio's "Game test" link opens this build; a failed build must not stop
# the Studio from starting.
"$project_dir/scripts/build_game_test.sh" || echo "Game test build a hlawhchham, Studio erawh kan tan tho e."

echo "Editorial Studio: http://localhost:3000"
echo "Game test:        http://localhost:3000/game-test/"
exec bin/rails server
