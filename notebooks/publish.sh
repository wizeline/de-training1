#!/usr/bin/env bash

export ERROR=`tput setaf 1`
export SUCCESS=`tput setaf 2`
export WARNING=`tput setaf 3`
export INFO=`tput setaf 6`
export RESET=`tput sgr0`

if [ -z "$DE_ACADEMY_REPO" ]; then
    echo "${ERROR}ERROR: The environment variable ${INFO}DE_ACADEMY_REPO${ERROR} is not set${RESET}"
    echo "You need to set it to point to the public DE Academy repo (e.g. ${INFO}export DE_ACADEMY_REPO=path${RESET})"
else
    while true; do
        echo $"${WARNING}This command will attempt to commit changes in the ${RESET}${DE_ACADEMY_REPO}${WARNING} \
repository and will invoke the default editor for git${RESET}"

        echo $"${WARNING}We advise you to set the ${RESET}GIT_EDITOR${WARNING} environment variable \
(or run ${RESET}git config --global core.editor "..."${WARNING}) if you haven't already"

        echo $"${WARNING}See the README file for details."
        echo
        read -p "${INFO}You're about to publish notebook changes to the public repository. \
Do you wish to proceed [y/n]? ${RESET}" answer

        case $answer in
            [Yy]* ) break;;
            [Nn]* ) exit;;
            * ) echo "Please answer yes or no.";;
        esac
    done

    cp -r "./public/" "$DE_ACADEMY_REPO/notebooks/"

    pushd "$DE_ACADEMY_REPO"
    git add .
    git commit
    git push origin
    popd
fi
