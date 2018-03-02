Set-Location test

# run tests in each project in the test folder
Get-ChildItem -Directory | ForEach-Object {
	Set-Location $_.Name
	dotnet restore
	dotnet xunit -verbose
	Set-Location ..
}

Set-Location ..