#!/bin/sh

cd /tmp

rm -f composer_update.bat
rm -f bower_update.bat

cat <<'__COMPOSER__' >composer_update.bat
set PATH=%PROGRAMDATA%\composersetup\bin;%PATH%

cd c:\Apache
cmd /c composer update --ignore-platform-reqs
__COMPOSER__

cat <<'__BOWER__' >bower_update.bat
set PATH=%ProgramFiles%\nodejs;%PATH%
set PATH=%APPDATA%\npm;%PATH%

cd c:\Apache\htdocs\ls\rest\browser

REM eliminate prompt with CI=true (http://goo.gl/aRfP3V)
set CI=true
bower install
__BOWER__

echo "Running composer update"
cmd /c composer_update.bat

echo "Running bower update"
cmd /c bower_update.bat
