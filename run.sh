#!/bin/bash

pushd $WERCKER_SOURCE_DIR
BODY=`git log -1 --pretty=format:"%b"`

echo "Pretty"
git log -1 --pretty=format:"%b"
echo "FULL"
git log -1
echo "Var"
BRANCH=$WERCKER_GIT_BRANCH
# convert to uppercase
BRANCH="${BRANCH^^}"
echo $BODY
BODY="${BODY^^}"
if [[ ! $BRANCH =~ ^ESDT-[0-9]+$ ]]; then
        echo "Branch $BRANCH not valid"
        echo "The format should be ESDT-[0-9]+"
        exit 1
fi
echo "Found branch $BRANCH"
ESDT=`echo $BODY| grep  -w -Eo "ESDT-[0-9]+"`
NR_ESDT=`echo $BODY| grep  -w -Eo "ESDT-[0-9]+" | wc -l `
NR_ESDT2=`echo $BODY| grep  -w -Eo "ESDT" | wc -l`
if [[ "$NR_ESDT" -eq "$NR_ESDT2" ]];
then
        echo -e "Found valid ESDT in commit:\n$ESDT"
else
        echo -e "Found non valid ESDT. The format should be ESDT-[0-9]+"
        echo $BODY
        exit 1
fi
