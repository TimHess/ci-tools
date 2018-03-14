Param(
    [Parameter]
    [string]$Version_To_Set
)

If (-Not $env:PackageReferencesToUpdate) {
    Write-Host "No depency updates requested"
    Write-Host "To use, set env:PackageReferencesToUpdate to a space-separated list of properties to update in dependent libraries"
    return
}

If (-Not $Version_To_Set)
{
    If (-Not $env:STEELTOE_VERSION) 
    {
        Write-Error "Downstream references identifed but version wasn't set explicitly or implicitly!"
        return -1
    }
    $Version_To_Set = "$env:STEELTOE_VERSION$env:STEELTOE_DASH_VERSION_SUFFIX"
}


If (-Not $env:SteeltoeRepositoryList) {
    Write-Information "Steeltoe repository list not set in Environment, using complete list"
    $s = "TimHess"
    $env:SteeltoeRepositoryList = "$s/base-ci-lib $s/dependent-ci-lib"
}

# specifically checkout dev branches in case one get master set as default at some point
$env:BranchFilter = "--single-branch -b dev"

# start the clock
$TotalTime = New-Object -TypeName System.Diagnostics.Stopwatch
$TotalTime.Start()

# ensure the workspace is clean
Remove-Item workspace -Force -Recurse -ErrorAction SilentlyContinue
[int]$env:TestErrors = 0
$env:ProcessTimes = ""

mkdir workspace -Force
Set-Location workspace

ForEach ($_ in $env:SteeltoeRepositoryList.Split(' ')) {
    $ProjectTime = New-Object -TypeName System.Diagnostics.Stopwatch
    $ProjectTime.Start()
    # build the clone command as a string to then execute so the branch filter works
    $cloneString = "git clone -q $env:BranchFilter https://github.com/$_.git"
    Write-Host "clone command: " $cloneString
    Invoke-Expression $cloneString

    Set-Location $_.Split("/")[1]
    If (Test-Path config/versions-dev.props)
    {
        # modify versions.props (xml) to update all steeltoe references (except SteeltoeVersion and SteeltoeVersionSuffix)
        $xmlContent = [XML](Get-Content("config/versions-dev.props"))
        $xmlContent.SelectNodes("//Project/PropertyGroup/*") | 
        ForEach-Object {
            If ($env:PackageReferencesToUpdate.Contains($_.name))
            {
                Write-Host "Original value of"$_.Name"is"$_.InnerXml
                $_.InnerXml = $Version_To_Set
                Write-Host "Updated value of"$_.Name"is"$_.InnerXml
            }
        }
        $xmlContent.OuterXml | Out-File "config/versions-dev.props"
    }
    Set-Location ..
    $ProjectTime.Stop()
    Write-Host "Process time for $_ :" $ProjectTime.Elapsed.ToString()
    $env:ProcessTimes += $_ + ":" + $ProjectTime.Elapsed.ToString() + ";"
}
Set-Location ..

# display processing times
Write-Host "Package build process times:"
ForEach ($_ in $env:ProcessTimes.Split(';')) { 
    Write-Host $_ 
}
$TotalTime.Stop()
Write-Host "Total process time:" $TotalTime.Elapsed.ToString()