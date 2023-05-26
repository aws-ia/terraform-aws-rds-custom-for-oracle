#!/bin/bash -e

## NOTE: paths may differ when running in a managed task. To ensure behavior is consistent between
# managed and local tasks always use these variables for the project and project type path
PROJECT_PATH=${BASE_PATH}/project
PROJECT_TYPE_PATH=${BASE_PATH}/projecttype

echo "Starting Functional Tests"

cd ${PROJECT_PATH}

#********** Environment Setup *************
export AWS_DEFAULT_REGION=us-west-2
CHECKOV_TEST_SCRIPT_PATH=${PROJECT_PATH}/.project_automation/functional_tests/checkov_test.sh

#********** Checkov Analysis *************
echo "Running Checkov Analysis"
for dir in ${PROJECT_PATH}/examples/*; do
  echo "Running Checkov Analysis for: $dir"
  source $CHECKOV_TEST_SCRIPT_PATH $dir
done

#********** Terratest execution **********
echo "Running Terratest"
export GOPROXY=https://goproxy.io,direct
cd test
rm -f go.mod
go mod init github.com/aws-ia/terraform-project-ephemeral
go mod tidy
go install github.com/gruntwork-io/terratest/modules/terraform
go test -timeout 45m

echo "End of Functional Tests"