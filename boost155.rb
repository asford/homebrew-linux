class UniversalPython < Requirement
  satisfy(:build_env => false) { archs_for_command("python").universal? }

  def message; <<-EOS.undent
    A universal build was requested, but Python is not a universal build

    Boost compiles against the Python it finds in the path; if this Python
    is not a universal build then linking will likely fail.
    EOS
  end
end

class UniversalPython3 < Requirement
  satisfy(:build_env => false) { archs_for_command("python3").universal? }

  def message; <<-EOS.undent
    A universal build was requested, but Python 3 is not a universal build

    Boost compiles against the Python 3 it finds in the path; if this Python
    is not a universal build then linking will likely fail.
    EOS
  end
end

class Boost155 < Formula
  homepage "http://www.boost.org"
  revision 1

  stable do
    url "https://downloads.sourceforge.net/project/boost/boost/1.55.0/boost_1_55_0.tar.bz2"
    sha256 "fff00023dd79486d444c8e29922f4072e1d451fc5a4d2b6075852ead7f2b7b52"

    # Patches boost::atomic for LLVM 3.4 as it is used on OS X 10.9 with Xcode 5.1
    # https://github.com/Homebrew/homebrew/issues/27396
    # https://github.com/Homebrew/homebrew/pull/27436
    patch :p2 do
      url "https://github.com/boostorg/atomic/commit/6bb71fdd.diff"
      sha256 "eb139160a33d8ef3e810ce3e47da278563d03d7be6d0a75c109f708030a7abcb"
    end

    patch :p2 do
      url "https://github.com/boostorg/atomic/commit/e4bde20f.diff"
      sha256 "8c5efeea91d44b2a48fdeee9cde71e831dad78f0930e8f65b7223ba0ecdfec9b"
    end

    # Patch fixes upstream issue reported here (https://svn.boost.org/trac/boost/ticket/9698).
    # Will be fixed in Boost 1.56 and can be removed once that release is available.
    # See this issue (https://github.com/Homebrew/homebrew/issues/30592) for more details.

    patch :p2 do
      url "https://github.com/boostorg/chrono/commit/143260d.diff"
      sha256 "f6f40b576725b15ddfe24497ddcd597f387dfdf674f6dd301b8dcb723593ee22"
    end

    # Patch boost::serialization for Clang
    # https://svn.boost.org/trac/boost/ticket/8757
    patch :p1 do
      url "https://gist.githubusercontent.com/philacs/375303205d5f8918e700/raw/d6ded52c3a927b6558984d22efe0a5cf9e59cd8c/0005-Boost.S11n-include-missing-algorithm.patch"
      sha256 "cb134e3982e01ba5b3d5abe51cc8343c9e24ecd34aa4d81f5e8dd4461f593cf1"
    end
  end
  bottle do
    cellar :any
    sha256 "7ddd8eaf57ef85d2cbc5bfa04f6cac1aedfbf435cefdab2ccbf1d682c846248c" => :yosemite
    sha256 "7a33b63b1e8c4afdb877cbb45b951c1867fb09ecd73f836478140cdce1ca8291" => :mavericks
    sha256 "e9c02b26e9190d8da61e1acc46d2fb478ea8b836c4a463d5aed57d3c892c7432" => :mountain_lion
  end

  keg_only "Conflicts with boost in main repository."

  env :userpaths

  option :universal
  option "with-icu", "Build regexp engine with icu support"
  option "without-single", "Disable building single-threading variant"
  option "without-static", "Disable building static library variant"
  option "with-mpi", "Build with MPI support"
  option :cxx11

  option "with-atomic", "Build with atomic support."
  option "with-chrono", "Build with chrono support."
  option "with-context", "Build with context support."
  option "with-coroutine", "Build with coroutine support."
  option "with-date_time", "Build with date_time support."
  option "with-exception", "Build with exception support."
  option "with-filesystem", "Build with filesystem support."
  option "with-graph", "Build with graph support."
  option "with-graph_parallel", "Build with graph_parallel support."
  option "with-iostreams", "Build with iostreams support."
  option "with-locale", "Build with locale support."
  option "with-log", "Build with log support."
  option "with-math", "Build with math support."
  option "with-program_options", "Build with program_options support."
  option "with-random", "Build with random support."
  option "with-regex", "Build with regex support."
  option "with-serialization", "Build with serialization support."
  option "with-signals", "Build with signals support."
  option "with-system", "Build with system support."
  option "with-test", "Build with test support."
  option "with-thread", "Build with thread support."
  option "with-timer", "Build with timer support."
  option "with-wave", "Build with wave support."

  depends_on :python => :optional
  depends_on :python3 => :optional
  depends_on UniversalPython if build.universal? && build.with?("python")
  depends_on UniversalPython3 if build.universal? && build.with?("python3")

  if build.with?("python3") && build.with?("python")
    odie "boost155: --with-python3 cannot be specified when using --with-python"
  end

  if build.with? "icu"
    if build.cxx11?
      depends_on "icu4c" => "c++11"
    else
      depends_on "icu4c"
    end
  end

  if build.with? "mpi"
    if build.cxx11?
      depends_on "open-mpi" => "c++11"
    else
      depends_on :mpi => [:cc, :cxx, :optional]
    end
  end

  fails_with :llvm do
    build 2335
    cause "Dropped arguments to functions when linking with boost"
  end

  def install
    # https://svn.boost.org/trac/boost/ticket/8841
    if build.with?("mpi") && build.with?("single")
      raise <<-EOS.undent
        Building MPI support for both single and multi-threaded flavors
        is not supported.  Please use "--with-mpi" together with
        "--without-single".
      EOS
    end

    if build.cxx11? && build.with?("mpi") && (build.with?("python") \
                                               || build.with?("python3"))
      raise <<-EOS.undent
        Building MPI support for Python using C++11 mode results in
        failure and hence disabled.  Please don"t use this combination
        of options.
      EOS
    end

    ENV.universal_binary if build.universal?

    # Force boost to compile using the appropriate GCC version.
    open("user-config.jam", "a") do |file|
      if OS.mac?
        file.write "using darwin : : #{ENV.cxx} ;\n"
      else
        file.write "using gcc : : #{ENV.cxx} ;\n"
      end
      file.write "using mpi ;\n" if build.with? "mpi"

      # Link against correct version of Python if python3 build was requested
      if build.with? "python3"
        py3executable = `which python3`.strip
        py3version = `python3 -c "import sys; print(sys.version[:3])"`.strip
        py3prefix = `python3 -c "import sys; print(sys.prefix)"`.strip

        file.write <<-EOS.undent
          using python : #{py3version}
                       : #{py3executable}
                       : #{py3prefix}/include/python#{py3version}m
                       : #{py3prefix}/lib ;
        EOS
      end
    end

    # we specify libdir too because the script is apparently broken
    bargs = ["--prefix=#{prefix}", "--libdir=#{lib}"]

    if build.with? "icu"
      icu4c_prefix = Formula["icu4c"].opt_prefix
      bargs << "--with-icu=#{icu4c_prefix}"
    else
      bargs << "--without-icu"
    end

    # Handle libraries that will not be built.
    without_libraries = []

    # The context library is implemented as x86_64 ASM, so it
    # won"t build on PPC or 32-bit builds
    # see https://github.com/Homebrew/homebrew/issues/17646
    if Hardware::CPU.ppc? || Hardware::CPU.is_32_bit? || build.universal?
      without_libraries << "context"
      # The coroutine library depends on the context library.
      without_libraries << "coroutine"
    end

    # Boost.Log cannot be built using Apple GCC at the moment. Disabled
    # on such systems.
    without_libraries << "log" if ENV.compiler == :gcc || ENV.compiler == :llvm
    without_libraries << "python" if build.without?("python") \
                                      && build.without?("python3")
    without_libraries << "mpi" if build.without? "mpi"

    without_libraries << "atomic" if build.without? "atomic"
    without_libraries << "chrono" if build.without? "chrono"
    without_libraries << "context" if build.without? "context"
    without_libraries << "coroutine" if build.without? "coroutine"
    without_libraries << "date_time" if build.without? "date_time"
    without_libraries << "exception" if build.without? "exception"
    without_libraries << "filesystem" if build.without? "filesystem"
    without_libraries << "graph" if build.without? "graph"
    without_libraries << "graph_parallel" if build.without? "graph_parallel"
    without_libraries << "iostreams" if build.without? "iostreams"
    without_libraries << "locale" if build.without? "locale"
    without_libraries << "log" if build.without? "log"
    without_libraries << "math" if build.without? "math"
    without_libraries << "program_options" if build.without? "program_options"
    without_libraries << "random" if build.without? "random"
    without_libraries << "regex" if build.without? "regex"
    without_libraries << "serialization" if build.without? "serialization"
    without_libraries << "signals" if build.without? "signals"
    without_libraries << "system" if build.without? "system"
    without_libraries << "test" if build.without? "test"
    without_libraries << "thread" if build.without? "thread"
    without_libraries << "timer" if build.without? "timer"
    without_libraries << "wave" if build.without? "wave"

    bargs << "--without-libraries=#{without_libraries.join(",")}"

    args = ["--prefix=#{prefix}",
            "--libdir=#{lib}",
            "-d2",
            "-j#{ENV.make_jobs}",
            "--layout=tagged",
            "--user-config=user-config.jam",
            "install"]

    if build.with? "single"
      args << "threading=multi,single"
    else
      args << "threading=multi"
    end

    if build.with? "static"
      args << "link=shared,static"
    else
      args << "link=shared"
    end

    args << "address-model=32_64" << "architecture=x86" << "pch=off" if build.universal?

    # Trunk starts using "clang++ -x c" to select C compiler which breaks C++11
    # handling using ENV.cxx11. Using "cxxflags" and "linkflags" still works.
    if build.cxx11?
      args << "cxxflags=-std=c++11"
      if ENV.compiler == :clang
        args << "cxxflags=-stdlib=libc++" << "linkflags=-stdlib=libc++"
      end
    end

    system "./bootstrap.sh", *bargs
    system "./b2", *args
  end

  def caveats
    s = ""
    # ENV.compiler doesn"t exist in caveats. Check library availability
    # instead.
    if Dir["#{lib}/libboost_log*"].empty?
      s += <<-EOS.undent

      Building of Boost.Log is disabled because it requires newer GCC or Clang.
      EOS
    end

    if Hardware::CPU.ppc? || Hardware::CPU.is_32_bit? || build.universal?
      s += <<-EOS.undent

      Building of Boost.Context and Boost.Coroutine is disabled as they are
      only supported on x86_64.
      EOS
    end

    s
  end

  test do
    (testpath/"test.cpp").write <<-EOS.undent
      #include <boost/algorithm/string.hpp>
      #include <boost/version.hpp>
      #include <string>
      #include <vector>
      #include <assert.h>
      using namespace boost::algorithm;
      using namespace std;
      int main()
      {
        string str("a,b");
        vector<string> strVec;
        split(strVec, str, is_any_of(","));
        assert(strVec.size()==2);
        assert(strVec[0]=="a");
        assert(strVec[1]=="b");

        assert(strcmp(BOOST_LIB_VERSION, "1_55") == 0);

        return 0;
      }
    EOS
    system ENV.cxx, "test.cpp", "-std=c++1y", "-I#{include}", "-L#{lib}", "-lboost_system", "-o", "test"
    system "./test"
  end
end
