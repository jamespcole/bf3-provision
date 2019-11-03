#!/usr/bin/env bash

# Source the common activation functions from the base framework environment
_CORE_SCRIPT_PATH='/home/vagrant/app/src'
[ -d "${_CORE_SCRIPT_PATH}" ] || {
    echo "Could not find core scripts directory at \"${_CORE_SCRIPT_PATH}\""
    exit 1
}
source "${_CORE_SCRIPT_PATH}/env/common.sh"

# If another environment is active remove all its location from the system path
if [ ! -z BF3_PATH ]; then
    export PATH=$(bf3.bootstrap.removePaths)
fi

# Set this as the current active environment
export BF3_ACTIVE_PATH="$(readlink -f $(dirname $(readlink -f ${BASH_SOURCE}))/..)"
unset BF3_PATH

# Add the fbase ramework to this environment
source "${_CORE_SCRIPT_PATH}/env/add.sh"

# Add this environment's commands to the system path
export PATH=$(bf3.bootstrap.addToPath "$PATH" "$(readlink -f $(dirname $(readlink -f ${BASH_SOURCE}))/..)/install_hooks")

# Add this enviroment to the BF3 path
export BF3_PATH=$(bf3.bootstrap.addToPath "$BF3_PATH" "$(readlink -f $(dirname $(readlink -f ${BASH_SOURCE}))/..)")

# This sets the path for this BF3 base framework locations
export BF3_FW_PATH="$_CORE_SCRIPT_PATH"

bf3.bootstrap.printSummary
