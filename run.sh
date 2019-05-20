#!/bin/bash

pushd $WERCKER_SOURCE_DIR
BODY=`git log -1 --pretty='%s'`

BODY2=`git log -2`

BRANCH=$WERCKER_GIT_BRANCH
# convert to uppercase
BRANCH=$(basename $BRANCH)
BRANCH="${BRANCH^^}"
BODY="${BODY^^}"
CHECK_BRANCH=0
echo "Title: $BODY"
echo "Full: $BODY2"
if [[ $BRANCH =~ ^ESDT-[0-9]+$ ]] || [[ $BRANCH =~ ^ESDT-[0-9]+[_-]+.*$ ]]; then
        CHECK_BRANCH=1
fi
if [[ "$BRANCH" == "MASTER" ]] || [[ $BRANCH =~ ^RELEASE-[0-9]+\.[0-9]+$ ]]; then
        CHECK_BRANCH=2
fi

if [[ $CHECK_BRANCH == 2 ]];
then
        echo "Master or release"
else
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

