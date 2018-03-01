cd src
# build each project in the src folder
Get-ChildItem -Directory | ForEach-Object {
	Write-Host "Now building $_..."
	cd $_
	# if there is a tag with the latest commit don't include symbols or source
	If ($env:APPVEYOR_REPO_TAG_NAME)
	{
		dotnet pack --configuration $env:BUILD_TYPE /p:Version=$env:STEELTOE_VERSION$env:STEELTOE_DASH_VERSION_SUFFIX
		# send package to AppVeyor Account feed for use by other builds on their way out to nuget.org
		appveyor PushArtifact bin\$env:BUILD_TYPE\$_.$env:STEELTOE_VERSION$env:STEELTOE_DASH_VERSION_SUFFIX.nupkg
	}
	Else
	{
		# include symbols and source
		dotnet pack --configuration $env:BUILD_TYPE /p:Version=$env:STEELTOE_VERSION$env:STEELTOE_DASH_VERSION_SUFFIX --include-symbols --include-source
		# send package to local feed for use within this build
		nuget add bin\$env:BUILD_TYPE\$_.$env:STEELTOE_VERSION$env:STEELTOE_DASH_VERSION_SUFFIX.nupkg -Source "$env:USERPROFILE\localfeed"
	}
	cd ..
}
cd ..