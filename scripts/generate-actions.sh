#!/bin/sh

CHANGED_DIRS=$1

echo $CHANGED_DIRS;

cd src
VERSIONS=$(ls -d */ | cut -f1 -d'/')

for VERSION in $VERSIONS; do
    cd $VERSION
    DIRECTORIES=$(ls -d */ | cut -f1 -d'/')
    for TAG in $DIRECTORIES; do
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
