#!/bin/bash

EVENT_NAME=$1
CHANGED_DIRS=$2

cd src
VERSIONS=$(ls -d */ | cut -f1 -d'/')

for VERSION in $VERSIONS; do
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
