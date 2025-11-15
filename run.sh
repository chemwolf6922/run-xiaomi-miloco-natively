OUTPUT_PATH="$PWD/output"

VENV_ACTIVATE="./.venv/miloco/bin/activate"

if [ ! -f "$VENV_ACTIVATE" ]; then
    echo "Virtual environment not found. Please run build.sh first."
    exit 1
fi

. "$VENV_ACTIVATE"

START_SCRIPT="$OUTPUT_PATH/scripts/start_server.py"

if [ ! -f "$START_SCRIPT" ]; then
    echo "Start script not found. Please run build.sh first."
    exit 1
fi

python "$START_SCRIPT" "$@"
