import.require 'provision.debian' as '@this.host'

@namespace

require() {
    @this.host.packageInstalled --package 'software-properties-common'

    # @this.host.addPpaRepositiory --ppa 'jonathonf/python-3.6'
    @this.host.addPpaRepositiory --ppa 'deadsnakes/ppa'
    @this.host.packageInstalled --package 'python3.6'
    @this.host.packageInstalled --package 'python3.6-venv'
    @this.host.packageInstalled --package 'python3.6-dev'
    # added for 18.04
    @this.host.packageInstalled --package 'python3-venv'
    return 0
}

ensureEnv::args() {
    parameters.add --key 'pyvenvDir' \
        --namespace '@this.ensureEnv' \
        --name 'Python Env Directory' \
        --alias '--env-dir' \
        --desc 'The directory to install the python environment to.' \
        --default "$(pwd)/.pyvenv" \
        --required '0' \
        --has-value 'y'
}

ensureEnv() {
    @=>params

    if @this.host.runCheckCommand "[ -f '@params[pyvenvDir]/bin/activate' ]"; then
        logger.debug --message "Python environment already created"
    else
        logger.info --message "Python environment not created"
        local createEnvCmd=$(cat << EOF
/usr/bin/python3.6 -m venv '@params[pyvenvDir]'
. @params[pyvenvDir]/bin/activate || exit 1
pip install --upgrade pip
pip install -U setuptools
EOF
)
        @this.host.run "${createEnvCmd}"
        logger.info --message \
            "Python environment created.  Run '. @params[pyvenvDir]/bin/activate' to activate."
    fi
}


ensureEnv::args() {
    parameters.add --key 'pyvenvDir' \
        --namespace '@this.ensureEnv' \
        --name 'Python Env Directory' \
        --alias '--env-dir' \
        --desc 'The directory to install the python environment to.' \
        --default "$(pwd)/.pyvenv" \
        --required '0' \
        --has-value 'y'
}

ensureEnv() {
    @=>params

    if @this.host.runCheckCommand "[ -f '@params[pyvenvDir]/bin/activate' ]"; then
        logger.debug --message "Python environment already created"
    else
        logger.info --message "Python environment not created"
        local createEnvCmd=$(cat << EOF
/usr/bin/python3.6 -m venv '@params[pyvenvDir]'
. @params[pyvenvDir]/bin/activate || exit 1
pip install --upgrade pip
pip install -U setuptools
EOF
)
        @this.host.run "${createEnvCmd}"
        logger.info --message \
            "Python environment created.  Run '. @params[pyvenvDir]/bin/activate' to activate."
    fi
}


installRequirements::args() {
    parameters.add --key 'pyvenvDir' \
        --namespace '@this.installRequirements' \
        --name 'Python Env Directory' \
        --alias '--env-dir' \
        --desc 'The directory to a activate before installing requirements.' \
        --default "$(pwd)/.pyvenv" \
        --required '0' \
        --has-value 'y'

    parameters.add --key 'reqsFile' \
        --namespace '@this.installRequirements' \
        --name 'Requirements File Path' \
        --alias '--reqs-file' \
        --desc 'The path to a requirements.txt file.' \
        --required '1' \
        --has-value 'y'
}

installRequirements() {
    @=>params

    if ! @this.host.runCheckCommand "[ -f '@params[pyvenvDir]/bin/activate' ]"; then
        logger.error \
            --message "Python environment '@params[pyvenvDir]' does not exist."
        logger.die
    fi

    if ! @this.host.runCheckCommand "[ -f '@params[reqsFile]' ]"; then
        logger.error \
            --message "Python requirements file '@params[reqsFile]' does not exist."
        logger.die
    fi
        local createEnvCmd=$(cat << EOF
. @params[pyvenvDir]/bin/activate || exit 1
pip install -r '@params[reqsFile]'
EOF
)
    @this.host.run "${createEnvCmd}"
}
