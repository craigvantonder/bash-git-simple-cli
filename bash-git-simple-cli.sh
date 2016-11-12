#!/bin/bash

###
 # @bash-git-simple-cli A simple Command Line Interface written in BASH and used to maintain Github repositories with Git.
 # @author Craig van Tonder
 # @version 0.0.7
 ##

##### CONSTANTS

# EG: bash-git-simple-cli
REPO_NAME=""
# EG: craigvantonder
USER_NAME=""
# EG: me@mydomain.com
USER_EMAIL=""
# EG: /path/to/id_rsa
SSH_KEY=""

##### END CONSTANTS

# Set the select prompt
PS3='What would you like to do? '

# Define the select options
OPTIONS=(
  "Commit to remote"
  "Stop tracking file"
  "Refresh local"
  "Merge branches"
  "Show branches"
  "Create branch"
  "Switch to branch"
  "Delete branch"
  "Initialise .git/config"
  "Cancel"
)

# Create a function that shows the menu and echoes the users choice
# http://stackoverflow.com/a/35854852/2110294
function show_menu {
  select option in "${OPTIONS[@]}"; do
    echo $option
    break
  done
}

# We can wrap that function in a loop, and only break out if the user picked Cancel
while true; do
  option=$(show_menu)

  # =========================
  # SELECTED COMMIT TO REMOTE
  # =========================
  if [[ $option == "Commit to remote" ]]; then
    # Started task
    echo "=> Committing to remote..."

    # Define the emailaddress used in conjuction with the SSH key to access github
    if [ -z "$SSH_KEY" ]
    then
      echo -n "Full path of SSH key: "
      read SSH_KEY
      USING_DEFAULTS=false
    fi

    # Define the emailaddress used in conjuction with the SSH key to access github
    echo -n "Branch to commit to: "
    read BRANCH

    # Prompt that defaults were used
    if [ -z "$USING_DEFAULTS" ]
    then
      echo "=> Using default SSH key"
    fi

    # Define the select message
    echo -n "Commit message: "
    read message

    # Add the changes to the index
    git add -A

    # Commit the changes
    git commit --interactive -m "$message"

    # Fork a copy of ssh-agent and generate Bourne shell commands on stdout
    eval $(ssh-agent -s)

    # Load the ssh key for access to Github
    ssh-add $SSH_KEY

    # Changes are currently in the HEAD of your local working copy
    # so send those changes to your remote repository
    git push origin $BRANCH

    # Kill the ssh-agent process
    pkill ssh-agent

    # Ended task
    echo "Successfully committed to remote!"
    echo "What would you like to do next?"
  fi

  # ======================
  # SELECTED STOP TRACKING
  # ======================
  if [[ $option == "Stop tracking file" ]]; then
    # Prompt the user to confirm that the refresh will happen (could lose changes)
    echo -n "File to stop tracking? (relative path): "
    read STOP_TRACKING_FILE

    # Stop tracking the specified file
    git rm --cached $STOP_TRACKING_FILE

    # Ended task
    echo "What would you like to do next?"
  fi

  # ================
  # SELECTED REFRESH
  # ================
  if [[ $option == "Refresh local" ]]; then
    # Prompt the user to confirm that the refresh will happen (could lose changes)
    echo -n "=> Are you sure you want to refresh? (y/n): "
    read CONFIRM_REFRESH

    # If we are going to refresh with remote
    if [ $CONFIRM_REFRESH == "y" ]
    then
      # Started task
      echo "=> Refreshing local repository..."

       # Fork a copy of ssh-agent and generate Bourne shell commands on stdout
      eval $(ssh-agent -s)

      # Load the ssh key for access to Github
      ssh-add $SSH_KEY

      # Fetch the latest commit from remote
      git fetch origin master;

      # Kill the ssh-agent process
      pkill ssh-agent;

      # Reset to the latest commit
      git reset --hard FETCH_HEAD;

      # Clean up any excess files that are not in the latest commit
      git clean -df;

      # Ended task
      echo "What would you like to do next?"
    fi

    # If we are not going to refresh
    if [ $CONFIRM_REFRESH == "n" ]
    then
      # Prompt that the task was cancelled
      echo "=> Cancelled..."
    fi
  fi

  # =======================
  # SELECTED MERGE BRANCHES
  # =======================
  if [[ $option == "Merge branches" ]]; then
    # Define the branch to name
    echo -n "=> Merging to branch: "
    read TO_BRANCH

    # Define the branch from name
    echo -n "=> Merging changes from branch: "
    read FROM_BRANCH

    # Switch to master
    git checkout $TO_BRANCH

    # Merge the branch into master
    git merge --squash $FROM_BRANCH

    # Ended task
    echo "Successfully merged $FROM_BRANCH into $TO_BRANCH"
    echo "What would you like to do next?"
  fi

  # ======================
  # SELECTED SHOW BRANCHES
  # ======================
  if [[ $option == "Show branches" ]]; then
    # Show the branches
    git show-branch --list

    # Ended task
    echo "What would you like to do next?"
  fi

  # ======================
  # SELECTED CREATE BRANCH
  # ======================
  if [[ $option == "Create branch" ]]; then
    # Define the branch name
    echo -n "=> Branch to create: "
    read BRANCH

    # Create the branch
    git checkout -b $BRANCH

    # Ended task
    echo "What would you like to do next?"
  fi

  # ======================
  # SELECTED SWITCH BRANCH
  # ======================
  if [[ $option == "Switch to branch" ]]; then
    # Define the branch name
    echo -n "=> Branch to switch to: "
    read BRANCH

    # Switch to the branch
    git checkout $BRANCH

    # Ended task
    echo "What would you like to do next?"
  fi

  # ======================
  # SELECTED DELETE BRANCH
  # ======================
  if [[ $option == "Delete branch" ]]; then
    # Define the branch name
    echo -n "=> Branch name to delete: "
    read BRANCH

    echo -n "=> Delete local branch: \"$BRANCH\"? (y/n): "
    read DELETE_LOCAL_BRANCH
    echo -n "=> Delete remote branch: \"$BRANCH\"? (y/n): "
    read DELETE_REMOTE_BRANCH

    # Define the email address used in conjuction with the SSH key to access github
    if [ -z "$SSH_KEY" ]
    then
      echo -n "=> Full path of SSH key: "
      read SSH_KEY
      USING_DEFAULTS=false
    fi

    # Prompt that defaults were used
    if [ -z "$USING_DEFAULTS" ]
    then
      echo "=> Using default SSH key"
    fi

    # If we are going to delete the local branch
    if [ $DELETE_LOCAL_BRANCH == "y" ]
    then
      # Started task
      echo "=> Deleting local branch..."
      # Delete the local branch
      git branch -D $BRANCH
    fi

    # If we are going to delete the remote branch
    if [ $DELETE_REMOTE_BRANCH == "y" ]
    then
      # Started task
      echo "=> Deleting remote branch..."

      # Fork a copy of ssh-agent and generate Bourne shell commands on stdout
      eval $(ssh-agent -s)

      # Load the ssh key for access to Github
      ssh-add $SSH_KEY

      # Delete the remote branch
      git push origin --delete $BRANCH

      # Kill the ssh-agent process
      pkill ssh-agent
    fi

    # If both options were no
    if [ $DELETE_LOCAL_BRANCH == "n" ] && [ $DELETE_REMOTE_BRANCH == "n" ]
    then
      # Prompt that the task was cancelled
      echo "=> Cancelled..."
    fi

    # Ended task
    echo "What would you like to do next?"
  fi

  # ==========================
  # SELECTED INITIALISE CONFIG
  # ==========================
  if [[ $option == "Initialise .git/config" ]]; then
    # Started task
    echo "=> Initialising .git/config..."

    # Define the name used to create the repository on Github
    if [ -z "$REPO_NAME" ]
    then
      echo -n "Repository name: "
      read REPO_NAME
      # Trigger using defaults prompt
      USING_DEFAULTS=false
    fi

    # Define the username used in conjuction with the email address for Github collaborators
    if [ -z "$USER_NAME" ]
    then
      echo -n "Github username: "
      read USER_NAME
      USING_DEFAULTS=false
    fi

    # Define the emailaddress used in conjuction with the SSH key to access github
    if [ -z "$USER_EMAIL" ]
    then
      echo -n "Email address: "
      read USER_EMAIL
      USING_DEFAULTS=false
    fi

    # Prompt that defaults were used
    if [ -z "$USING_DEFAULTS" ]
    then
      echo "=> Using constant defaults"
    fi

    # Echo in the basic configuration for git to use
    echo "[core]
      repositoryformatversion = 0
      filemode = true
      bare = false
      logallrefupdates = true
[remote \"origin\"]
      url = git@github.com:$USER_NAME/$REPO_NAME.git
      fetch = +refs/heads/*:refs/remotes/origin/*
[branch \"master\"]
      remote = origin
      merge = refs/heads/master
[user]
      name = $USER_NAME
      email = $USER_EMAIL" > .git/config

    # Ended task
    echo "=> Initialised .git/config"
    echo "What would you like to do next?"
  fi

  # ===============
  # SELECTED CANCEL
  # ===============
  if [[ $option == "Cancel" ]]; then
    break
  fi

  # =====================================
  # INPUT WAS NOT WITHIN RANGE OF OPTIONS
  # =====================================
  # if [ !$option == "Commit to remote" ] &&
  #      [ !$option == "Refresh local" ] &&
  #      [ !$option == "Merge branches" ] &&
  #      [ !$option == "Show branches" ] &&
  #      [ !$option == "Create branch" ] &&
  #      [ !$option == "Switch to branch" ] &&
  #      [ !$option == "Delete branch" ] &&
  #      [ !$option == "Initialise .git/config" ] &&
  #      [ !$option == "Cancel" ]; then
  #   echo "Invalid option selected!"
  # fi

done
