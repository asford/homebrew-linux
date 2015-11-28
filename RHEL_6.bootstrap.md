# Adapted from https://github.com/Homebrew/linuxbrew/wiki/Standalone-Installation

## Setup temporary modern ruby
    mkdir ~/linuxbrew_bootstrap
    pushd ~/linuxbrew_bootstrap
    wget 'https://cache.ruby-lang.org/pub/ruby/2.2/ruby-2.2.3.tar.gz'
    tar -zxof ruby-2.2.3.tar.gz
    cd ruby-2.2.3
    configure --prefix=$HOME/linuxbrew_bootstrap
    make && make install
    popd

# Sanitize build path
    PATH=~/linuxbrew_bootsrap/bin:~/.linuxbrew/bin:/usr/local/bin:/usr/bin:/bin
    unset LD_LIBRARY_PATH PKG_CONFIG_PATH
  
## Setup linuxbrew
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/linuxbrew/go/install)"
    ln -s $(which gcc) `brew --prefix`/bin/gcc-$(gcc -dumpversion |cut -d. -f1,2)
    ln -s $(which g++) `brew --prefix`/bin/g++-$(g++ -dumpversion |cut -d. -f1,2)
    brew tap homebrew/dupes

# Install the compiler tool chain 
##Install glibc

    brew install glibc
    brew remove binutils
    brew unlink glibc
    brew test glibc
    brew install hello && brew test hello; brew remove hello
    ln -s `brew —-/prefix/lib `brew --prefix`/lib64

##Install zlib
    brew install https://raw.githubusercontent.com/Homebrew/homebrew-dupes/master/zlib.rb

##Install binutils

    brew install binutils
    brew install hello && brew test hello; brew remove hello

##Install gcc
    brew link glibc
    brew install patchelf
    ln -s /usr/lib64/libstdc++.so.6 /lib64/libgcc_s.so.1 `brew --prefix`/lib/
    brew install gcc --with-glibc -v
    rm -f `brew --prefix`/lib/{libstdc++.so.6,libgcc_s.so.1}
    brew link gcc
    brew install hello && brew test hello; brew remove hello

#Install core utils
    brew install bzip2 curl expat git
    brew install ruby
    PATH=~/.linuxbrew/bin:/usr/local/bin:/usr/bin:/bin
    
    brew install hello && brew test hello; brew remove hello

##Cleanup temp ruby
    rm -rf ~/linuxbrew_bootstrap
