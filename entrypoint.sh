#!/bin/sh
set -euf

export APPNAME="$1"
export BRANCH="$GITHUB_REF"
export CODEBUILD_BUILD_ID="external-$GITHUB_RUN_ID"
export CODEBUILD_BUILD_NUMBER="external-$GITHUB_RUN_NUMBER"

# set environment variables
echo "Collecting build metadata"
aws codebuild batch-get-projects --names "$APPNAME" --query 'projects[0]' > build.json
export DOCKER_REPO=$(jq -r '.environment.environmentVariables[] | select(.name == "DOCKER_REPO") | .value' < build.json)
export PIPELINE="$(jq -r '.environment.environmentVariables[] | select(.name == "PIPELINE") | .value' < build.json)"
export DOCKERHUB_USERNAME=$(aws ssm get-parameters --names /apppack/account/dockerhub-username --query Parameters[0].Value --output text)
export DOCKERHUB_ACCESS_TOKEN=$(aws ssm get-parameters --names /apppack/account/dockerhub-access-token --with-decryption --query Parameters[0].Value --output text)
# extract build script
jq -r .source.buildspec < build.json > buildspec.yml
yj < buildspec.yml | jq -r .phases.install.commands > script.sh
yj < buildspec.yml | jq -r .phases.pre_build.commands >> script.sh
yj < buildspec.yml | jq -r .phases.build.commands >> script.sh
# run build script
echo "::group::Running build process"
bash script.sh
echo "::endgroup::"
echo "Fixing file permissions"
chown 1001 build.json
echo "  * build.json"
chown 1001 buildspec.yml
echo "  * buildspec.yml"
for FILE in $(yj < buildspec.yml | jq -r '.artifacts.files[]'); do
  echo "  * $FILE"
  test -f "$FILE" && chown 1001 "$FILE" || echo "::warning::$FILE does not exist"

done
echo "::set-output name=docker_image::$DOCKER_REPO:$GITHUB_SHA"
