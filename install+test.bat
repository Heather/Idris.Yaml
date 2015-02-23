@echo off

::build & install
idris --clean Yaml.ipkg
idris --install Yaml.ipkg

::test
cd tests
bash runtests.sh

pause
