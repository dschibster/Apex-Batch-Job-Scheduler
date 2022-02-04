#!/usr/bin/env bash
set -euo pipefail

PACKAGEVERSIONID=$( jq -r 'last(.packageAliases[])' sfdx-project.json )

echo "Promoting latest package version"

echo "sfdx force:package:version:promote -p PACKAGE_VERSION_ID --noprompt -v devhub"
sfdx force:package:version:promote -p $PACKAGEVERSIONID --noprompt -v devhub


