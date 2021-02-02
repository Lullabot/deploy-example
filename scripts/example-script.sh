#!/usr/bin/env bash

#############
# CONFIGURE #
#############

# Configure Git repository.
GIT_URL="git@github.com:mtift/deploy-example.git"
GIT_REMOTE_NAME="origin"
UNCOMPILED_BRANCH="master"
COMPILED_BRANCH="master-compiled"

# Directories or path patterns to force commit.
FORCE_COMMIT_PATTERNS="vendor \
/web/core \
/web/modules/contrib \
/web/themes/contrib \
/web/profiles/contrib \
/web/libraries"

# Add a warning message. You are about to update the following directories
# in the following Git repository.

# Make sure the repo exists as a remote.
# if git remote|grep $GIT_REMOTE_NAME; then
  # git remote set-url $GIT_REMOTE_NAME $GIT_URL
# else
  # git remote add $GIT_REMOTE_NAME $GIT_URL
# fi

# Make sure $UNCOMPILED_BRANCH is clean.
# git checkout $UNCOMPILED_BRANCH
# git fetch $GIT_REMOTE_NAME

# TODO: fix this.
if -z git diff-index --quiet HEAD --; then
  echo "Please clean up your ${UNCOMPILED_BRANCH} before proceeding."
  exit 0;
fi



#########
# BUILD #
#########

# Build the theme assets
# npm install
# npm run build

# Install files with composer
composer install --optimize-autoloader


##########
# COMMIT #
##########

# Don't ignore the composer-generated files.
cp -f .gitignore.acquia .gitignore

# Clean out all .git dirs from any directories.
for PATTERN in $FORCE_COMMIT_PATTERNS; do
  echo $PATTERN
  if [ -d $PATTERN ]; then
    find $PATTERN -type d -name .git | xargs rm -rf
    # Add all of the $UNCOMPILED_BRANCH assets into $COMPILED_BRANCH.
    git add --force $PATTERN > /dev/null
  fi
done

# Create a tag
DATE=`date +%Y-%m-%d`
VERSION=0
TAG=${DATE}.${VERSION}
# Check to see if the tag already exists. If so, increment the version.
while git tag|grep ${TAG}; do
  VERSION=$((VERSION+1))
  TAG=${DATE}.${VERSION}
done

# This deletes the old master-compiled. The tags contain the history.
git checkout -B master-compiled --track origin/master-compiled
git add --all
git commit --quiet -m"Deployment for tag ${TAG}"

# Push our branch and tags.
git push origin

# Undo all our changes to the branch.
git reset --hard origin/master
