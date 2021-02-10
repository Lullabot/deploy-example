#!/usr/bin/env bash

#############
# CONFIGURE #
#############

drush build

# Directories or path patterns to force commit.
FORCE_COMMIT_PATTERNS="vendor \
web/core \
web/modules/contrib \
web/themes/contrib \
web/profiles/contrib \
web/libraries \
web/themes/custom/deploy_example_theme/css \
web/themes/custom/deploy_example_theme/js \
web/themes/custom/deploy_example_theme/node_modules"

# Clean out all .git dirs from any directories.
for PATTERN in $FORCE_COMMIT_PATTERNS; do
  echo "Force push to $PATTERN"
  if [ -d $PATTERN ]; then
    find $PATTERN -type d -name .git | xargs rm -rf
    git add --force $PATTERN &> /dev/null
    sleep 5
  fi
done

git status

echo "\nComplete! The master-compiled branch is ready for verification"
