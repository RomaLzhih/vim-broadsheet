#!/usr/bin/env bash
BACKUP_DIR="${HOME}/backups"
if [ ! -d "$BACKUP_DIR" ]; then
  mkdir -p "$BACKUP_DIR"
fi
for f in a b c; do
  case "$f" in
    a) echo "first" ;;
    *) break ;;
  esac
done
while true; do exit 1; done
