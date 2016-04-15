FROM ubuntu:15.10

ARG CC=/usr/bin/gcc-5
ARG CXX=/usr/bin/g++-5
ARG CFLAGS="-D_GLIBCXX_USE_CXX11_ABI=0 -fPIC -g -fno-omit-frame-pointer -O3 -pthread"
ARG CXXFLAGS="-D_GLIBCXX_USE_CXX11_ABI=0 -fPIC -g -fno-omit-frame-pointer -O3 -pthread"

ARG FOLLY_SHA=e756d07cd35714d7528444321ea5145b41f5ae0f
ARG WANGLE_SHA=d67b7632be2923de3695201c7ac361f50646bbbf
ARG PROXYGEN_SHA=ab90f2a9f0709180a2df726278d8692a5da11c79
ARG BUCK_SHA=b5c1b24d8f25be5c96e8bce0a70c4665870a5749
ARG GTEST_SHA=13206d6f53aaff844f2d3595a01ac83a29e383db
ARG DOUBLE_SHA=7499d0b6926e1a5a3d9deeb4c29b4f8bfc742c42
ARG WATCHMAN_VER=v4.5.0
ARG GFLAG_VER=v2.1.2
ARG GLOG_VER=v0.3.4
ARG DEBIAN_FRONTEND=noninteractive


