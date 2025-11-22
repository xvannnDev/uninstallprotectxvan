#!/bin/bash
set -e

REMOTE_PATH="/var/www/pterodactyl/app/Http/Controllers/Admin/ApiController.php"

echo "🚀 Menghapus proteksi Application API..."

# cari backup terakhir
BACKUP_FILE=$(ls -t ${REMOTE_PATH}.bak_* 2>/dev/null | head -n 1)

if [ -z "$BACKUP_FILE" ]; then
  echo "⚠️ Tidak ada backup yang ditemukan! Tidak bisa uninstall."
  exit 1
fi

echo "📦 Mengembalikan ApiController dari backup: $BACKUP_FILE"

# restore backup
cp -a "$BACKUP_FILE" "$REMOTE_PATH"
chown www-data:www-data "$REMOTE_PATH" || true
chmod 644 "$REMOTE_PATH"

echo "✅ Backup berhasil di-restore!"

# clear caches Laravel
cd /var/www/pterodactyl || exit 1
php artisan cache:clear || true
php artisan config:clear || true
php artisan route:clear || true
php artisan view:clear || true
php artisan optimize:clear || true

# restart service
if systemctl list-units --type=service --all | grep -q pteroq; then
  systemctl restart pteroq || true
fi
if systemctl list-units --type=service --all | grep -q nginx; then
  systemctl restart nginx || true
fi

echo "✅ Uninstall Application API selesai!"
echo "📂 File controller dikembalikan ke versi backup: $BACKUP_FILE"
echo "🔓 Berhasil 100%."