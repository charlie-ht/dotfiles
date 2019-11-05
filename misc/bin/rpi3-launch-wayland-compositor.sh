#!/bin/bash

ssh -t root@metro <<EOF
SSH_HACK_RUNTIME_DIR=/root/runtime
export XDG_RUNTIME_DIR=\$SSH_HACK_RUNTIME_DIR
if ! [ -d \$SSH_HACK_RUNTIME_DIR ]; then
   mkdir \$SSH_HACK_RUNTIME_DIR && chmod 0700 \$SSH_HACK_RUNTIME_DIR
fi

if [ -e \$SSH_HACK_RUNTIME_DIR/wayland-0 ] ; then
   echo "Weston already running?"
   exit 1
fi

G_MESSAGES_DEBUG=all MESA_DEBUG=1 EGL_LOG_LEVEL=debug LIBGL_DEBUG=verbose weston --backend=drm-backend.so --tty=1
EOF
