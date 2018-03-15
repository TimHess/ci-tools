#!/bin/bash   

dotnet --info

export CI_BUILD=True
if [[ "$TRAVIS_BRANCH" == "master" ]]; 
then 
	echo "Use dependencies from nuget.org and myget/master"
	export MyGet_Feed="oss-ci-master"
	#nuget sources add -Name SteeltoeMyGetMaster -Source https://www.myget.org/F/oss-ci-master/api/v3/index.json
	#nuget sources add -Name SteeltoeMyGetMaster -Source https://www.myget.org/F/steeltoemaster/api/v3/index.json
elif [[ "$TRAVIS_BRANCH" == "dev" ]]; 
then 
	echo "Use dependencies from nuget.org and myget/dev"
	export MyGet_Feed="oss-ci-dev"
	#nuget sources add -Name SteeltoeMyGetDev -Source https://www.myget.org/F/oss-ci-dev/api/v3/index.json
	#nuget sources add -Name SteeltoeMyGetDev -Source https://www.myget.org/F/steeltoedev/api/v3/index.json
elif [[ "${TRAVIS_BRANCH:0:6}" == "update" ]]; 
then 
	echo "Use dependencies from nuget.org and myget/update"
	export MyGet_Feed="oss-ci-update"
	#nuget sources add -Name SteeltoeMyGetUpdates -Source https://www.myget.org/F/steeltoeupdates/api/v3/index.json
else
    echo "No special case detected, just use nuget.org"
fi

if [[ $MyGet_Feed ]];
then
	# write out a nuget config file
	cat > nuget.config <<EOF 
<?xml version="1.0" encoding="utf-8"?>
<configuration>
<packageSources>
	<add key="Steeltoe" value="https://www.myget.org/F/$MyGet_Feed/api/v3/index.json" />
	<add key="NuGet" value="https://api.nuget.org/v3/index.json" />
</packageSources>
</configuration>
EOF
	export NuGetConfigSwitch="--configfile ../../nuget.config"
fi