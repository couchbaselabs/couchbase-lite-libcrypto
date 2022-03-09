⚠️ This repo is obsolete.  It was used in Couchbase Lite 1.x.

# couchbase-lite-libcrypto #

Pre-built OpenSSL libcrypto static libraries for using with the SQLCipher and cbforest.

The OpenSSL version is [1.0.2j](https://github.com/openssl/openssl/releases/tag/OpenSSL_1_0_2j), except for the Windows Store builds which are [1.0.2k](https://github.com/Microsoft/openssl/tree/OpenSSL_1_0_2k_WinRT) and the source tree is not included in this repo.

##How to rebuild the binaries

###1. Setup the project
```
$git clone https://github.com/couchbaselabs/couchbase-lite-libcrypto.git
$git submodule update --init --recursive
```
###2. Generate include headers

Run the following command on a Mac or Linux machine. The headers will be output at `libs/include`.
```
$./generate-headers.sh
```

###3. Build the binaries for each platform

##3.1 Android

###Requirements
1. [Android NDK](http://developer.android.com/ndk/index.html)
2. Mac OSX Machine

###Common Build Steps
1. Make sure that you have the `ANDROID_NDK_HOME` variable defined. For example,

 ```
 #.bashrc:
 export ANDROID_NDK_HOME=~/Android/android-ndk-r10e
 ```
 
###Build Steps with GCC
1. Run the build script. The binaries will be output at `libs/android`

 ```
 $./build-android.sh
 ```

###Build Steps with clang
1. Run the build script. The binaries will be output at `libs/android/clang`

 ```
 $./build-android-clang.sh
 ```
 
##3.2 OSX ~~and iOS~~

###Requirements
1. XCode
2. makedepend (if you don't have one)

 ```
 $homebrew install makedepend
 ```

###Build Steps
Run the build script. The binaries will be output at `libs/osx` and `libs/ios`. The osx and ios binaries are universal libraries.
 ```
 $./build-osx-ios.sh
 ```

##3.3 Linux

###Requirements
1. GCC
2. makedepend (if you don't have one)

 ```
 $sudo apt-get install xutils-dev
 ```

###Build Steps
Run the build script. The binaries will be output at `libs/linux`.
 ```
 $./build-linux.sh
 ```
##3.4 Windows

###Requirements
1. [Visual Studio 2015](https://www.visualstudio.com/en-us/downloads/download-visual-studio-vs.aspx)
2. [Windows SDK](https://msdn.microsoft.com/en-us/windows/desktop/bg162891.aspx).
3. [Active Perl](http://www.activestate.com/activeperl) or [Strawberry Perl](http://strawberryperl.com)

Note that the build-windows.cmd script is configured with Visual Studio 2013.

###Build Steps
1. Make sure that the path to the `nmake` tool is included into the PATH Environment.

 ```
 Visual 2015: C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\bin
 ```
2. Run the build script. The binaries will be output at `libs/windows`.

 ```
 C:\couchbase-lite-libcrypto>build-windows.cmd
 ```
##3.5 Windows Store

Follow the instructions at [Microsoft's fork](https://github.com/Microsoft/openssl/tree/OpenSSL_1_0_2k_WinRT)
