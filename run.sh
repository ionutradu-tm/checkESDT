#!/bin/bash

pushd $WERCKER_SOURCE_DIR
BODY=`git log -1 --pretty='%s'`

BRANCH=$WERCKER_GIT_BRANCH
# convert to uppercase
BRANCH=$(basename $BRANCH)
BRANCH="${BRANCH^^}"
BODY="${BODY^^}"
CHECK_BRANCH=1
if [[ $BRANCH =~ ^ESDT-[0-9]+$ ]] || [[ "$BRANCH" == "MASTER" ]] || [[ $BRANCH =~ ^RELEASE-[0-9]+\.[0-9]+$ ]] || [[ $BRANCH =~ ^ESDT-[0-9]+[_-]+.*$ ]]; then
        CHECK_BRANCH=0
fi
echo "CHECK_BRANCH: $CHECK_BRANCH"
ESDT=`echo $BODY| grep  -w -Eo "ESDT-[0-9]+"`
NR_ESDT=`echo $BODY| grep  -w -Eo "ESDT-[0-9]+" | wc -l `
NR_ESDT2=`echo $BODY| grep  -w -Eo "ESDT" | wc -l`
if [[ $NR_ESDT != 0 ]];
   then
      if [[ "$NR_ESDT" -eq "$NR_ESDT2" ]];
         then
             echo -e "Found valid ESDT in commit:\n$ESDT"
         else
             echo -e "Found non valid ESDT. The format should be ESDT-[0-9]+"
             echo $BODY
             exit 0
       fi
   else
       if [[ $CHECK_BRANCH == 1 ]];
          then
             echo "Found invalid branch $BRANCH and no valid message"
             echo "The format should be ESDT-[0-9]+"
             exit 0
       fi
fi
