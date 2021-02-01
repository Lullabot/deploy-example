#!/usr/bin/env bash
set -e

git checkout master
git pull
git checkout master-compiled
git fetch
git merge origin/master

# Build the theme assets
npm install
npm run build

# Install files with composer
composer install --optimize-autoloader

# These are the directories or path patterns to force commit.
FORCE_COMMIT_PATTERNS="vendor \
/docroot/core \
/docroot/modules/contrib \
/docroot/themes/contrib \
/docroot/themes/custom/elluciantheme/dist \
/docroot/profiles/contrib \
/docroot/libraries"

# Clean out all .git dirs from any directories.
for PATTERN in $FORCE_COMMIT_PATTERNS; do
  echo $PATTERN
  if [[ -d $PATTERN ]]; then
    find $PATTERN -type d -name .git | xargs rm -rf
    # Add all of the master branch assets into master-compiled.
    git add --force $PATTERN > /dev/null
  fi
done

# Create a tag
DATE=`date +%Y-%m-%d`
TAG_SUFFIX=0
git tag -a "${DATE}.${TAG_SUFFIX}" -m "Compiled code for ${DATE}.${TAG_SUFFIX}"
git commit -m"Deployment for tag ${DATE}.${TAG_SUFFIX}"

# Undo all our changes to the branch.
git push