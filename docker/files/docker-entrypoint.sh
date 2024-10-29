#!/bin/bash
set -eoux pipefail
INSTALLED_DIRECTORY=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
FACTORIO_VOL=/factorio
LOAD_LATEST_SAVE="${LOAD_LATEST_SAVE:-true}"
GENERATE_NEW_SAVE="${GENERATE_NEW_SAVE:-false}"
PRESET="${PRESET:-""}"
SAVE_NAME="${SAVE_NAME:-""}"
BIND="${BIND:-""}"
CONSOLE_LOG_LOCATION="${CONSOLE_LOG_LOCATION:-""}"

mkdir -p "$FACTORIO_VOL"
mkdir -p "$SAVES"
mkdir -p "$CONFIG"
mkdir -p "$MODS"
mkdir -p "$SCENARIOS"
mkdir -p "$SCRIPTOUTPUT"

if [[ ! -f $CONFIG/rconpw ]]; then
  # Generate a new RCON password if none exists
  pwgen 15 1 >"$CONFIG/rconpw"
fi

# Copy server-settings.json
cp /opt/factorio/data/server-settings.json "$CONFIG/server-settings.json"

if [[ ! -f $CONFIG/map-gen-settings.json ]]; then
  cp /opt/factorio/data/map-gen-settings.example.json "$CONFIG/map-gen-settings.json"
fi

if [[ ! -f $CONFIG/map-settings.json ]]; then
  cp /opt/factorio/data/map-settings.example.json "$CONFIG/map-settings.json"
fi

NRTMPSAVES=$( find -L "$SAVES" -iname \*.tmp.zip -mindepth 1 | wc -l )
if [[ $NRTMPSAVES -gt 0 ]]; then
  # Delete incomplete saves (such as after a forced exit)
  rm -f "$SAVES"/*.tmp.zip
fi

if [[ ${UPDATE_MODS_ON_START:-} == "true" ]]; then
  ${INSTALLED_DIRECTORY}/docker-update-mods.sh
fi

${INSTALLED_DIRECTORY}/docker-dlc.sh

EXEC=""
if [[ $(id -u) == 0 ]]; then
  # Update the User and Group ID based on the PUID/PGID variables
  usermod -o -u "$PUID" factorio
  groupmod -o -g "$PGID" factorio
  # Take ownership of factorio data if running as root
  chown -R factorio:factorio "$FACTORIO_VOL"
  # Drop to the factorio user
  EXEC="runuser -u factorio -g factorio --"
fi
if [[ -f /bin/box64 ]]; then
  # Use an emulator to run on ARM hosts
  # this only gets installed when the target docker platform is linux/arm64
  EXEC="$EXEC /bin/box64"
fi

sed -i '/write-data=/c\write-data=\/factorio/' /opt/factorio/config/config.ini

NRSAVES=$(find -L "$SAVES" -iname \*.zip -mindepth 1 | wc -l)
if [[ $GENERATE_NEW_SAVE != true && $NRSAVES ==  0 ]]; then
    GENERATE_NEW_SAVE=true
    SAVE_NAME=_autosave1
fi

if [[ $GENERATE_NEW_SAVE == true ]]; then
    if [[ -z "$SAVE_NAME" ]]; then
        echo "If \$GENERATE_NEW_SAVE is true, you must specify \$SAVE_NAME"
        exit 1
    fi
    if [[ -f "$SAVES/$SAVE_NAME.zip" ]]; then
        echo "Map $SAVES/$SAVE_NAME.zip already exists, skipping map generation"
    else
        if [[ ! -z "$PRESET" ]]; then
            $EXEC /opt/factorio/bin/x64/factorio \
                --create "$SAVES/$SAVE_NAME.zip" \
                --preset "$PRESET" \
                --map-gen-settings "$CONFIG/map-gen-settings.json" \
                --map-settings "$CONFIG/map-settings.json"
        else
            $EXEC /opt/factorio/bin/x64/factorio \
                --create "$SAVES/$SAVE_NAME.zip" \
                --map-gen-settings "$CONFIG/map-gen-settings.json" \
                --map-settings "$CONFIG/map-settings.json"
        fi
    fi
fi

FLAGS=(\
  --port "$PORT" \
  --server-settings "$CONFIG/server-settings.json" \
  --server-banlist "$CONFIG/server-banlist.json" \
  --rcon-port "$RCON_PORT" \
  --server-whitelist "$CONFIG/server-whitelist.json" \
  --use-server-whitelist \
  --server-adminlist "$CONFIG/server-adminlist.json" \
  --rcon-password "$(cat "$CONFIG/rconpw")" \
  --server-id /factorio/config/server-id.json \
  --mod-directory "$MODS" \
)

if [ -n "$CONSOLE_LOG_LOCATION" ]; then
  FLAGS+=( --console-log "$CONSOLE_LOG_LOCATION" )
fi

if [ -n "$BIND" ]; then
  FLAGS+=( --bind "$BIND" )
fi

if [[ $LOAD_LATEST_SAVE == true ]]; then
    FLAGS+=( --start-server-load-latest )
else
    FLAGS+=( --start-server "$SAVE_NAME" )
fi

# shellcheck disable=SC2086
exec $EXEC /opt/factorio/bin/x64/factorio "${FLAGS[@]}" "$@"
