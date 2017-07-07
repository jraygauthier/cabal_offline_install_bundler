Readme
======

A simple tool that allows one to quickly bundle all the transitive dependencies of a set of
haskell package using cabal so that they could be deployed offline to another computer.

The bundle is in the form of a tarball with a companion bash deploy script that will automatically
extract the tarball to the proper location.

Prerequisites
-------------

 -  An installation of `ghc` with `cabal-install`
 -  `bash` which should be available on most systems. On windows, you can use msys2 or even 
    git for windows.


Creating the bundle
-------------------

First, make sure the computer that will be used to create the bundle runs on the same OS and
is using the same version of ghc and haskell platform (if applicable) as the target computer.

~~~{.bash}
git clone http://url/to/cabal_offline_install_bundler
cd cabal_offline_install_bundler
./create_hs_pkgs_tarball.sh first-hs-pkg second-hs-pkg
~~~

The bundle should have been created as a `haskell_packages` directory in the current working
directory containing the following files:

 -  `packages.tar.gz`

    The actual bundle of haskell packages. Include both `first-hs-pkg` and `second-hs-pkg` but
    also all their transitive dependencies. This is litterally a copy of the content that
    can be found under `~/.cabal/packages`.

 -  `deploy_packages.sh`

    The deployment script you should run on the target machine to install the bundled 
    haskell packages.


Deploying the bundle
--------------------

Transfer the bundle on the target computer (which most likely does not have any internet access).

~~~{.bash}
cd /my/path/on/the/target/computer/to/haskell_packages
./deploy_packages.sh
cabal install --offline first-hs-pkg second-hs-pkg 
~~~

If everything went well, the packages should have been installed successfully even though
there is no internet connection on this computer.


Tips and trick
--------------

 -  On linux, in order to play safe with your global cabal package set, you can specify an
    alternate home directory like so: `export HOME=./path/to/my/alt/home/dir`. A `.cabal` will
    be created there. Note that even without this, the scripts take a backup of all your
    cabal dot files and restore them afterward.

 -  If using nix, you most likely have existing haskell package installed. Because of nix's
    way of doing things, removing the cabal dot files temporarily as does this script won't
    be enough to fool the `cabal fetch` command used internally into thinking that no haskell
    packages are installed. This is why the `shell.nix` environement is provided. Simply enter
    this environement using `nix-shell --pure` before calling `./create_hs_pkgs_tarball.sh`
    and the tool should work as expected.

