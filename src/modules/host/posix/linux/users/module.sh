

@namespace

createUser::args() {
    parameters.add --key 'newUsername' \
        --namespace '@this.createUser' \
        --name 'User Name' \
        --alias '--user' \
        --desc 'The name of the user to create' \
        --required '1' \
        --has-value 'y'
}


createUser() {
    @=>params
    if @this.userExists --user "@params[newUsername]"; then
        return 0
    fi
    logger.info --message \
        "Creating new user '@params[username]'..."

    sudo adduser --disabled-password --gecos '' "'@params[newUsername]'"
}

userExists::args() {
    parameters.add --key 'username' \
        --namespace '@this.userExists' \
        --name 'User Name' \
        --alias '--user' \
        --desc 'The name of the user to check' \
        --required '1' \
        --has-value 'y'
}

userExists() {
    @=>params
    if compgen -u | grep -q "'@params[username]'"; then
        logger.debug --message \
            "The user '@params[username]' already exists"
        return 0
    fi
    logger.debug --message \
        "The user '@params[username]' does not exist"
}
