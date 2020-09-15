#!/bin/bash

echo "source branch: ${SOURCE_BRANCH}"
echo "dest branch: ${DEST_BRANCH}"
echo "PR Title: ${PR_TITLE}"
echo "Prefix branch format: ${FORMAT_PREFIX_BRANCH}"
echo "Project names ${PROJECT_NAMES}"
echo "Allow branch names: ${ALLOW_SOURCE_BRANCHES}"

shopt -s nocasematch
PREFIX_BRANCH=$(dirname ${SOURCE_BRANCH})
SUFFIX_BRANCH="$(basename ${BRANCH})"

# allows master and release branches as source branch
if [[ ! "${SOURCE_BRANCH}" =~ ^(${ALLOW_SOURCE_BRANCHES})$ ]]; then
  # check branch name prefix
  if [[ "${PREFIX_BRANCH}" != "." ]]; then
    if [[ ! "${PREFIX_BRANCH}" =~ ^(${FORMAT_PREFIX_BRANCH})$ ]]; then
      echo "Found invalid branch name: ${SOURCE_BRANCH}"
      echo "The format should be ${FORMAT_PREFIX_BRANCH}/${PROJECT_NAMES}-[0-9]+ or ${PROJECT_NAMES}-[0-9]+"
      exit 1
    fi
  fi
  # end check

  # check branch name suffix
  if [[ ! "${SUFFIX_BRANCH}" =~ ^((${PROJECT_NAMES})+\-[0-9]+)$ ]]; then
    echo "Found invalid branch name: ${SOURCE_BRANCH}"
    echo "The format should be ${FORMANT_PREFIX_BRANCH}/${PROJECT_NAMES}-[0-9]+ or ${PROJECT_NAMES}-[0-9]+"
    exit 2
  fi
  # check PR title
  NR_PROJECTS=$(echo ${PR_TITLE} | grep -w -Eo "(${PROJECT_NAMES})+-[0-9]+" | wc -l)
  NR_PROJECT_NAMES=$(echo ${PR_TITLE} | grep -w -Eo "(${PROJECT_NAMES})+" | wc -l)
  NR_PROJECT_NUMBERS=$(echo ${PR_TITLE} | grep -w -Eo "[0-9]+" | wc -l)
  if [[ "${NR_PROJECT_NAMES}" -ne "${NR_PROJECT_NUMBERS}" ]] || [[ "${NR_PROJECTS}" -eq "0" ]]; then
    echo "Found invalid PR title, the format should be (${PROJECT_NAME})+-[0-9]+ and no additional numbers are allowed"
    exit 3
  fi
  # end check
else
  echo "Allowed source branches"
fi