# Add utils to enable changing apt lists
# And then add them on.
RUN apt-get -y update && \
    apt-get -y install \
        apt-utils \
        python-software-properties \
        software-properties-common \
        wget && \
    wget -O - http://llvm.org/apt/llvm-snapshot.gpg.key | apt-key add - && \
    add-apt-repository 'deb http://llvm.org/apt/wily/ llvm-toolchain-wily-3.7 main' && \
    apt-add-repository ppa:ubuntu-toolchain-r/test && \
    apt-get -qq clean && \
    apt-get -y -qq autoremove && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/ && \
    rm -rf /tmp/*

# Install all of the prerequisites for folly, and install g++-5 to get c++14 features
RUN apt-get -y update && \
    apt-get -y install \
        ant \
        autoconf \
        autoconf-archive \
        automake \
        binutils-dev \
        bison \
        build-essential \
        clang-3.7 \
        clang-format-3.7 \
        clang-tidy-3.7 \
        cmake \
        curl \
        flex \
        g++-5 \
        gdb \
        gdc \
        git \
        gperf \
        libbz2-dev \
        libcap-dev \
        libevent-dev \
        libjemalloc-dev \
        libkrb5-dev \
        liblz4-dev \
        liblzma-dev \
        libnuma-dev \
        libsasl2-dev \
        libsnappy-dev \
        libssl-dev \
        libtool \
        libunwind8-dev \
        lldb \
        llvm-3.7-dev \
        make \
        openjdk-8-jdk \
        pciutils \
        pkg-config \
        python-dev \
        unzip \
        zlib1g-dev && \
    apt-get -qq clean && \
    apt-get -y -qq autoremove && \
    ln -s /usr/bin/clang-3.7 /usr/bin/clang && \
    ln -s /usr/bin/clang++-3.7 /usr/bin/clang++ && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/ && \
    rm -rf /tmp/*

# Don't use -j8 or anything like that that gcc errors out in unpredictable ways.
# Better to have the docker build step take a little while longer than to error out.

#
# Build the Cpp libraries.
# 
# GCC 5.1 and libstdc++ devs are jerks.
# They added in a a new abi tag without bumping soname
# Because of that every c++ library needs to be compiled
# by us without that feature so that switching between clang
# and gcc works
#


# Download Boost from fedora because the mirrors at source forge are awful.
# They frequently just 404 because it's a day that ends in Y.
RUN cd /usr/src && pwd && ls -alh && \
    wget http://pkgs.fedoraproject.org/repo/pkgs/boost/boost_1_59_0.tar.bz2/6aa9a5c6a4ca1016edd0ed1178e3cb87/boost_1_59_0.tar.bz2 && \
    tar xjf boost_1_59_0.tar.bz2 && \
    cd boost_1_59_0 && \
    ./bootstrap.sh --with-toolset=gcc && \
    ./b2 --toolset=gcc link=shared,static cxxflags="${CXXFLAGS}" cflags="${CFLAGS}" -j2 && \
    ./b2 --toolset=gcc link=shared,static cxxflags="${CXXFLAGS}" cflags="${CFLAGS}" install && \
    ./b2 clean && \
    rm -rf /usr/src/boost_1_59_0.tar.bz2

RUN git clone https://github.com/google/double-conversion.git /usr/src/double-conversion && \
    cd /usr/src/double-conversion && \
    git checkout ${DOUBLE_SHA} && \
    ldconfig && \
    cmake -DCMAKE_BUILD_TYPE=Release . && \
    make -j2 && \
    make install && \
    make clean && \
    cmake -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_SHARED_LIBS=ON . && \
    make -j2 && \
    make install && \
    make clean && \
    rm -rf /usr/src/double-conversion/.git

RUN git clone --depth 1 --branch ${GFLAG_VER} https://github.com/gflags/gflags.git /usr/src/gflags && \
    cd /usr/src/gflags && \
    ldconfig && \
    cmake -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_STATIC_LIBS=ON \
      -DBUILD_SHARED_LIBS=ON \
      -DBUILD_TESTING=ON . && \
    make -j2 && \
    make install && \
    make clean && \
    rm -rf /usr/src/gflags/.git
    
RUN git clone https://github.com/google/googletest.git /usr/src/googletest && \
    cd /usr/src/googletest && \
    git checkout ${GTEST_SHA} && \
    ldconfig && \
    cmake -DCMAKE_BUILD_TYPE=Release \ 
      -Dgtest_build_samples=ON . && \
    make -j2 && \
    make install && \
    make clean && \
    rm -rf /usr/src/googletest/.git

RUN git clone --depth 1 --branch ${GLOG_VER}  https://github.com/google/glog.git /usr/src/glog && \
    cd /usr/src/glog && \
    ldconfig && \
    autoreconf -ivf && \
    ./configure && \
    make -j2 && \
    make install && \
    make clean && \
    rm -rf /usr/src/glog/.git

# Download and install folly, build with clang or gcc-5 
RUN git clone https://github.com/facebook/folly.git /usr/src/folly && \
	  cd /usr/src/folly/folly && \
    git checkout ${FOLLY_SHA} && \
    ldconfig && \
    autoreconf -ivf && \
    ./configure && \
    make -j2 && \
    make install && \
    make clean && \
    rm -rf /usr/src/folly/.git

# Download and install wangle, build with clang or gcc-5 
# Wangle has a hard coded CXXFLAGS so we have to sed them for now.
# When they have an over-ridable default then this can go back to normal
#
# Also wangle's build of gmock doesn't seem to work at all.
# Should figure out why.
# Until then just don't build the tests
RUN git clone https://github.com/facebook/wangle.git /usr/src/wangle && \
    cd /usr/src/wangle/wangle && \
    git checkout ${WANGLE_SHA} && \
    ldconfig && \
    sed -i 's/fPIC/fPIC -D_GLIBCXX_USE_CXX11_ABI=0 -O2 -g/' CMakeLists.txt && \
    cmake -DBUILD_TESTS=OFF . && \
    make -j2 && \
    make install && \
    make clean && \
    sed -i 's/wangle STATIC/wangle SHARED/' CMakeLists.txt && \
    cmake -DBUILD_TESTS=OFF . && \
    make -j2 && \
    make install && \
    make clean && \
    rm -rf /usr/src/wangle/.git

# Download and install proxygen, build with clang or gcc-5  
RUN git clone https://github.com/facebook/proxygen.git /usr/src/proxygen && \
    cd /usr/src/proxygen/proxygen && \
    git checkout ${PROXYGEN_SHA} && \
    ldconfig && \
    autoreconf -ivf && \
    ./configure && \
    make -j2 && \
    make install && \
	  make clean && \
    rm -rf /usr/src/proxygen/.git

#
# Build the tools
#

# Download and install watchman, build with g++5 tools
RUN git clone --depth 1 --branch ${WATCHMAN_VER} https://github.com/facebook/watchman.git /usr/src/watchman && \
    cd /usr/src/watchman && \
    ldconfig && \
    ./autogen.sh && \
    ./configure && \
    make -j2 && \
    make install && \
    make clean && \
    rm -rf /usr/src/watchman/.git

# Download and install buck. Run it once so that it does its own first-run build process
# Remove some extra files that end up being ~250M combined
RUN git clone https://github.com/facebook/buck.git /usr/src/buck && \
    cd /usr/src/buck && \
    git checkout ${BUCK_SHA} && \
    ant && \
    ln -s /usr/src/buck/bin/buck /usr/local/bin/buck && \
    ln -s /usr/src/buck/bin/buckd /usr/local/bin/buckd && \
    ( /usr/local/bin/buck --help || true ) &&  \
    rm -rf /usr/src/buck/.git && \
    rm -rf /usr/src/buck/test

# Flint
RUN git clone https://github.com/L2Program/FlintPlusPlus.git /usr/src/flint && \
    cd /usr/src/flint/flint && \
    ldconfig && \
    make && \
    ln -s /usr/src/flint/flint/flint++ /usr/local/bin/flint++ && \
    rm -rf /usr/src/flint/.git
  
#
# Now that buck is installed time to make the buckconfig
#
ADD buckconfig /root/.buckconfig
RUN sed -i -e "s|\${CXXFLAGS}|${CXXFLAGS}|g" -e "s|\${CC}|${CC}|g" -e "s|\${CXX}|${CXX}|g" /root/.buckconfig

# Right now, if buckd is enabled in virtualbox one of two things will happen:
#  - If the project is mounted on a virtualbox shared folders dir,
#    mmap will not work, and https://github.com/facebook/buck/blob/master/src/com/facebook/buck/cxx/ObjectFileScrubbers.java
#    will fail
#  - If the project is mounted on NFS, mmap works, but when 'buck clean'
#    is run, watchman keeps handles on some files, and creates zombie
#    $PROJECT/.buckd/.nfs* files. Then buck clean fails because .buckd
#    cannot be deleted. Until one of these problems is fixed, it's a
#    worse user experience to use buckd
RUN echo 'if lspci | grep "VirtualBox" 2>&1 >/dev/null; then export NO_BUCKD=1; fi' >> /root/.bashrc

WORKDIR /root
