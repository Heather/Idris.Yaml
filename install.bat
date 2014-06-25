@echo off

::build & install
idris --clean Yaml.ipkg
idris --install Yaml.ipkg

pause
