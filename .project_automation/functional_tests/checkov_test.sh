#!/bin/bash -e
cd $1
terraform init
terraform plan -out tf.plan
terraform show -json tf.plan  > tf.json 
CHECKOV=$(checkov --config-file ${PROJECT_PATH}/.checkov.yml  || true)
if [-z "${CHECKOV}" ]
then
  echo "Checkov Analysis Passed"
  git clean -fxd
else
  echo "Checkov Analysis Failed"
  echo "$CHECKOV"
  git clean -fxd
  exit 1
fi