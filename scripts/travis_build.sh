#!/bin/bash

# loop through projects, restore & build
for d in ./src/*; do
    cd $d
    dotnet restore $NuGetConfigSwitch
    dotnet build --f netcoreapp2.0
    cd ../../
done
