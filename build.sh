#!/bin/bash

# recursive package builder
# 1. build makedepends of package template
# 2. build package from template
# 3. build depends of resulting binary package
# note: doesn't build hostmakedepends, they are taken from repositories

# remove stale state files that can prevent phases (e.g. patch) being re-run
rm -rf masterdir-x86_64/builddir

if test -z "$3"
then
  rm -f __build__*
elif test -f __build__$2
then
  echo "$3already building $2"
  exit 0
fi

if test "$1" == "x86_64-musl"
then
  cross=
else
  cross="-a $1"
fi

if test "$1" == "armv7hf-musl"
then
  output=armv7l-musl
else
  output=$1
fi

package=`ls hostdir/binpkgs |grep "^$2-[^-]*.$output.xbps$"`
if test -f "hostdir/binpkgs/$package"
then
  echo "$3already built $2"
else
  for i in `./xbps-src -A x86_64-musl $cross show-makedepends $2`
  do
    echo "$3pre-build $2: makedepend $i"
    if ! ./build.sh $1 $i "$3  "
    then
      echo "failed: ./build.sh $1 $i \"$3  \""
      exit 1
    fi
  done
  echo "$3build $2: ./xbps-src -A x86_64-musl $cross -1 -N -n pkg $2"
  if ! ./xbps-src -1 -A x86_64-musl $cross -n pkg $2
  then
    echo "failed: ./xbps-src -A x86_64-musl $cross -1 -N -n pkg $2"
    exit 1
  fi
  package=`ls hostdir/binpkgs |grep "^$2-[^-]*.$output.xbps$"`
  if ! test -f "hostdir/binpkgs/$package"
  then
    echo "missing: hostdir/binpkgs/$2-[^-]*.$output.xbps"
    exit 1
  fi
  echo "$3build $2: found $package"
fi

rm -rf __temp__
mkdir __temp__
unzstd <hostdir/binpkgs/$package |(cd __temp__ && tar xf -)
run_depends=`sed -ne '/<key>run_depends<\/key>/,/<\/array>/s/^\t*<string>\([^&=]*\)[&=].*<\/string>$/\1/p' <__temp__/props.plist`

touch __build__$2
for i in $run_depends
do
  echo "$3post-build $2: depend $i"
  case $i in
  awk) i=gawk;;
  esac
  if ! ./build.sh $1 $i "$3  "
  then
    echo "failed: ./build.sh $1 $i \"$3  \""
    exit 1
  fi
done
rm __build__$2
