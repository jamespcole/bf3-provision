
@namespace

isPackageInstalled() {
    local package="${1}"
    if ! @this.runCheckCommand "apt-cache policy "$package" | grep -q 'Installed:'"; then
        logger.error \
            --message "The package '$package' does not seem to exist, is the name correct?"
        logger.die
    fi

    if @this.runCheckCommand "[ \$(apt-cache policy "$package" | grep 'Installed: (none)' | wc -l) != '0' ]"; then
        logger.info --message \
            "The package '${package}' is not installed"
    else
        logger.debug --message \
            "The package '${package}' is already installed"
        return 0
    fi

    return 1
}

ppaInstalled() {
    local ppa="${1}"

    if @this.runCheckCommand "[ -d /etc/apt/sources.list.d ] && grep ^ /etc/apt/sources.list /etc/apt/sources.list.d/* | grep -q '${ppa}'"; then
        logger.debug --message "The ppa '${ppa}' is already installed"
        return 0
    elif @this.runCheckCommand "grep ^ /etc/apt/sources.list | grep -q '${ppa}'"; then
        logger.debug --message "The ppa '${ppa}' is already installed"
        return 0
    fi

    logger.info --message "The ppa '${ppa}' is not already installed"

    return 1
}

addPpaRepositiory::args() {
    parameters.add --key 'ppaName' \
        --namespace '@this.addPpaRepositiory' \
        --name 'PPA Name' \
        --alias '--ppa' \
        --desc 'The name of the PPA to add eg, "ppa:gnome-desktop"' \
        --required '1' \
        --has-value 'y'
}

addPpaRepositiory() {
    @=>params

    if @this.ppaInstalled "@params[ppaName]"; then
        return 1
    fi
    logger.info --message "The ppa '@params[ppaName]' needs to be added"
    @this.run "sudo add-apt-repository 'ppa:@params[ppaName]' -y"
    @this.run "sudo apt-get update"
}

addAptList::args() {
    parameters.add --key 'aptUrl' \
        --namespace '@this.addAptList' \
        --name 'Apt Url' \
        --alias '--url' \
        --desc 'The apt url without the trailing distro name' \
        --required '1' \
        --has-value 'y'

    parameters.add --key 'aptName' \
        --namespace '@this.addAptList' \
        --name 'Apt Name' \
        --alias '--name' \
        --desc 'The name of the apt source' \
        --required '1' \
        --has-value 'y'

    parameters.add --key 'aptKeyUrl' \
        --namespace '@this.addAptList' \
        --name 'Apt Key Url' \
        --alias '--key-url' \
        --desc 'The url of the apt key to install' \
        --required '1' \
        --has-value 'y'
}

addAptList() {
    @=>params
    local filePath="/etc/apt/sources.list.d/@params[aptName].list"
    local distId="@this['distId']"
    distId="${distId,,}"
    local aptUrl="@params[aptUrl]/${distId}"
    local aptLine="deb ${aptUrl} @this[distCodename] stable"
    logger.debug --message \
        "Checking apt source '@params[aptName]' => '${aptUrl}'"

    logger.debug --message \
        "Adding apt source '@params[aptName]' => '${aptLine}' to '${filePath}'"

    @this.toFile \
        --destination "${filePath}" \
        --contents "${aptLine}" \
        --owner 'root' \
        --group 'root' \
        --owner-perms 'rw-' \
        --group-perms 'rw-' \
        --everybody-perms 'r--' || {
            return 0
        }

    @this.isPackageInstalled 'curl' || {
        @this.run 'sudo apt-get install curl'
    }
    logger.debug --message \
        "Adding apt '@params[aptName]'"
    @this.run "curl -sL @params[aptKeyUrl] | sudo apt-key add -"
    logger.debug --message \
        "Updating apt cache to add '@params[aptName]'"
    @this.run 'sudo apt-get update'
}

runInitialUpdate() {
    # if [ -f '/var/lib/apt/periodic/update-stamp' ]; then
    if [ -f '/var/cache/apt/pkgcache.bin' ]; then
        logger.debug --message \
            'Do not need to run initial apt cache update'
        return 1
    fi

    logger.debug --message \
        'Running intial apt cache update...'
    @this.run 'sudo apt-get update -y'
    return 0
}

packageInstalled::args() {
    parameters.add --key 'packageName' \
        --namespace '@this.packageInstalled' \
        --name 'Package Name' \
        --alias '--package' \
        --desc 'The name of the package to install' \
        --required '1' \
        --has-value 'y'
}

packageInstalled() {
    @=>params

    if @this.isPackageInstalled "@params[packageName]"; then
        return 1
    fi
    logger.info \
        --message "The package '@params[packageName]' needs to be installed..."
    @this.run "sudo apt-get install '@params[packageName]' -y"
}


isInstalled::args() {
    parameters.add --key 'binaryName' \
        --namespace '@this.isInstalled' \
        --name 'Binary/Command Name' \
        --alias '--name' \
        --desc 'The name of the binary/command to test for.' \
        --required '1' \
        --has-value 'y'
}

isInstalled() {
    @=>params
    local binary="@params[binaryName]"
    if @this.runCheckCommand "[ \$(which '${binary}' | wc -l) == '0' ]"; then
        logger.info --message \
            "Command \"${binary}\" is not installed"
        return 1
    fi
    logger.debug --message \
        "Command \"${binary}\" is already installed"

    return 0
}
