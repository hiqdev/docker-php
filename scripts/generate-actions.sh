#!/bin/bash

EVENT_NAME=$1
CHANGED_DIRS=$2
PERIODIC_UPDATES_MIN_VERSION=$3

cd src
VERSIONS=$(ls -d */ | cut -f1 -d'/')

for VERSION in $VERSIONS; do
    # if not commit or pull request and version is older than 7.4, do not include it in the matrix
    if [[ $EVENT_NAME != 'pull_request' ]] && [[ $EVENT_NAME != 'push' ]] && [[ $VERSION < $PERIODIC_UPDATES_MIN_VERSION ]]; then
        continue
    fi

    cd $VERSION
    DIRECTORIES=$(ls -d */ | cut -f1 -d'/')
    for TAG in $DIRECTORIES; do
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
