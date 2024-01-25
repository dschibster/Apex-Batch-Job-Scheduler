#!/usr/bin/env bash
set -euo pipefail

PACKAGEVERSIONID=$( jq -r 'last(.packageAliases[])' sfdx-project.json )

echo "Promoting latest package version"

echo "sf package version promote -p PACKAGE_VERSION_ID --no-prompt -v devhub"
sf package version promote -p $PACKAGEVERSIONID --no-prompt -v devhub


