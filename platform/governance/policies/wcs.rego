package wcs.onboarding

import future.keywords.if

default start := {"allow": false}

# Allow operators and admins to start onboarding workflow
start := {"allow": true} if {
    input.action == "workflow.start"
    input.role == "operator"
}

start := {"allow": true} if {
    input.action == "workflow.start"
    input.role == "admin"
}

# Deny autonomous start for basic users
start := {"allow": false} if {
    input.action == "workflow.start"
    input.role == "user"
}
