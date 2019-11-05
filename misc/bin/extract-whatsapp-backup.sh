#!/usr/bin/env bash


WhatsAppBackupFolder=$1
if [ -z "$WhatsAppBackupFolder" ] ; then
    echo "$0 <folder containing whatsapp backup>"
    exit 1
fi

echo "Copying all media files from $WhatsAppBackupFolder"
find $WhatsAppBackupFolder -type f \( -name '*.opus' -o -name '*.jpg' -o -name '*.jpeg' -o -name '*.mp4' \) -exec sh -c '
  for file do
    echo "$file"
    case $file in
    *.opus)
      mv -v "$file" ~/Audio/WhatsApp/
      ;;
    *.jpg|*.jpeg)
      mv -v "$file" ~/Pictures/WhatsApp/
      ;;
    *.mp4)
      mv -v "$file" ~/Videos/WhatsApp/
      ;;
    esac

  done
' sh {} +

echo "Remaining files in backup dir"
find $WhatsAppBackupFolder -type f
