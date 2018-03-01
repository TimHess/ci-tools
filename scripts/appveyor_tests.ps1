cd test
# run tests in each project in the test folder
Get-ChildItem -Directory | ForEach-Object {
	cd $_.Name
	dotnet xunit -verbose
	cd ..
}
cd ..