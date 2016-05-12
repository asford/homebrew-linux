require 'formula'

class Ndarray < Formula
  homepage 'https://github.com/ndarray/'
  url 'https://github.com/ndarray/ndarray.git', :using => :git, :branch => 'master'
  version "0.0.1"

  depends_on 'scons' => :build

  depends_on 'eigen'

  depends_on 'boost155' => 'with-python'
  depends_on 'numpy' => :python

  def install
    args = [
      "--with-boost=" + Formula["boost155"].opt_prefix,
      "--rpath=" + Formula["boost155"].opt_prefix + "/lib",
      "--with-eigen-include=" + Formula["eigen"].opt_prefix + "include/Eigen3",
      "--rpath=#{HOMEBREW_PREFIX}/lib",
      "--prefix=#{prefix}"
    ]

    system "scons", "include", "m4"

    system "scons", "tests", *args
    system "scons", *args
    system "scons", "install", *args
  end
end
