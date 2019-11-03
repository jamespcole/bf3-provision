import.require 'provision'

@namespace

require() {
    if provision.isInstalled 'git'; then
        return 0
    fi
    sudo apt-get install -y 'git'
    return $?
}
