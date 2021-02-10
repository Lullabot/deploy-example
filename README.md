## Use Case
This is primarily intended for smaller clients that do not the staff or budget
to manage more complex CI implementations, such as CircleCI or GitHub Actions.

The repository provides an example for how to push compiled code to a remote
Git repository, such as Pantheon or Acquia.

## Assumptions
`master` branch is totally update-to-date with changes.

# The process

## Merge master into compiled master.
```
git checkout master-compiled
git pull origin master-compiled
git merge master
```

## Build artifacts.
```
drush build
```

## Run the script to force push.
```
sh scripts/deploy-script.sh
```

## Commit.
```
git add .
git commit -m "Whatever"
git push origin master-compiled
```

## Reset all the things.
```
git checkout master
composer install --optimize-autoloader
drush build
```

## Update database, import config, and clear cache.
```
drush @{site.env} -y updb
drush @{site.env} -y csim
drush @{site.env} cr
```
