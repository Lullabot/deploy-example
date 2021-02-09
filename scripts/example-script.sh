#!/usr/bin/env bash

#############
# CONFIGURE #
#############

# Configure Git repository.
GIT_URL="git@github.com:Lullabot/deploy-example.git"
GIT_REMOTE_NAME="origin"
UNCOMPILED_BRANCH="master"
COMPILED_BRANCH="master-compiled"

# Directories or path patterns to force commit.
FORCE_COMMIT_PATTERNS="vendor \
web/core \
web/modules/contrib \
web/themes/contrib \
web/themes/custom/deploy_example_theme/css \
web/themes/custom/deploy_example_theme/js \
web/themes/custom/deploy_example_theme/node_modules \
web/profiles/contrib \
web/libraries"

# Warning message.
read -r -p "Are you sure you want to update the ${COMPILED_BRANCH} and create a new tag? <y/N> " INPUT
case $INPUT in
    [yY][eE][sS]|[yY])
 echo "Proceeding with deployment"
 ;;
    [nN][oO]|[nN])
 echo "Aborting deployment"
       ;;
    *)
 echo "Aborting deployment"
 exit 1
 ;;
esac

# Make sure the repo exists as a remote.
if git remote|grep $GIT_REMOTE_NAME; then
  git remote set-url $GIT_REMOTE_NAME $GIT_URL
else
  git remote add $GIT_REMOTE_NAME $GIT_URL
fi

# Make sure $UNCOMPILED_BRANCH is clean.
git checkout $UNCOMPILED_BRANCH
git fetch $GIT_REMOTE_NAME

# Checkout that the branch is clean
FILES=`git diff --name-only`
if [ ! -z "$FILES" ]; then
  echo "\n>> Aborted deployment. Please clean up the ${UNCOMPILED_BRANCH} branch."
  exit 1
fi


#########
# BUILD #
#########

build_local() {

  # Build the theme assets
  ( cd web/themes/custom/deploy_example_theme && npm install )

  if [ ! -d "web/themes/custom/deploy_example_theme/js" ]; then
    mkdir web/themes/custom/deploy_example_theme/js
  fi
  if [ ! -d "web/themes/custom/deploy_example_theme/css" ]; then
    mkdir web/themes/custom/deploy_example_theme/css
  fi

  ( cd web/themes/custom/deploy_example_theme && npm run build )

  # Install files with composer
  composer install --optimize-autoloader &> /dev/null

}

build_local

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
    git add --force $PATTERN &> /dev/null
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

# Create a temporary branch to store the assets.
# TODO: There might be a better way to do this, but for now this works.
git checkout -b $TAG
git add --all
git commit --quiet -m"Deployment for tag ${TAG}"

# Add the the changes in the $TAG branch to the $COMPILED_BRANCH.
git checkout $COMPILED_BRANCH
git checkout $TAG -- .
git commit --quiet -m"Deployment for tag ${TAG}"
git tag -a "${TAG}" -m "Compiled code for ${TAG}."
git branch -D $TAG

# Push our branch and tags.
git push --follow-tags origin

# Get back to where we started.
git checkout $UNCOMPILED_BRANCH
build_local

echo "\nComplete! Updated the ${COMPILED_BRANCH} branch and created a new tag ${TAG}"
