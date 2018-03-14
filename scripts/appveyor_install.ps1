# Output dotnet info
dotnet --info

$env:CI_BUILD = $env:APPVEYOR
$env:STEELTOE_VERSION = $env:APPVEYOR_BUILD_VERSION.Replace("-$env:APPVEYOR_REPO_BRANCH-$env:APPVEYOR_BUILD_NUMBER", "")
Write-Host "NuGet package version to build: $env:STEELTOE_VERSION"

$env:BUILD_TYPE = "Release"

# if the last commit was tagged, only use version suffixes from the tag itself
If ($env:APPVEYOR_REPO_TAG_NAME) {
	$env:STEELTOE_VERSION_SUFFIX = $env:APPVEYOR_REPO_TAG_NAME.split("-", 2)[1]
	$env:STEELTOE_DASH_VERSION_SUFFIX = If ($env:STEELTOE_VERSION_SUFFIX) { "-$env:STEELTOE_VERSION_SUFFIX" }
}
Else {
	# use this variable to set the version on packages
	$env:STEELTOE_VERSION_SUFFIX = "$env:APPVEYOR_REPO_BRANCH-" + $env:APPVEYOR_BUILD_NUMBER.ToString().PadLeft(5, "0")
    # use this variable to refer to dependencies within the current solution that are built during CI builds
	$env:STEELTOE_DASH_VERSION_SUFFIX = "-$env:STEELTOE_VERSION_SUFFIX"
}

Write-Host "Package version suffix to use: $env:STEELTOE_VERSION_SUFFIX"

# add MyGet server as required, copy versions.props to solution root for use later
If ($env:APPVEYOR_REPO_BRANCH -eq "master") {
	Write-Host "Use dependencies from nuget.org and https://www.myget.org/F/oss-ci-master/api/v3/index.json"
	nuget sources add -Name SteeltoeMyGetMaster -Source https://www.myget.org/F/oss-ci-master/api/v3/index.json
	$env:PropsVersion = "-master"
}
ElseIf ($env:APPVEYOR_REPO_BRANCH -eq "dev") {
	Write-Host "Use dependencies from nuget.org and https://www.myget.org/F/oss-ci-dev/api/v3/index.json"
	nuget sources add -Name SteeltoeMyGetDev -Source https://www.myget.org/F/oss-ci-dev/api/v3/index.json
	$env:PropsVersion = "-dev"
	$env:BUILD_TYPE = "Debug"
}
ElseIf ($env:APPVEYOR_REPO_BRANCH.SubString(0,6) -eq "update") {
	Write-Host "Use dependencies from nuget.org and https://www.myget.org/F/steeltoeupdates/api/v3/index.json"
	nuget sources add -Name SteeltoeMyGetUpdates -Source https://www.myget.org/F/steeltoeupdates/api/v3/index.json
	$env:PropsVersion = "-update"
}
If (Test-Path config/versions.props)
{
	Copy-Item .\config\versions$env:PropsVersion.props -Destination .\versions.props	
}


# setup a local folder NuGet feed for use during the build
mkdir localfeed -Force
nuget sources add -Name localfeed -Source localfeed