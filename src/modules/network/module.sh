
@namespace

getIpAddress::args() {
    parameters.add --key 'hostName' \
        --namespace '@this.getIpAddress' \
        --name 'Hostname' \
        --alias '--hostname' \
        --desc "The hostname to resolve to an ip address.  If empty it defaults to current machine's hostname." \
        --required '0' \
        --default "$(hostname)" \
        --has-value 'y'
}

getIpAddress() {
    @=>params
    getent ahostsv4 "@params[hostName]" \
        | grep 'STREAM' \
        | head -n 1 \
        | cut -d ' ' -f 1
}
