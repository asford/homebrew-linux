require 'formula'

class BoostNumpy < Formula
  homepage 'https://github.com/ndarray/'
  url 'git@github.com:ndarray/Boost.NumPy.git', :using => :git, :branch => 'master'
  version "0.0.1"

  depends_on 'scons' => :build

  depends_on 'boost155' => 'with-python'
  depends_on 'numpy' => :python

  def install
    args = [
      "--rpath=" + Formula["boost155"].opt_prefix + "/lib",
      "--with-boost=" + Formula["boost155"].opt_prefix,
      "--rpath=#{HOMEBREW_PREFIX}/lib",
      "--prefix=#{prefix}"
    ]

    system "scons", *args
    system "scons", "install", *args
  end
end
