#!/usr/bin/env bash
set -euo pipefail

echo "Starting script to create new package version"

echo "sf package version create -p PACKAGE_ID -f config/project-scratch-def.json -x -v devhub -c --json -w 50"

PACKAGE_ID=$( jq -r 'first(.packageAliases[])' sfdx-project.json )

sf package version create  -p $PACKAGE_ID -f config/project-scratch-def.json -x -v devhub -c --json -w 50 > result.json

cat result.json | jq -r '.result.SubscriberPackageVersionId' > packgeversionid.txt

PACKAGEVERSIONID=$( cat packgeversionid.txt )
if [[ "$PACKAGEVERSIONID" == "null" ]]; then    
    echo "Package version could not be created (likely due to limits)"
    exit 1
fi

echo "New Package Version Id: $PACKAGEVERSIONID"

echo "Updating docs"
#updates docs with new installation id
sed -i "s/04t.\{15\}/$PACKAGEVERSIONID/g" docs/installation.md

#updates README with new installation id
sed -i "s/04t.\{15\}/$PACKAGEVERSIONID/g" README.md

git add docs/installation.md
git add README.md
git add sfdx-project.json
git config --local user.email "action@github.com"
git config --local user.name "GitHub Action Bot"
git commit -m "Update Package Version sfdx-project.json, README and Installation Docs"
git push

LATEST_HASH=$(git rev-parse HEAD)

curl \
  -X POST \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  https://api.github.com/repos/$REPO_NAME/statuses/$LATEST_HASH \
  -d '{"state":"success", "description": "Build success", "context": "build"}'

  exit 0