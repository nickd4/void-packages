#!/bin/bash

# recursive package builder
# 1. build makedepends of package template
# 2. build package from template
# 3. build depends of resulting binary package
# note: doesn't build hostmakedepends, they are taken from repositories

# remove stale state files that can prevent phases (e.g. patch) being re-run
rm -rf masterdir-x86_64-musl/builddir

if test -z "$2"
then
  rm -f __build__*
elif test -f __build__$1
then
  echo "$2already building $1"
  exit 0
fi

package=`ls hostdir/binpkgs |grep "^$1-[^-]*.x86_64-musl.xbps$"`
if test -f "hostdir/binpkgs/$package"
then
  echo "$2already built $1"
else
  for i in `./xbps-src -A x86_64-musl show-makedepends $1`
  do
    echo "$2pre-build $1: makedepend $i"
    if ! ./build.sh $i "$2  "
    then
      echo "failed: ./build.sh $i \"$2  \""
      exit 1
    fi
  done
  echo "$2build $1: ./xbps-src -1 -A x86_64-musl -N -n pkg $1"
  if ! ./xbps-src -1 -A x86_64-musl -n pkg $1
  then
    echo "failed: ./xbps-src -1 -A x86_64-musl -N -n pkg $1"
    exit 1
  fi
  package=`ls hostdir/binpkgs |grep "^$1-[^-]*.x86_64-musl.xbps$"`
  if ! test -f "hostdir/binpkgs/$package"
  then
    echo "missing: hostdir/binpkgs/$1-[^-]*.x86_64-musl.xbps"
    exit 1
  fi
  echo "$2build $1: found $package"
fi

rm -rf __temp__
mkdir __temp__
unzstd <hostdir/binpkgs/$package |(cd __temp__ && tar xf -)
run_depends=`sed -ne '/<key>run_depends<\/key>/,/<\/array>/s/^\t*<string>\([^&=]*\)[&=].*<\/string>$/\1/p' <__temp__/props.plist`

touch __build__$1
for i in $run_depends
do
  echo "$2post-build $1: depend $i"
  case $i in
  awk) i=gawk;;
  esac
  if ! ./build.sh $i "$2  "
  then
    echo "failed: ./build.sh $i \"$2  \""
    exit 1
  fi
done
rm __build__$1
