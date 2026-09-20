#!/usr/bin/env bash
# Launch the Python host GUI using the SDK virtualenv.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=yhjm-env.sh
. "${SCRIPT_DIR}/yhjm-env.sh"
yhjm_import_env

venv_py="${YHJM_SDK_PYTHON}/.venv/bin/python"
if [[ ! -x "${venv_py}" ]]; then
    echo "SDK venv not found. Run ./tools/setup-env.sh first." >&2
    exit 1
fi

exec "${venv_py}" "${YHJM_SDK_PYTHON}/servo_gui.py" "$@"
