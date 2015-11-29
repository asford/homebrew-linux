#!/bin/sh

## Target paths
    LINUXBREW_BOOTSTRAP=$HOME/linuxbrew_bootstrap
    LINUXBREW_ROOT=$HOME/.linuxbrew

## Setup modern ruby separate from  linuxbrew install to avoid cyclic dependency 
## brew-ing with a brew-ed ruby breaks the brewery if any dependency is removed
    PATH=/usr/local/bin:/usr/bin:/bin
    mkdir -p $LINUXBREW_BOOTSTRAP
    pushd $LINUXBREW_BOOTSTRAP
    wget 'https://cache.ruby-lang.org/pub/ruby/2.2/ruby-2.2.3.tar.gz'
    tar -zxof ruby-2.2.3.tar.gz
    cd ruby-2.2.3
    ./configure --prefix=$LINUXBREW_BOOTSTRAP --disable-install-rdoc
    make && make install
    popd

## Unpack linuxbrew install
    mkdir -p $LINUXBREW_PREFIX
    pushd $LINUXBREW_PREFIX
    curl -fsSL
    https://github.com/Homebrew/linuxbrew/tarball/master | tar xz -m --strip 1
    popd

## Setup system compilers
    PATH=$LINUXBREW_BOOTSTRAP/bin:$LINUXBREW_PREFIX/bin:/usr/local/bin:/usr/bin:/bin
    ln -s $(which gcc) `brew --prefix`/bin/gcc-$(gcc -dumpversion |cut -d. -f1,2)
    ln -s $(which g++) `brew --prefix`/bin/g++-$(g++ -dumpversion |cut -d. -f1,2)
    #gfortran dumps full license info v/dumpversion at versions < 4.8
    ln -s $(which gfortran) `brew --prefix`/bin/gfortran-$(gfortran -dumpversion | egrep -o '[0-9]\.[0-9]' | head -n 1 | cut -d. -f1,2)

## Setup git to manage brew
    brew install git --without-tcl-tk
    brew install hello && brew test hello; brew remove hello

### Deploy modified openssl to match RHEL openssl configuration w/ ssl2 enabled.
    brew tap asford/linux
    brew install pkg-config
    brew install asford/linux/openssl

### Setup python installation
    brew install python 
    pip install numpy

### Setup pyrosetta requirements
    brew install cmake ninja
    brew install asford/linux/boost155 --with-python
    brew tap homebrew/head-only
    brew install --HEAD homebrew/head-only/gccxml

### Final step, grab a brew
    brew install pyrosetta
