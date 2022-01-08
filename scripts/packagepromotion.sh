echo "Starting Script for Package Promotion"

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

PACKAGE_ID=$( q -r 'first(.packageAliases[])' sfdx-project.json )

VERSIONNUMBER=$( jq -r '.packageDirectories[0].versionNumber' sfdx-project.json )
echo "Current Version: $VERSIONNUMBER"
echo "A -1 Number means we are preparing for a .0 release!"

NEWVERSIONNUMBER=$( increment_version $VERSIONNUMBER 2)
NEWPUBLICVERSIONNUMBER="ver. $( cut_patch_version $NEWVERSIONNUMBER)"

echo "New Version Number: $NEWVERSIONNUMBER"

#updates sfdx-project.json with incremented version number and version name 
echo "$( NEWVERSIONNUMBER=$"$NEWVERSIONNUMBER"  jq '.packageDirectories[0].versionNumber = env.NEWVERSIONNUMBER' sfdx-project.json )" > sfdx-project.json
echo "$( NEWPUBLICVERSIONNUMBER=$"$NEWPUBLICVERSIONNUMBER"  jq '.packageDirectories[0].versionName = env.NEWPUBLICVERSIONNUMBER' sfdx-project.json )" > sfdx-project.json

# Create a new package version (with the previously incremented package version) and import the package version id for further use.
echo "Creating new package version"
node_modules/sfdx-cli/bin/run force:package:version:create -p $PACKAGE_ID -f config/project-scratch-def.json -k nordzuckerms123 -c --json -w 30 | jq -r '.result.SubscriberPackageVersionId' > packageversionid.txt

PACKAGEVERSIONID=$( cat packageversionId.txt )
echo "New Package Version Id: $PACKAGEVERSIONID"

#This promotes the package version
echo "Promoting Package Version"
node_modules/sfdx-cli/bin/run force:package:version:promote -p $PACKAGEVERSIONID --noprompt


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
git commit -m "Update Package Version with GitHub Action"
git push
