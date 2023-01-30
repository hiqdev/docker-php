#!/bin/bash

EVENT_NAME=$1
CHANGED_DIRS=$2
PERIODIC_UPDATES_MIN_VERSION=$3

cd src
VERSIONS=$(ls -d */ | cut -f1 -d'/')

for VERSION in $VERSIONS; do
    # Do not include versions that are not supported by periodic updates
    if [[ $EVENT_NAME == 'schedule' ]] && [[ $VERSION < $PERIODIC_UPDATES_MIN_VERSION ]]; then
        continue
    fi

    cd $VERSION
    DIRECTORIES=$(ls -d */ | cut -f1 -d'/')
    for TAG in $DIRECTORIES; do
        # if a pull request and no files changed in the dir, do not include it in the matrix
        CHANGED_FILES_COUNT=$(echo $CHANGED_DIRS | jq ".[] | select(. | contains(\"src/$VERSION/$TAG/\"))" | wc -l)
        if [[ $EVENT_NAME == 'pull_request' ]] && [[ $CHANGED_FILES_COUNT -eq 0 ]]; then
            continue
        fi
        jq --null-input \
          --arg php "$VERSION" \
          --arg tag "$TAG" \
          '{"name": ($php + "-" + $tag), "php": $php, "tag": $tag}'
     done
     cd ../
done | jq -cs '
		{
			"fail-fast": false,
			matrix: { include: . },
		}
'
