#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PORT="${PORT:-3000}"
OPENCODE_WEB_DIR="${OPENCODE_WEB_DIR:-/home/runner/work/_temp/omgithub-web}"
export PROJECT_DIR PORT OPENCODE_WEB_DIR

[[ "$PORT" =~ ^[0-9]+$ ]] || { echo "PORT must be numeric" >&2; exit 1; }
/usr/bin/time -p mkdir -p "$PROJECT_DIR/dist" "$OPENCODE_WEB_DIR"
# This project has no local package dependencies or compilation step: publish its
# static entry point and modules into an in-project deployment directory.
/usr/bin/time -p cp "$PROJECT_DIR/index.html" "$PROJECT_DIR/style.css" "$PROJECT_DIR/game.js" "$PROJECT_DIR/dist/"
/usr/bin/time -p python3 -c 'import json,os; json.dump({"project":os.environ["PROJECT_DIR"],"directory":os.path.join(os.environ["PROJECT_DIR"],"dist")},open(os.path.join(os.environ["OPENCODE_WEB_DIR"],"deployment-output.json"),"w"))'
cd "$PROJECT_DIR/dist"
exec /usr/bin/time -p python3 -m http.server "$PORT" --bind 0.0.0.0 --directory "$PROJECT_DIR/dist"
