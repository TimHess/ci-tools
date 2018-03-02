cd src
If ($env:ProjectList -eq $null){
	Write-Host "env:ProjectList was not defined - discover and build projects alphabetically"
	$env:ProjectList = Get-ChildItem -Directory 
}
# build each project in the src folder
ForEach ($_ in $env:ProjectList.Split(' ')) {
	Write-Host "Now building $_..."
	cd $_

	dotnet restore

	# if there is a tag with the latest commit don't include symbols or source
	If ($env:APPVEYOR_REPO_TAG_NAME)
	{
		Write-Host "Creating package $_.$env:STEELTOE_VERSION$env:STEELTOE_DASH_VERSION_SUFFIX without symbols"
		dotnet pack --configuration $env:BUILD_TYPE /p:Version=$env:STEELTOE_VERSION$env:STEELTOE_DASH_VERSION_SUFFIX
	}
	Else
	{
		Write-Host "Creating package $_.$env:STEELTOE_VERSION$env:STEELTOE_DASH_VERSION_SUFFIX with symbols"
		# include symbols and source
		dotnet pack --configuration $env:BUILD_TYPE /p:Version=$env:STEELTOE_VERSION$env:STEELTOE_DASH_VERSION_SUFFIX --include-symbols --include-source
	}
	# send package to local feed for use within this build
	Write-Host "Adding package to local feed for use within this build..."
	nuget add bin\$env:BUILD_TYPE\$_.$env:STEELTOE_VERSION$env:STEELTOE_DASH_VERSION_SUFFIX.nupkg -Source "$env:USERPROFILE\localfeed"

	cd ..
}
cd ..