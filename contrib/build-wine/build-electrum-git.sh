#!/bin/bash

NAME_ROOT=electrum
PYTHON_VERSION=3.5.4

# These settings probably don't need any change
export WINEPREFIX=/opt/wine64
export PYTHONDONTWRITEBYTECODE=1
export PYTHONHASHSEED=22

PYHOME=c:/python$PYTHON_VERSION
PYTHON="wine $PYHOME/python.exe -OO -B"


# Let's begin!
cd `dirname $0`
set -e

rm -rf $WINEPREFIX/drive_c/electrum
cp -r ../../../electrum-fjc-3.1.x $WINEPREFIX/drive_c/electrum
cp ../../LICENCE .

# Install frozen dependencies
$PYTHON -m pip install -r ../deterministic-build/requirements.txt

$PYTHON -m pip install -r ../deterministic-build/requirements-hw.txt

pushd $WINEPREFIX/drive_c/electrum
$PYTHON setup.py install
popd

rm -rf dist/

# build standalone and portable versions
wine "C:/python$PYTHON_VERSION/scripts/pyinstaller.exe" --noconfirm --ascii --name electrum-FJC-3.1.2 -w deterministic.spec

# set timestamps in dist, in order to make the installer reproducible
#pushd dist
#find -exec touch -d '2000-11-11T11:11:11+00:00' {} +
#popd

# build NSIS installer
# $VERSION could be passed to the electrum.nsi script, but this would require some rewriting in the script iself.
wine "$WINEPREFIX/drive_c/Program Files (x86)/NSIS/makensis.exe" /DPRODUCT_VERSION=$VERSION electrum.nsi


echo "Done."
md5sum dist/electrum*exe
