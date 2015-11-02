#FROM ubuntu:14.04
FROM ubuntu:15.10

# Accept the oracle java license
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections

# Install all of the prerequisites for folly, and install g++-5 to get c++14 features
RUN apt-get update && \
    apt-get -y install software-properties-common python-software-properties && \
    apt-add-repository ppa:ubuntu-toolchain-r/test && \
    add-apt-repository ppa:webupd8team/java && \
    apt-get update && \
    apt-get -y install \ 
		ant \
        autoconf-archive \
        autoconf \
        automake \
        binutils-dev \
        bison \
        cmake \
        curl \
        flex \
        g++-5 \
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
        make \
        oracle-java8-installer \
		pciutils \
        pkg-config \
        unzip \
        zlib1g-dev && \
    apt-get clean

# Download and install folly, build with g++5 tools
RUN git clone --depth 1 https://github.com/facebook/folly.git /usr/src/folly && \
	cd /usr/src/folly/folly && \
    autoreconf -ivf && \
    CXX=/usr/bin/g++-5 CC=/usr/bin/gcc-5 ./configure && \
    make && \
    make install && \
    make clean
# RUN make check

# Download and install wangle, build with g++5 tools
RUN git clone https://github.com/facebook/wangle.git /usr/src/wangle && \
    cd /usr/src/wangle/wangle && \
    git checkout e15b84fd02ba8135927d54e8e586e6d8cc275f96 && \
    CMAKE_CXX_COMPILER=/usr/bin/g++-5 CMAKE_C_COMPILER=/usr/bin/gcc-5 cmake . && \
    make -j8 && \
    make install && \
	make clean

RUN git clone https://github.com/facebook/proxygen.git /usr/src/proxygen && \
    cd /usr/src/proxygen/proxygen && \
    autoreconf -ivf && \
    CXX=/usr/bin/g++-5 CC=/usr/bin/gcc-5 ./configure && \
    make -j 8 && \
    make install && \
	make clean

# Download and install watchman, build with g++5 tools
RUN git clone --depth 1 --branch v3.8.0 https://github.com/facebook/watchman.git /usr/src/watchman && \
    cd /usr/src/watchman && \
    ./autogen.sh && \
    CXX=/usr/bin/g++-5 CC=/usr/bin/gcc-5 ./configure && \
    make && \
    make install && \
    make clean

# Download and install buck. Run it once so that it does its own first-run build process
# Remove some extra files that end up being ~250M combined
RUN git clone --depth 1 https://github.com/facebook/buck.git /usr/src/buck && \
    cd /usr/src/buck && \
    ant && \
    ln -s /usr/src/buck/bin/buck /usr/local/bin/buck && \
    ln -s /usr/src/buck/bin/buckd /usr/local/bin/buckd && \
    /usr/local/bin/buck --help; echo "" && \
    rm -rf /usr/src/buck/.git && \
    rm -rf /usr/src/buck/test

ADD helloworld /root/src/helloworld
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
