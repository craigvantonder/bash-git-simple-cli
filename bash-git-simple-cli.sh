#!/bin/bash

# bash-git-simple-cli - A simple Command Line Interface written in bash for maintaining Github repositories with Git.

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
  "Initialise .git/config"
  "Commit to master"
  "Cancel"
)

# Start the select loop
select opt in "${OPTIONS[@]}"
do
  case $opt in
    # SELECTED INITIALISE CONFIG
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

    # SELECTED COMMIT
    "Commit to master")
      # Started task
      echo "=> Committing to master..."

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
      git push origin master

      # Kill the ssh-agent process
      pkill ssh-agent

      # Ended task
      echo "=> Committed to master"

      break
    ;;

    # SELECTED CANCEL
    "Cancel")
      break
    ;;

    # INPUT WAS NOT WITHIN RANGE OF OPTIONS
    *)
      echo "Invalid option selected!"
    ;;
  esac
done