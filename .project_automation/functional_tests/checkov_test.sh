#!/bin/bash -e

cd $1
echo $PWD

terraform init
terraform plan -out tf.plan
terraform show -json tf.plan  > tf.json 

if checkov --config-file $FUNCTIONAL_TEST_PATH/.merged_checkov.yml
then
  echo "Checkov Analysis Passed"
else
  echo "Checkov Analysis Failed"  
  cd ${PROJECT_PATH}
  git clean -ffxd
  exit 1
fi