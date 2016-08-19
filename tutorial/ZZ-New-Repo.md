# Command line instructions #

## Git global setup ##

```
git config --global user.name "Mark Bentley"
git config --global user.email "mark@dimension-systems.com"
```

## Create a new repository ##

```
git clone git@lab-git.dimsys.lab:mark/puppet-training.git
cd puppet-training
touch README.md
git add README.md
git commit -m "add README"
git push -u origin master
```

## Existing folder or Git repository ##

```
cd existing_folder
git init
git remote add origin git@lab-git.dimsys.lab:mark/puppet-training.git
git add .
git commit
git push -u origin master
```

