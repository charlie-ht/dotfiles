    if [[ -x $(which virtualenvwrapper.sh) ]]; then
        # FIXME: Grim interpreter selection
        VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3 source $(which virtualenvwrapper.sh)
    else
        echo_warning "Woah, Batman! There is not virtualenvwrapper?"
    fi
