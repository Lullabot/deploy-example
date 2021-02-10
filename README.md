## Use Case
This is primarily intended for smaller clients that do not the staff or budget
to manage more complex CI implementations, such as CircleCI or GitHub Actions.

The repository provides an example for how to push compiled code to a remote
Git repository, such as Pantheon or Acquia.

## Assumptions
`master` branch is totally update-to-date with changes

# The process
(yes, involves a lot of manual steps)

## Check that master is all nice and clean
```
git checkout master
git pull origin master
git push origin master
```

## Merge master into compiled master
```
git checkout master-compiled
git pull origin master-compiled
git push origin master-compiled
git fetch
git merge origin/master
```

## Make sure the js and css directories exist
```
mkdir -p web/themes/custom/deploy_example_theme/js
mkdir -p web/themes/custom/deploy_example_theme/css
mkdir -p web/themes/custom/deploy_example_theme/node_modules
```

# Run the script
```
sh scripts/deploy-script.sh
```

## Commit
```
git add .
git commit -m "Whatever"
git push
```

## Reset all the things
```
git checkout master
composer install --optimize-autoloader
(cd web/themes/custom/deploy_example_theme && npm install)
(cd web/themes/custom/deploy_example_theme && npm run build)
```

## Update database, import config, clear cache
```
drush @{site.env} -y updb
drush @{site.env} -y csim
drush @{site.env} cr
```
