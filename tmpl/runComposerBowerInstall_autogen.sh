#!/bin/sh

cd /tmp

rm -f composer_install.bat
rm -f bower_install.bat

cat <<'__COMPOSER__' >composer_install.bat
set PATH=%PROGRAMDATA%\composersetup\bin;%PATH%

cd c:\Apache
cmd /c composer install --ignore-platform-reqs
__COMPOSER__

cat <<'__BOWER__' >bower_install.bat
set PATH=%ProgramFiles%\nodejs;%PATH%
set PATH=%APPDATA%\npm;%PATH%

cd c:\Apache\htdocs\ls\rest\browser

REM eliminate prompt with CI=true (http://goo.gl/aRfP3V)
set CI=true
bower install
__BOWER__

echo "Running composer install"
cmd /c composer_install.bat

echo "Running bower install"
cmd /c bower_install.bat
