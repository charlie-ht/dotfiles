if [[ -x $(which virtualenvwrapper.sh) ]]; then
    # FIXME: Grim interpreter selection
    VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3 source $(which virtualenvwrapper.sh)
else
    echo_warning "Woah, Batman! There is not virtualenvwrapper?"
fi

python_new_project() {
    local name=$1
    if [ -z $name ]; then
        echo "Batman! Please! Give this project a name!"
        return 1
    fi

    VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3 mkvirtualenv -p python3.7 $name
}

python_list_projects() {
    VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3 lsvirtualenv
}

python_remove_project() {
    VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3 rmvirtualenv $1
}
