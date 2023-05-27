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
echo "Configuring Checkov"
yq eval-all '. as $item ireduce ({}; . *+ $item)' .checkov.yml $FUNCTIONAL_TEST_PATH/.checkov-overrides.yml > $FUNCTIONAL_TEST_PATH/.merged_checkov.yml
checkov --show-config --config-file $FUNCTIONAL_TEST_PATH/.merged_checkov.yml

# for dir in ${PROJECT_PATH}/examples/*; do
#   echo "Running Checkov Analysis for: $dir"
#   source $CHECKOV_TEST_SCRIPT_PATH $dir
# done

# #********** Terratest execution **********
# echo "Running Terratest"
# export GOPROXY=https://goproxy.io,direct
# cd test
# rm -f go.mod
# go mod init github.com/aws-ia/terraform-project-ephemeral
# go mod tidy
# go install github.com/gruntwork-io/terratest/modules/terraform
# go test -timeout 45m

echo "End of Functional Tests"