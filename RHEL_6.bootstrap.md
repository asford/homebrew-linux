# Adapted from https://github.com/Homebrew/linuxbrew/wiki/Standalone-Installation

## Setup temporary modern ruby
    mkdir ~/linuxbrew_bootstrap
    pushd ~/linuxbrew_bootstrap
    wget 'https://cache.ruby-lang.org/pub/ruby/2.2/ruby-2.2.3.tar.gz'
    tar -zxof ruby-2.2.3.tar.gz
    cd ruby-2.2.3
    ./configure --prefix=$HOME/linuxbrew_bootstrap
    make && make install
    popd

## Setup build paths
    ln -s $(which gcc) `brew --prefix`/bin/gcc-$(gcc -dumpversion |cut -d. -f1,2)
    ln -s $(which g++) `brew --prefix`/bin/g++-$(g++ -dumpversion |cut -d. -f1,2)
    #gfortran dumps full spew at versions < 4.8
    ln -s $(which gfortran) `brew --prefix`/bin/gfortran-$(gfortran -dumpversion | egrep -o '[0-9]\.[0-9]' | head -n 1 | cut -d. -f1,2)
    PATH=~/linuxbrew_bootstrap/bin:~/.linuxbrew/bin:/usr/local/bin:/usr/bin:/bin

## Bootstrap ruby
    brew install git --without-tcl-tk
    brew install ruby
    PATH=~/.linuxbrew/bin:/usr/local/bin:/usr/bin:/bin
    brew install hello && brew test hello; brew remove hello

    rm -rf ~/linuxbrew_bootstrap
    brew install hello && brew test hello; brew remove hello
