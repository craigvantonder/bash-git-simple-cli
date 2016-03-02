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
2. Merge branches
3. Show branches
4. Create branch
5. Switch to branch
6. Delete branch
7. Initialise .git/config
8. Cancel