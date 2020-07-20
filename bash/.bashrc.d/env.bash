# See gpg-agent(1)
GPG_TTY=$(tty)
export GPG_TTY

export EDITOR='emacsclient'
export PAGER=less
export JAVA_HOME=/home/cht/igalia/graphics/jdk1.8.0_251
export ANDROID_NDK_HOME=/home/cht/igalia/graphics/android-home/ndk-bundle
export ANDROID_HOME=/home/cht/igalia/graphics/android-home

path_prepend_if_missing $HOME/bin
path_prepend_if_missing $HOME/.local/bin
