#!/bin/bash

###
 # @bash-git-simple-cli A simple Command Line Interface written in BASH and used to maintain Github repositories with Git.
 # @author Craig van Tonder
 # @version 0.0.2
 ##

##### CONSTANTS

# EG: bash-git-simple-cli
REPO_NAME=""
# EG: craigvantonder
USER_NAME=""
# EG: me@mydomain.com
USER_EMAIL=""
# EG: /path/to/id_rsa
SSH_KEY="";

##### END CONSTANTS

# Set the select prompt
PS3='What would you like to do? '

# Define the select options
OPTIONS=(
  "Commit to remote"
  "Merge branches"
  "Show branches"
  "Create branch"
  "Switch to branch"
  "Delete branch"
  "Initialise .git/config"
  "Cancel"
)

# Start the select loop
select opt in "${OPTIONS[@]}"
do
  case $opt in
    # ===============
    # SELECTED COMMIT
    # ===============
    "Commit to remote")
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
      echo "=> Committed to remote"

      break
    ;;

    # ==============
    # MERGE BRANCHES
    # ==============
    "Merge branches")

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
      echo "=> Successfully merged $FROM_BRANCH into $TO_BRANCH"

      break
    ;;

    # ======================
    # SELECTED SHOW BRANCHES
    # ======================
    "Show branches")

      # Show the branches
      git show-branch --list

      break
    ;;

    # ======================
    # SELECTED CREATE BRANCH
    # ======================
    "Create branch")

      # Define the branch name
      echo -n "=> Branch to create: "
      read BRANCH

      # Create the branch
      git checkout -b $BRANCH

      break
    ;;

    # ======================
    # SELECTED SWITCH BRANCH
    # ======================
    "Switch to branch")

      # Define the branch name
      echo -n "=> Branch to switch to: "
      read BRANCH

      # Switch to the branch
      git checkout $BRANCH

      break
    ;;

    # ======================
    # SELECTED DELETE BRANCH
    # ======================
    "Delete branch")

      # Define the branch name
      echo -n "=> Branch to delete: "
      read BRANCH

      echo -n "=> Are you sure you want to delete local and remote \"$BRANCH\"? YES / NO:  "
      read DELETE_BRANCH

      # Define the emailaddress used in conjuction with the SSH key to access github
      if [ -z "$SSH_KEY" ]
      then
        echo -n "Full path of SSH key: "
        read SSH_KEY
        USING_DEFAULTS=false
      fi

      # Prompt that defaults were used
      if [ -z "$USING_DEFAULTS" ]
      then
        echo "=> Using default SSH key"
      fi

      # Define the emailaddress used in conjuction with the SSH key to access github
      if [ $DELETE_BRANCH == "YES" ]
      then
        # Delete the local branch
        git branch -d $BRANCH

        # Fork a copy of ssh-agent and generate Bourne shell commands on stdout
        eval $(ssh-agent -s)

        # Load the ssh key for access to Github
        ssh-add $SSH_KEY

        # Delete the remote branch
        git push origin --delete $BRANCH

        # Kill the ssh-agent process
        pkill ssh-agent

        break
      else
        # Prompt that the task was cancelled
        echo "=> Cancelled "

        break
      fi
    ;;

    # ==========================
    # SELECTED INITIALISE CONFIG
    # ==========================
    "Initialise .git/config")
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

      break
    ;;

    # ===============
    # SELECTED CANCEL
    # ===============
    "Cancel")
      # Prompt that the task was cancelled
      echo "=> Cancelled "

      break
    ;;

    # INPUT WAS NOT WITHIN RANGE OF OPTIONS
    *)
      echo "Invalid option selected!"
    ;;
  esac
done
