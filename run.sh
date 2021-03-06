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
if [[ "$BRANCH" == "MASTER" ]] || [[ $BRANCH =~ ^RELEASE-[0-9]+\.[0-9]+$ ]] || [[ $BRANCH =~ ^RELEASE-[0-9]+$ ]] || [[ $BRANCH == "MASTER-BPR" ]] || [[ $BRANCH =~ "^RELEASE-BPR-[0-9]+\.[0-9]+$" ]] || [[ $BRANCH == "MASTER-REID" ]] || [[ $BRANCH =~ "^RELEASE-REID-[0-9]+\.[0-9]+$" ]]; then
        CHECK_BRANCH=2
fi

if [[ $CHECK_BRANCH == 2 ]];
then
        echo "Master or release"
else
        echo "REPO_USER: $REPO_USER"
        echo "REPO_NAME: $REPO_NAME"
        LAST_PR=$(curl -s -H "Authorization: token $TOKEN" https://api.github.com/repos/$REPO_USER/$REPO_NAME/pulls | jq '.[0] .number')
        echo "Latest PR: ${LAST_PR}"
        MIN_PR=$(( LAST_PR - 40))
        for PR in `seq $LAST_PR -1 $MIN_PR`;
        do
            PR_MESSAGE=$(curl -s -H "Authorization: token $TOKEN" https://api.github.com/repos/$REPO_USER/$REPO_NAME/pulls/$PR/commits | jq ".[] .sha"| tr -d \"| tail -n 1)
            echo "Latest commit for PR: ${PR} is ${PR_MESSAGE}"
            if [[ $COMMIT_MESSAGE == $PR_MESSAGE ]]; then
                FOUND="1"
                break
            fi
        done
        if [[ "${FOUND}" == "1" ]];then
          echo "COMMIT_MESSAGE: ${COMMIT_MESSAGE}"
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
                       echo -e "Found valid ESDT in the commit:\n$ESDT"

                else
                  if [[ $CHECK_BRANCH == 0 ]];
                     then
                         echo "Found invalid branch name: $BRANCH and no valid title: $BODY"
                         echo "The format should be ESDT-[0-9]+ (PR title or branch name) or ESDT-[0-9]+[-_]+.* (branch)"
                         exit 1
                     fi
            fi
          else
            echo "COMMIT_MESSAGE: ${COMMIT_MESSAGE}"
            echo "The PR is not the last 20 PRs"

          fi
        fi
fi

