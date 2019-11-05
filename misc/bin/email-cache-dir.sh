DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ls -lh $HOME/.cache | $DIR/email-self.sh "Cache dir contents" "chturne@gmail.com"
