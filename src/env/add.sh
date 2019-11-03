
if declare -f -F 'bf3.bootstrap.addToPath' > /dev/null; then
    export BF3_PATH=$(bf3.bootstrap.addToPath "$BF3_PATH" "$(readlink -f $(dirname $(readlink -f ${BASH_SOURCE}))/..)")
    export PATH=$(bf3.bootstrap.addToPath "$PATH" "$(readlink -f $(dirname $(readlink -f ${BASH_SOURCE}))/..)/install_hooks")
else
    echo "ERROR: The function 'bf3.bootstrap.addToPath' was not found."
    echo "Make sure you have sourced 'common.sh' in the base framework environment first"
fi
