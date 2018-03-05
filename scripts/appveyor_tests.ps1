Set-Location test

[int]$errors = 0

# run tests in each project in the test folder
Get-ChildItem -Directory | ForEach-Object {
	Set-Location $_.Name
	dotnet restore
	dotnet xunit -verbose
	$errors = $errors + $lastexitcode
	Set-Location ..
}

Set-Location ..

If ($errors -gt 0)
{
    Throw "$errors test(s) failed" 
}