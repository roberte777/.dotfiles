#!/bin/sh
# Generates a 64-character hex encryption key for Homarr
# and updates it in the .env file.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"

KEY=$(openssl rand -hex 32)

if [ ! -f "$ENV_FILE" ]; then
  echo "Error: $ENV_FILE not found. Copy .env.example to .env first." >&2
  exit 1
fi

if grep -q '^HOMARR_SECRET_ENCRYPTION_KEY=' "$ENV_FILE"; then
  sed -i "s|^HOMARR_SECRET_ENCRYPTION_KEY=.*|HOMARR_SECRET_ENCRYPTION_KEY=$KEY|" "$ENV_FILE"
else
  echo "HOMARR_SECRET_ENCRYPTION_KEY=$KEY" >> "$ENV_FILE"
fi

echo "Homarr encryption key set in $ENV_FILE"
