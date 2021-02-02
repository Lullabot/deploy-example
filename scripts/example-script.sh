#!/usr/bin/env bash
set -e

# Configure Git repository.
GIT_URL="git@github.com:mtift/deploy-example.git"
GIT_REMOTE_NAME="acquia"

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
if git remote|grep ${GIT_REMOTE_NAME}; then
  git remote set-url ${GIT_REMOTE_NAME} ${GIT_URL}
else
  git remote add ${GIT_REMOTE_NAME} ${GIT_URL}
fi

# Get the lastest code into master-compiled.
git checkout master
# Accept the default commit message.
git pull ${GIT_REMOTE_NAME} master --no-edit
git checkout master-compiled
git fetch
git merge ${GIT_REMOTE_NAME}/master

# Don't ignore the composer-generated files.
cp -f .gitignore.acquia .gitignore

# Build the theme assets
# npm install
# npm run build

# Install files with composer
composer install --optimize-autoloader

# Clean out all .git dirs from any directories.
for PATTERN in $FORCE_COMMIT_PATTERNS; do
  echo $PATTERN
  if [ -d $PATTERN ]; then
    find $PATTERN -type d -name .git | xargs rm -rf
    # Add all of the master branch assets into master-compiled.
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
git add --all
git tag -a "${TAG}" -m "Compiled code for ${TAG}"
git commit --quiet -m"Deployment for tag ${TAG}"

# Push our branch and tags.
git push --follow-tags

# Switch back to the master branch
git checkout --quiet master

# Replace the ignored files
git checkout ${GIT_REMOTE_NAME}/master -- .gitignore.acquia
git checkout .gitignore
