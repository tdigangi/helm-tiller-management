#!/bin/bash
CONTEXT=$(kubectl config current-context)
curl https://www.googleapis.com/oauth2/v2/tokeninfo?access_token=$(kubectl config view -o jsonpath="{.users[?(@.name == \"$CONTEXT\")].user.auth-provider.config.access-token}") | jq -r .email
