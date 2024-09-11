# git cheat sheet

## git clone https://repo.git
creates a working directory by cloning a git

## git add file1 file2
adds files to your staging area

## git status
shows if files are not commited yet

## git commit -m "comment"
makes a snapshot and transfers the changes to the local repository

## git push
transfers the changes to the remote repository

## git mv
moves or renames a file in the git enviroment

## git log
shows the history of commits. Exit by pressing "q"

## git diff unique_hash -- filename
shows the changes in a file of a specific commit

## git checkout unique_hash -- filename
restores an older version of a file of a specific commit

## pandoc -o filename.pdf filename.md
creates an pdf out of the markdown file

## git rm filename
removes a file and directly adds the changes

## .gitignore
create .gitignore file to exclude files to be shown in git status

## git checkout -b branchname
creates a new branch

## git commit -m "message"
commits the branch

## git push -u origin branchname
pushes the branch

## git checkout main OR branchname
switches between main and branches

## git merge branchname
while in the main branch, this merges the given branch with the main. To Leave the menu, press ctrl+x and then shift+n.