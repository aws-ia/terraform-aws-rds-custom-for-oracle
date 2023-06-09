#!/bin/bash -e

## NOTE: paths may differ when running in a managed task. To ensure behavior is consistent between
# managed and local tasks always use these variables for the project and project type path
PROJECT_PATH=${BASE_PATH}/project
PROJECT_TYPE_PATH=${BASE_PATH}/projecttype

echo "Starting Functional Tests"

cd ${PROJECT_PATH}

#********** Environment Setup *************
FUNCTIONAL_TEST_PATH=${PROJECT_PATH}/.project_automation/functional_tests
CHECKOV_TEST_SCRIPT_PATH=${PROJECT_PATH}/.project_automation/functional_tests/checkov_test.sh
# Use this to load any additional environment vars / terraform vars
source $FUNCTIONAL_TEST_PATH/env_setup.sh 

#********** Checkov Analysis *************
echo "Running Checkov Analysis"
terraform init
terraform plan -out tf.plan
terraform show -json tf.plan  > tf.json 
checkov --config-file ${PROJECT_PATH}/.config/checkov.yml

#********** Terratest execution **********
echo "Running Terratest"
export GOPROXY=https://goproxy.io,direct
cd test
rm -f go.mod
go mod init github.com/aws-ia/terraform-project-ephemeral
go mod tidy
go install github.com/gruntwork-io/terratest/modules/terraform
go test -timeout 240m

#********** CLEANUP *************
echo "Cleaning up all temp files and artifacts"
cd ${PROJECT_PATH}
git clean -ffxd

echo "End of Functional Tests"
