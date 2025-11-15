OUTPUT_PATH="$PWD/output"

MILOCO_PATH=$1

if [ -z "$MILOCO_PATH" ]; then
  echo "Usage: $0 <miloco_path>"
  exit 1
fi

# Prepare a Python virtual environment

if ! command -v python3 >/dev/null 2>&1; then
    echo "python3 is required but not installed."
    exit 1
fi

VENV_TARGET="$PWD/.venv/miloco"

if [ -n "$VIRTUAL_ENV" ]; then
    read -r -p "Detected virtual environment at $VIRTUAL_ENV. Use it? [y/N] " use_current
    if [[ ! "$use_current" =~ ^[Yy]$ ]]; then
        python3 -m venv "$VENV_TARGET"
        # shellcheck disable=SC1091
        . "$VENV_TARGET/bin/activate"
    fi
else
    if [ ! -d "$VENV_TARGET" ]; then
        python3 -m venv "$VENV_TARGET"
    fi
    # shellcheck disable=SC1091
    . "$VENV_TARGET/bin/activate"
fi

# Install the python backend packages

MIOT_KIT_SOURCE_PATH="$MILOCO_PATH/miot_kit"
MIOT_KIT_TARGET_PATH="$OUTPUT_PATH/miot_kit"

rm -rf "$MIOT_KIT_TARGET_PATH"
cp -r "$MIOT_KIT_SOURCE_PATH" "$MIOT_KIT_TARGET_PATH"

MILOCO_SERVER_SOURCE_PATH="$MILOCO_PATH/miloco_server"
MILOCO_SERVER_TARGET_PATH="$OUTPUT_PATH/miloco_server"

rm -rf "$MILOCO_SERVER_TARGET_PATH"
cp -r "$MILOCO_SERVER_SOURCE_PATH" "$MILOCO_SERVER_TARGET_PATH"

python -m pip install --upgrade pip setuptools wheel

python -m pip uninstall -y miloco-server miloco-kit 2>/dev/null || true
python -m pip install -e "$MIOT_KIT_TARGET_PATH"
python -m pip install -e "$MILOCO_SERVER_TARGET_PATH"

# Copy configuration files

CONFIG_SOURCE_PATH="$MILOCO_PATH/config"
CONFIG_TARGET_PATH="$OUTPUT_PATH/config"
rm -rf "$CONFIG_TARGET_PATH"
mkdir -p "$CONFIG_TARGET_PATH"

cp "$CONFIG_SOURCE_PATH/server_config.yaml" "$CONFIG_TARGET_PATH/"
cp "$CONFIG_SOURCE_PATH/prompt_config.yaml" "$CONFIG_TARGET_PATH/"

# Copy startup script

SCRIPT_SOURCE_PATH="$MILOCO_PATH/scripts"
SCRIPT_TARGET_PATH="$OUTPUT_PATH/scripts"
rm -rf "$SCRIPT_TARGET_PATH"
mkdir -p "$SCRIPT_TARGET_PATH"

cp "$SCRIPT_SOURCE_PATH/start_server.py" "$SCRIPT_TARGET_PATH/"

# Build the frontend

if ! command -v npm >/dev/null 2>&1; then
    echo "npm is required but not installed."
    exit 1
fi

MILOCO_WEBUI_PATH="$MILOCO_PATH/web_ui"

npm i --prefix $MILOCO_WEBUI_PATH
npm run build --prefix $MILOCO_WEBUI_PATH

WEBUI_TARGET_PATH="$MILOCO_SERVER_TARGET_PATH/static"
rm -rf "$WEBUI_TARGET_PATH"
mkdir -p "$WEBUI_TARGET_PATH"
cp -r "$MILOCO_WEBUI_PATH/dist/"* "$WEBUI_TARGET_PATH/"

