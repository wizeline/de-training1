#!/bin/bash

ERROR=`tput setaf 1`
SUCCESS=`tput setaf 2`
WARNING=`tput setaf 3`
INFO=`tput setaf 6`
RESET=`tput sgr0`

VIRTUALENV_NAME=de-training

# make virtualenvwrapper commands available
source "$HOME/.bashrc"
source "$HOME/.bash_profile"

VIRTUALENVWRAPPER_INSTALLED=`command -v mkvirtualenv`
if [ -z "$VIRTUALENVWRAPPER_INSTALLED" ]; then
    echo "${ERROR}ERROR: You must have ${INFO}virtualenvwrapper${ERROR} to set up this project.${RESET}"
    echo "Please check ${INFO}https://docs.python-guide.org/dev/virtualenvs/${RESET} for instructions on how to install it."
    exit
fi

echo "${INFO}Creating virtual environment... ${RESET}"
mkvirtualenv --python=python3 $VIRTUALENV_NAME \
              -a . # associate this directory with the virtual environment
echo "${SUCCESS}Virtual environment installed! ${RESET}"

echo "${INFO}Installing dependencies... ${RESET}"
pip install -r requirements.txt
echo "${SUCCESS}Dependencies installed! ${RESET}"

echo "${INFO}Installing git pre-commit hooks... ${RESET}"
workon $VIRTUALENV_NAME
pre-commit install
deactivate
echo "${SUCCESS}Git pre-commit hooks installed! ${RESET}"

echo -n "${SUCCESS}You're all set. You can start working by running -> ${RESET}"
echo "${INFO}workon $VIRTUALENV_NAME ${RESET}"

