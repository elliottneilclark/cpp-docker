FROM ubuntu:15.10


# Accept the oracle java license
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections

# Add utils to enable changing apt lists
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -qq -y install \
       apt-utils \
       python-software-properties \
       software-properties-common \
       wget && \
    DEBIAN_FRONTEND=noninteractive apt-get -qq clean && \
    DEBIAN_FRONTEND=noninteractive apt-get -y -qq autoremove && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/ && \
    rm -rf /tmp/*

# Add llvm and java repos
RUN echo "yes" | add-apt-repository 'deb http://llvm.org/apt/wily/ llvm-toolchain-wily-3.7 main' && \
    wget -O - http://llvm.org/apt/llvm-snapshot.gpg.key | apt-key add - && \
    echo "yes" | apt-add-repository ppa:ubuntu-toolchain-r/test && \
    echo "yes" | add-apt-repository ppa:webupd8team/java

# Install all of the prerequisites for folly, and install g++-5 to get c++14 features
RUN DEBIAN_FRONTEND=noninteractive apt-get -qq update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y -qq install \ 
		    ant \
        autoconf \
        autoconf-archive \
        automake \
        binutils-dev \
        bison \
        build-essential \
        clang-3.7 \
        clang-tidy-3.7 \
        cmake \
        curl \
        flex \
        g++-5 \
        gdc \
        git \
        gperf \
        libboost-all-dev \
        libcap-dev \
        libdouble-conversion-dev \
        libevent-dev \
        libgflags-dev \
        libgoogle-glog-dev \
        libgtest-dev \
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
        llvm-3.7-dev \
        make \
        oracle-java8-installer \
        pciutils \
        pkg-config \
        unzip \
        zlib1g-dev && \
    DEBIAN_FRONTEND=noninteractive apt-get -qq clean && \
    DEBIAN_FRONTEND=noninteractive apt-get -y -qq autoremove && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/ && \
    rm -rf /tmp/*

# Don't use -j8 or anything like that that gcc errors out in unpredictable ways.
# Better to have the docker build step take a little while longer than to error out.

ENV CC /usr/bin/gcc-5
ENV CXX /usr/bin/g++-5
ENV CMAKE_C_COMPILER /usr/bin/gcc-5
ENV CMAKE_CXX_COMPILER /usr/bin/g++-5

ENV FOLLY_SHA f2a8b592861472bf47495c40519fdd778b420bc1 
ENV WANGLE_SHA 9ed41ea931c1039d2eb80b9152577bbe714f9b71
ENV PROXYGEN_SHA d5721badd9e2a416036e2034112ea90c34918309 
ENV BUCK_SHA 82edf0bdbe63ef99cff17114458d4bd442a55fd7 
ENV WATCHMAN_VER v4.3.0

#
# Build the tools
#

# Download and install watchman, build with g++5 tools
RUN git clone --depth 1 --branch ${WATCHMAN_VER} https://github.com/facebook/watchman.git /usr/src/watchman && \
    cd /usr/src/watchman && \
    ./autogen.sh && \
    ./configure && \
    make && \
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
    /usr/local/bin/buck --help || true && \
    rm -rf /usr/src/buck/.git && \
    rm -rf /usr/src/buck/test

# Flint
RUN git clone https://github.com/L2Program/FlintPlusPlus.git /usr/src/flint && \
    cd /usr/src/flint/flint && \
    make && \
    ln -s /usr/src/flint/flint/flint++ /usr/local/bin/flint++ 
#
# Build the Cpp libraries.
#

# Download and install folly, build with g++5 tools
RUN git clone https://github.com/facebook/folly.git /usr/src/folly && \
	  cd /usr/src/folly/folly && \
    git checkout ${FOLLY_SHA} && \
    autoreconf -ivf && \
    ./configure && \
    make && \
    make install && \
    make clean && \
    rm -rf /usr/src/folly/.git

# Download and install wangle, build with g++5 tools
RUN git clone https://github.com/facebook/wangle.git /usr/src/wangle && \
    cd /usr/src/wangle/wangle && \
    git checkout ${WANGLE_SHA} && \
    cmake . && \
    make && \
    make install && \
    make clean && \
    rm -rf /usr/src/wangle/.git

RUN git clone https://github.com/facebook/proxygen.git /usr/src/proxygen && \
    cd /usr/src/proxygen/proxygen && \
    git checkout ${PROXYGEN_SHA} && \
    autoreconf -ivf && \
    ./configure && \
    make && \
    make install && \
	  make clean && \
    rm -rf /usr/src/proxygen/.git


ADD .buckconfig /root/.buckconfig
WORKDIR /root

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
