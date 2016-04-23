BASH GIT SIMPLE CLI
===================

A simple Command Line Interface written in BASH and used to maintain Github repositories with Git.

Tested on Ubuntu Server 14.04.

Requirements:

    # GIT
    sudo apt-get install git
    # SSH-AGENT
    sudo apt-get install ssh-agent

You will also need generate an SSH key and add it to your github account. More information on these subjects can be found in the [Github Documentation](https://help.github.com/articles/generating-an-ssh-key/).

Available options:

1. Commit to remote
2. Refresh local
3. Merge branches
4. Show branches
5. Create branch
6. Switch to branch
7. Delete branch
8. Initialise .git/config
9. Cancel