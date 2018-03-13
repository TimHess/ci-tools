#!/bin/bash   

dotnet --info

export CI_BUILD=True
if [[ "$TRAVIS_BRANCH" == "master" ]]; 
then 
	echo "Use dependencies from nuget.org and myget/master"
	nuget sources add -Name SteeltoeMyGetMaster -Source https://www.myget.org/F/oss-ci-master/api/v3/index.json
	#nuget sources add -Name SteeltoeMyGetMaster -Source https://www.myget.org/F/steeltoemaster/api/v3/index.json
elif [[ "$TRAVIS_BRANCH" == "dev" ]]; 
then 
	echo "Use dependencies from nuget.org and myget/dev"
	nuget sources add -Name SteeltoeMyGetDev -Source https://www.myget.org/F/oss-ci-dev/api/v3/index.json
	#nuget sources add -Name SteeltoeMyGetDev -Source https://www.myget.org/F/steeltoedev/api/v3/index.json
elif [[ "${TRAVIS_BRANCH:0:6}" == "update" ]]; 
then 
	echo "Use dependencies from nuget.org and myget/update"
	nuget sources add -Name SteeltoeMyGetUpdates -Source https://www.myget.org/F/steeltoeupdates/api/v3/index.json
else
    echo "No special case detected, just use nuget.org"
fi
