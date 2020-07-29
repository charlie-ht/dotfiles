export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
PIP=pip3

if [[ -x $(which virtualenvwrapper.sh) ]]; then
    source $(which virtualenvwrapper.sh)
else
    echo_warning "Woah, Batman! There is not virtualenvwrapper?"
fi

python_user_list_packages() {
    $PIP list --user
}

python_user_install_package() {
    $PIP install $1
}

python_user_remove_package() {
    $PIP uninstall $1
}

python_user_upgrade_packages() {
    $PIP list --user
}

python_new_project() {
    local name=$1
    if [ -z $name ]; then
        echo "Batman! Please! Give this project a name!"
        return 1
    fi

    base_requirements=$(mktemp /tmp/virtual-env-requirements_XXX.txt)
    cat <<EOF > $tmpfile
mypy
flake8
pylint
jedi
jupyter
numpy
EOF
    mkvirtualenv -p python3.7 -r $base_requirements $name
}

python_list_projects() {
    lsvirtualenv
}

python_remove_project() {
    rmvirtualenv $1
}
