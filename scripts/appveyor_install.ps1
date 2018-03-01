# Output dotnet info
dotnet --info

$env:CI_BUILD = $env:APPVEYOR
$env:STEELTOE_VERSION = "0.0.1"
Write-Host "NuGet package version to build: $env:STEELTOE_VERSION"

$env:BUILD_TYPE = "Release"

# if the last commit was tagged, don't use version suffixes
If ($env:APPVEYOR_REPO_TAG_NAME) {
	$env:STEELTOE_VERSION_SUFFIX = ""
    $env:STEELTOE_DASH_VERSION_SUFFIX = ""
}
Else {
	# use this variable to set the version on packages
	$env:STEELTOE_VERSION_SUFFIX = "$env:APPVEYOR_REPO_BRANCH-" + $env:APPVEYOR_BUILD_NUMBER.ToString().PadLeft(5, "0")
    # use this variable to refer to dependencies within the current solution that are built during CI builds
	$env:STEELTOE_DASH_VERSION_SUFFIX = "-$env:STEELTOE_VERSION_SUFFIX"
}

Write-Host "Package version suffix to use: $env:STEELTOE_VERSION_SUFFIX"

# add MyGet server as required, copy versions.props to solution root for use later
If ($env:APPVEYOR_REPO_TAG_NAME) {
	Write-Host "Use dependencies from nuget.org only"
	nuget sources add -Name SteeltoeMyGetStaging -Source https://www.myget.org/F/oss-ci/api/v3/index.json
	Copy-Item .\config\versions.props -Destination .\versions.props
}
ElseIf ($env:APPVEYOR_REPO_BRANCH -eq "master") {
	Write-Host "Use dependencies from nuget.org and myget/master"
	nuget sources add -Name SteeltoeMyGetMaster -Source https://www.myget.org/F/steeltoemaster/api/v3/index.json
	Copy-Item .\config\versions-master.props -Destination .\versions.props
}
ElseIf ($env:APPVEYOR_REPO_BRANCH -eq "dev") {
	Write-Host "Use dependencies from nuget.org and myget/dev"
	nuget sources add -Name SteeltoeMyGetDev -Source https://www.myget.org/F/steeltoedev/api/v3/index.json
	Copy-Item .\config\versions-dev.props -Destination .\versions.props
	$env:BUILD_TYPE = "Debug"
}
ElseIf ($env:APPVEYOR_REPO_BRANCH.SubString(0,6) -eq "update") {
	Write-Host "Use dependencies from nuget.org and myget/update"
	nuget sources add -Name SteeltoeMyGetUpdates -Source https://www.myget.org/F/steeltoeupdates/api/v3/index.json
	Copy-Item .\config\versions-update.props -Destination .\versions.props
}

dotnet restore

# setup a local folder NuGet feed for use during the build
mkdir $env:USERPROFILE\localfeed -Force
nuget sources add -Name localfeed -Source $env:USERPROFILE\localfeed