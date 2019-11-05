#!/bin/bash

# Launch a website on the pi.

URL=${1:-'https://google.com'}

ssh -t root@metro <<EOF
SSH_HACK_RUNTIME_DIR=/root/runtime
export XDG_RUNTIME_DIR=\$SSH_HACK_RUNTIME_DIR

if ! [ -e \$SSH_HACK_RUNTIME_DIR/wayland-0 ] ; then
   echo "no wayland compositor running?"
   exit 1
fi

G_MESSAGES_DEBUG=all MESA_DEBUG=1 EGL_LOG_LEVEL=debug LIBGL_DEBUG=verbose G_MESSAGES_DEBUG=all \
  cog -P fdo $URL

EOF

