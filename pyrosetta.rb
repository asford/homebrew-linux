# Documentation: https://github.com/Homebrew/homebrew/blob/master/share/doc/homebrew/Formula-Cookbook.md
#                http://www.rubydoc.info/github/Homebrew/homebrew/master/frames
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!

class Pyrosetta < Formula
  head "git@github.com:RosettaCommons/main.git", :revision => "0dad065", :using => :git

  depends_on "cmake"  => :build
  depends_on "ninja"  => :build
  depends_on "gccxml" => :build
  depends_on "python"
  depends_on "numpy" => :python
  depends_on "boost155" => "with-python"

  def install
    # Remove unrecognized options if warned by configure
    system "source/src/python/packaged_bindings/BuildPackagedBindings.py",
           "--boost_path", Formula["boost155"].opt_prefix,
           "-j", "8"
    cd "pyrostta" do
      system python, "setup.py", "install", "--prefix=#{prefix}"
    end
  end

  test do
    system python, "-c", "import rosetta; rosetta.init(); rosetta.get_score_function(rosetta.pose_from_sequence('TEST'))"
  end
end
