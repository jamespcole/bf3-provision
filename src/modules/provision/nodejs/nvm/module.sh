#!/usr/bin/env bash
import.require 'provision'
import.require 'provision.git'

@namespace

require() {
    @this.ensureEnv "$@" || {
        logger.error --message \
            "Failed to install nodejs environment"
        return 1
    }
    return 0
}

ensureEnv::args() {
    parameters.add --key 'nvmDir' \
        --namespace '@this.ensureEnv' \
        --name 'NVM Directory' \
        --alias '--nvm-dir' \
        --desc 'The directory to install NVM to.' \
        --default "$(pwd)/.nvm" \
        --required '0' \
        --has-value 'y'

    parameters.add --key 'nodeVersion' \
        --namespace '@this.ensureEnv' \
        --name 'Node Version' \
        --alias '--node-version' \
        --desc 'The NodeJS version to install and activate.' \
        --default '6' \
        --required '0' \
        --has-value 'y'

    parameters.add --key 'addToBash' \
        --namespace '@this.ensureEnv' \
        --name 'Add to .bashrc' \
        --alias '--add-to-bashrc' \
        --desc "Add to the current user's .bashrc file so it is automatically initialised." \
        --default '0' \
        --required '0' \
        --type 'switch'
}

ensureEnv() {
    @=>params

    local nvmDir="@params[nvmDir]"
    local nodeVer="@params[nodeVersion]"
    local addToBashrc="@params[addToBash]"

    if [ ! -f "${nvmDir}/nvm.sh" ]; then
        mkdir -p "${nvmDir}"
        provision.require 'git' || {
            logger.error \
                --message "git requirement not met while installing nvm"
            return 1
        }

        export NVM_DIR="${nvmDir}" && (
            git clone https://github.com/creationix/nvm.git "$NVM_DIR"
            cd "$NVM_DIR"
            git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" origin`
        ) && . "$NVM_DIR/nvm.sh"

        if ! test "$NVM_DIR"; then
            . "${nvmDir}/nvm.sh"
        fi

        # If it's still not available export the NVM_DIR environment variable and source it again
        nvm > /dev/null 2>&1 || {
            export NVM_DIR="${nvmDir}"
            . "${nvmDir}/nvm.sh"
        }

        # grep away the download progress which looks crappy during vagrant provision
        nvm install "${nodeVer}" 2>&1 | grep -v '^#.*%$' || {
            logger.error --message \
                'Failed to install node'
            return 1${__params['nvm-dir']}
        }
        nvm use "${nodeVer}" || {
            return 1
        }

    else
        export NVM_DIR="${nvmDir}"
        . "${nvmDir}/nvm.sh"
        nvm use "${nodeVer}" || {
            nvm install "${nodeVer}" 2>&1 | grep -v '^#.*%$' || {
                logger.error --message \
                    'Failed to install node'
                return 1
            }
            nvm use "${nodeVer}" || {
                return 1
            }
        }
    fi

    if [[ "${addToBashrc}" == '1' ]] \
        && [ $(grep 'NVM_DIR' "$HOME/.bashrc" | wc -l) == '0' ]
    then
        echo -e \
            "\nexport NVM_DIR=\"${nvmDir}\"\n[ -s \"\$NVM_DIR/nvm.sh\" ] && . \"\$NVM_DIR/nvm.sh\"\n" \
            >> "$HOME/.bashrc"
    fi

    return 0
}
