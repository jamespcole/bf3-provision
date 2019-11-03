import.require 'bml'

resource.relative '@rel==templates/motd.bml' into '@this'

@namespace

getMotdText::precache() {
    local -A templateData
    templateData[appName]="WorkSteps"
    templateData[name]="@this[name]"
    templateData[appId]="@globals[appId]"
    templateData[envId]="@globals[envId]"
    bml.print --text \
        "$(@this.resource.get 'templates/motd.bml')"
}
