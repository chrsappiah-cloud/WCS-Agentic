package wcs.certificate

import future.keywords.if

default issue := {"allow": false}

issue := {"allow": true} if {
    input.action == "issue_certificate"
    input.approval.dual_control_complete == true
    input.role == "admin"
}

issue := {"allow": true} if {
    input.action == "prepare_certificate"
    input.role == "operator"
}
