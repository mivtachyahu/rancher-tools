#!/bin/bash

# Script to Check a Rancher Service Health 
# Called with script <STACK NAME> <SERVICE NAME>

if [ "$#" -ne 2 ]; then
    echo "Two parameters required  - STACKNAME, SERVICENAME"
    exit 1
fi

if which jq 2>&1 >> /dev/null; then
  echo "jq installed - good"
else
  echo "jq not found - exiting"
  exit 1
fi

if which curl 2>&1 >> /dev/null; then
  echo "curl installed - good"
else
  echo "curl not found - exiting"
  exit 1
fi

export STACK_NAME=$1
export SERVICE_NAME=$2

export STACK_ID=$(curl -s -u "${CATTLE_ACCESS_KEY}:${CATTLE_SECRET_KEY}" "${CATTLE_URL}/stacks?name=${STACK_NAME}" | jq --raw-output '.data[0].id')
echo ${STACK_ID}
export SERVICE_ID=$(curl -s -u "${CATTLE_ACCESS_KEY}:${CATTLE_SECRET_KEY}" "${CATTLE_URL}/services?stackId=${STACK_ID}&name=${SERVICE_NAME}" | jq --raw-output '.data[0].id')
echo ${SERVICE_ID}
export SERVICE_HEALTH=$(curl -s -u "${CATTLE_ACCESS_KEY}:${CATTLE_SECRET_KEY}" "${CATTLE_URL}/services/${SERVICE_ID}" | jq --raw-output '.healthState')

case ${SERVICE_HEALTH} in
  healthy)
    echo "${STACK_NAME} ${SERVICE_NAME} healthy"
    exit 0
    ;;
  unhealthy)
    echo "${STACK_NAME} ${SERVICE_NAME} unhealthy!"
    exit 3
    ;;
  initializing)
    echo "${STACK_NAME} ${SERVICE_NAME} initializing"
    exit 4
    ;;
  *)
    echo "${STACK_NAME} ${SERVICE_NAME} ${SERVICE_HEALTH}"
    exit 5
    ;;
esac
