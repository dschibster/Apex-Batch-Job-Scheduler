#!/usr/bin/env bash
set -euo pipefail

echo "Incrementing Package Version"

increment_version() {
    local delimiter=.
    local array=($(echo "$1" | tr $delimiter '\n'))
    array[$2]=$((array[$2]+1))
    if [ $2 -lt 2 ]; then array[2]=0; fi
    if [ $2 -lt 1 ]; then array[1]=0; fi
    echo $(local IFS=$delimiter ; echo "${array[*]}")
}

cut_patch_version(){
    local delimiter=.
    local array=($(echo "$1" | tr $delimiter '\n'))
    unset array[3]
    echo $(local IFS=$delimiter ; echo "${array[*]}")
}



VERSIONNUMBER=$( jq -r '.packageDirectories[0].versionNumber' sfdx-project.json )
echo "Current Version: $VERSIONNUMBER"
echo "A -1 Number means we are preparing for a .0 release!"

NEWVERSIONNUMBER=$( increment_version $VERSIONNUMBER 2)
NEWPUBLICVERSIONNUMBER="ver. $( cut_patch_version $NEWVERSIONNUMBER)"

echo "New Version Number: $NEWVERSIONNUMBER"

#updates sfdx-project.json with incremented version number and version name 
echo "$( NEWVERSIONNUMBER=$"$NEWVERSIONNUMBER"  jq '.packageDirectories[0].versionNumber = env.NEWVERSIONNUMBER' sfdx-project.json )" > sfdx-project.json
echo "$( NEWPUBLICVERSIONNUMBER=$"$NEWPUBLICVERSIONNUMBER"  jq '.packageDirectories[0].versionName = env.NEWPUBLICVERSIONNUMBER' sfdx-project.json )" > sfdx-project.json

git add sfdx-project.json
git config --local user.email "action@github.com"
git config --local user.name "GitHub Action Bot"
git commit -m "Increment Package Version after opened Pull Request"
git push
exit 0