#!/bin/bash

source common.sh

metadata_file="${INPUT_SCANMETADATAREPORTFILE}"

serverUrl="$(sed -n 's/serverUrl=\(.*\)/\1/p' $metadata_file)"
ceTaskUrl="$(sed -n 's/ceTaskUrl=\(.*\)/\1/p' $metadata_file)"
task="$(curl --silent --user $SONAR_TOKEN: $ceTaskUrl)"
status="$(jq -r '.task.status' <<< "$task")"

until [[ ${status} != "PENDING" && ${status} != "IN_PROGRESS" ]]; do
    printf '.'
    sleep 1
    task="$(curl --silent --user $SONAR_TOKEN: $ceTaskUrl)"
    status="$(jq -r '.task.status' <<< "$task")"
done

analysisId="$(jq -r '.task.analysisId' <<< "$task")"
taskId="$(jq -r '.task.id' <<< "$task")"
qualityGateUrl="${serverUrl}/api/qualitygates/project_status?analysisId=$analysisId"
qualityGateStatus="$(curl --silent --user $SONAR_TOKEN: $qualityGateUrl | jq -r '.projectStatus.status')"

if [[ ${qualityGateStatus} == "OK" ]];then
   success "Quality Gate has PASSED."
elif [[ ${qualityGateStatus} == "WARN" ]];then
   warn "Warnings on Quality Gate."
elif [[ ${qualityGateStatus} == "ERROR" ]];then
   fail "Quality Gate has FAILED."
else
   fail "Quality Gate not set for the project. Please configure the Quality Gate in SonarQube or remove sonarqube-quality-gate action from the workflow."
fi

