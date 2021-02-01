#!/usr/bin/env bash
set -e

git checkout master
git pull
git checkout master-compiled
git fetch
git merge origin/master

mv -f .gitignore.acquia .gitignore

# Build the theme assets
# npm install
# npm run build

# Install files with composer
composer install --optimize-autoloader

# These are the directories or path patterns to force commit.
FORCE_COMMIT_PATTERNS="vendor \
/web/core \
/web/modules/contrib \
/web/themes/contrib \
/web/profiles/contrib \
/web/libraries"

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
git tag -a "${TAG}" -m "Compiled code for ${TAG}"
git commit -m"Deployment for tag ${TAG}"

# Push our branch and tags.
git push --follow-tags

# Switch back to the master branch
git checkout master

# Replace the ignored files
git checkout .gitignore.acquia
git checkout .gitignore

