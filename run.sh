#!/bin/bash

pushd $WERCKER_SOURCE_DIR

REPO_USER=$WERCKER_CHECK_ESDT_REPO_USER
REPO_NAME=$WERCKER_CHECK_ESDT_REPO_NAME
TOKEN=$WERCKER_CHECK_ESDT_TOKEN

#install jq
apt-get -y update
apt-get -y install jq
COMMIT_MESSAGE=`git log -1 --pretty='%H'`

BRANCH=$WERCKER_GIT_BRANCH
# convert to uppercase
BRANCH=$(basename $BRANCH)
BRANCH="${BRANCH^^}"
CHECK_BRANCH=0

if [[ $BRANCH =~ ^ESDT-[0-9]+$ ]] || [[ $BRANCH =~ ^ESDT-[0-9]+[_-]+.*$ ]]; then
        CHECK_BRANCH=1
fi
if [[ "$BRANCH" == "MASTER" ]] || [[ $BRANCH =~ ^RELEASE-[0-9]+\.[0-9]+$ ]] || [[ $BRANCH =~ ^RELEASE-[0-9]+$ ]] || [[ $BRANCH == "NOCACHEREBUILD" ]]; then
        CHECK_BRANCH=2
fi

if [[ $CHECK_BRANCH == 2 ]];
then
        echo "Master or release"
else
        echo "REPO_USER: $REPO_USER"
        echo "REPO_NAME: $REPO_NAME"
        LAST_PR=$(curl -s -H "Authorization: token $TOKEN" https://api.github.com/repos/$REPO_USER/$REPO_NAME/pulls | jq '.[0] .number')
        MIN_PR=$(( LAST_PR - 20))
        for PR in `seq $LAST_PR -1 $MIN_PR`;
        do
            PR_MESSAGE=$(curl -s -H "Authorization: token $TOKEN" https://api.github.com/repos/$REPO_USER/$REPO_NAME/pulls/$PR/commits | jq ".[0] .sha"| tr -d \")
            if [[ $COMMIT_MESSAGE == $PR_MESSAGE ]]; then
                break
            fi
        done
        echo "PR: $PR"
        TITLE=$(curl -s -H "Authorization: token $TOKEN" https://api.github.com/repos/$REPO_USER/$REPO_NAME/pulls/$PR | jq ".title"| tr -d \")
        echo "PR TITLE: $TITLE"
        BODY="${TITLE^^}"
        ESDT=`echo $BODY| grep  -w -Eo "ESDT-[0-9]+"`
        NR_ESDT=`echo $BODY| grep  -w -Eo "ESDT-[0-9]+" | wc -l `
        NR_ESDT2=`echo $BODY| grep  -w -Eo "ESDT" | wc -l`
        NR_NUMBERS=`echo $BODY|  grep -w -Eo "[0-9]+" | wc -l`
        if [[ $NR_ESDT != 0 ]] ;
           then
              if [[ "$NR_ESDT" -eq "$NR_ESDT2" ]] && [[ "$NR_NUMBERS" -eq "$NR_ESDT" ]];
                 then
                     echo -e "Found valid ESDT in commit:\n$ESDT"
              else
                     echo -e "Found non valid ESDT in title. The format should be ESDT-[0-9]+ ESDT-[0-9\+"
                     echo $BODY
                     exit 1
              fi
            else
              if [[ $CHECK_BRANCH == 0 ]];
                 then
                     echo "Found invalid branch $BRANCH and no valid title $BODY"
                     echo "The format should be ESDT-[0-9]+ (PR title or branch name) or ESDT-[0-9]+[-_]+.* (branch)"
                     exit 1
                 fi
        fi

fi

