#!/bin/bash -e
cd $1
terraform init
terraform plan -out tf.plan
terraform show -json tf.plan  > tf.json 
CHECKOV=$(checkov --config-file $FUNCTIONAL_TEST_PATH/.merged_checkov.yml  || true)
if [-z "${CHECKOV}" ]
then
  echo "Checkov Analysis Passed"
  git clean -ffxd
else
  echo "Checkov Analysis Failed"
  echo "$CHECKOV"
  git clean -ffxd
  exit 1
fi