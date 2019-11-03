import.require 'provision.debian.apt' mixin '@this'

@namespace

run() {
    bash -s < <(echo "${1}") \
        || {
            logger.die
        }
}

runCheckCommand() {
    bash -s < <(echo "${1}") 2>&1
}
