#!/bin/bash
#Exit on error
set -e
#debug
set -x

PPA=mHero
TARGET=trusty
PKG=openinfoman
RLS=1.0



#Don't edit below



HOME=`pwd`
DEBS=$HOME/debs-${TARGET}
echo $DEBS

if [ -n "$LAUNCHPADPPALOGIN" ]; then
  echo Using $LAUNCHPADPPALOGIN for Launchpad PPA login
  echo "To Change You can do: export LAUNCHPADPPALOGIN=$LAUNCHPADPPALOGIN"
else 
  echo -n "Enter your launchpad login for the ppa and press [ENTER]: "
  read LAUNCHPADPPALOGIN
  echo "You can do: export LAUNCHPADPPALOGIN=$LAUNCHPADPPALOGIN to avoid this step in the future"
fi

gpg --list-public-keys | grep ^pub | awk '{print $2}' | awk -F / '{print $2}'

if [ -n "$GPGKEY" ]; then
  echo Using $GPGKEY for Launchpad PPA login
  echo "To Change You can do: export GPGKEY=$GPGKEY"
else 
  echo -n "Enter your GPG key for the ppa and press [ENTER]: "
  echo "Do: 
     gpg --list-public-keys | grep ^pub | awk '{print \$2}' | awk -F / '{print \$2}'
to see the available keys"
  echo "You can do: export GPGKEY=XXXXX to avoid this step in the future"
  exit 1

fi



PKGDIR=${DEBS}/${PKG}-${RLS}~${TARGET}
CHANGES=$DEBS/${PKG}_${RLS}~${TARGET}_source.changes
rm -fr $PKGDIR
mkdir -p $PKGDIR/var/lib
cd $PKGDIR/var/lib && git clone https://github.com/openhie/$PKG openinfoman
mkdir -p $PKGDIR/var/lib/openinfoman/repo
mv $PKGDIR/var/lib/openinfoman/repo $PKGDIR/var/lib/openinfoman/repo-src 
cp  -R $HOME/packaging/* $PKGDIR


cd $PKGDIR && echo `pwd` && dpkg-buildpackage -uc -us
#cd $PKGDIR && echo `pwd` && dpkg-buildpackage -k$GPGKEY -S -sa 
#dput --force ppa:$LAUNCHPADPPALOGIN/$PPA  $CHANGES


