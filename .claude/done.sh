#!/usr/bin/env bash
# The repo's "Done means" check (see CLAUDE.md). Run by the claude-stop-check Stop hook.
set -euo pipefail
cd "$(dirname "$0")/.."
python3 -c "import ast,yaml; ast.parse(open('hc_status.star').read(),'hc_status.star'); yaml.safe_load(open('.github/workflows/push.yml')); print('ok: star parses, workflow yaml loads')"
