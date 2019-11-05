#!/bin/bash

SUBJECT=$1
TO=$2
HOSTNAME=$(hostname)

mailx -v -s "$SUBJECT" \
      -S smtp-use-starttls \
      -S ssl-verify=ignore \
      -S smtp-auth=login \
      -S smtp=smtp://smtp.gmail.com:587 \
      -S from="$PERSONAL_EMAIL($HOSTNAME)" \
      -S smtp-auth-user=$PERSONAL_EMAIL \
      -S smtp-auth-password=$PERSONAL_EMAIL_SMTP_PASS \
      -S ssl-verify=ignore \
      -S nss-config-dir=~/.certs \
      "$TO" >/dev/null 2>&1
