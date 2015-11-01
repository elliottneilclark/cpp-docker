FROM ubuntu:15.10

# Accept the oracle java license
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections

# Install all of the prerequisites for folly, and install g++-5 to get c++14 features
RUN apt-get update 
RUN apt-get -y install software-properties-common python-software-properties 
RUN apt-add-repository ppa:ubuntu-toolchain-r/test 
RUN add-apt-repository ppa:webupd8team/java 
RUN apt-get update  
RUN apt-get -y install \ 
    automake \
    autoconf \
    autoconf-archive \
	cmake \
    libtool \
    libboost-all-dev \
    libevent-dev \
    libunwind8-dev \
    libdouble-conversion-dev \
    libgoogle-glog-dev \
    libgflags-dev \
    liblz4-dev \
    liblzma-dev \
    libsnappy-dev \
    make \
    zlib1g-dev \
    binutils-dev \
    libjemalloc-dev \
    libssl-dev \
    libgtest-dev \
    git \
    oracle-java8-installer \
    ant \
    curl \
    g++-5 \ 
flex \
bison \
libkrb5-dev \
libsasl2-dev \
libnuma-dev \
pkg-config \
libcap-dev \
gperf \
wget \
    unzip 
RUN apt-get clean

# Download and install folly, build with default tools
RUN git clone --depth 1 https://github.com/facebook/folly.git /usr/src/folly 
#RUN cd /usr/src/folly/folly 
WORKDIR /usr/src/folly/folly
RUN autoreconf -ivf 
RUN CXX=/usr/bin/g++-5 CC=/usr/bin/gcc-5 ./configure 
RUN make 
RUN make install 
RUN make clean
WORKDIR /root
# RUN make check

# Download and install wangle, build with default tools
RUN git clone https://github.com/facebook/wangle.git /usr/src/wangle
#RUN cd /usr/src/wangle/wangle
WORKDIR /usr/src/wangle/wangle
RUN cd ../ && git checkout e15b84fd02ba8135927d54e8e586e6d8cc275f96
RUN CMAKE_CXX_FLAGS="-latomic" CMAKE_C_FLAGS="-latomic" CMAKE_EXE_LINKER_FLAGS="-latomic" cmake .
RUN CMAKE_CXX_FLAGS="-latomic" CMAKE_C_FLAGS="-latomic" CMAKE_EXE_LINKER_FLAGS="-latomic" make -j8
RUN make install
RUN ldconfig

RUN git clone https://github.com/facebook/proxygen.git /usr/src/proxygen
#RUN cd /usr/src/proxygen/proxygen
WORKDIR /usr/src/proxygen/proxygen
RUN autoreconf -ivf
RUN CXX=/usr/bin/g++-5 CC=/usr/bin/gcc-5 CFLAGS="-latomic" CXXFLAGS="-latomic" ./configure
RUN make -j 8
RUN make install

# Download and install proxygen, build with default tools
#RUN git clone https://github.com/facebook/proxygen.git /usr/src/proxygen && \
#  cd /usr/src/proxygen/proxygen && \
#  CMAKE_CXX_COMPILER=/usr/bin/g++-5 \
#	CMAKE_C_COMPILER=/usr/bin/gcc-5 \
#	CXX=/usr/bin/g++-5 \ 
#	CC=/usr/bin/gcc-5 \
#	CMAKE_CXX_FLAGS="-latomic" CMAKE_C_FLAGS="-latomic" CMAKE_EXE_LINKER_FLAGS="-latomic" \
#	CFLAGS="-latomic" CXX_FLAGS="-latomic" ./deps.sh && \
#  make clean && \
#  cd folly/folly && \
#  make clean && \
#  cd wangle/wangle && \
#  make clean


# Download and install watchman, build with default tools
RUN git clone --depth 1 --branch v3.8.0 https://github.com/facebook/watchman.git /usr/src/watchman 
#RUN cd /usr/src/watchman 
WORKDIR /usr/src/watchman 
RUN ./autogen.sh 
RUN CXX=/usr/bin/g++-5 CC=/usr/bin/gcc-5 ./configure 
RUN make 
RUN make install 
RUN make clean

# Download and install buck. Run it once so that it does its own first-run build process
# Remove some extra files that end up being ~250M combined
RUN git clone --depth 1 https://github.com/facebook/buck.git /usr/src/buck 
#RUN cd /usr/src/buck 
WORKDIR /usr/src/buck 
RUN ant 
RUN ln -s /usr/src/buck/bin/buck /usr/local/bin/buck 
RUN ln -s /usr/src/buck/bin/buckd /usr/local/bin/buckd 
RUN /usr/local/bin/buck --help; echo "" 
RUN rm -rf /usr/src/buck/.git 
RUN rm -rf /usr/src/buck/test

#RUN echo 'NO_BUCKD=1' >> /root/.bashrc 
ADD helloworld /root/src/helloworld
ADD .buckconfig /root/.buckconfig
WORKDIR /root

# Right now, if buckd is enabled one of two things will happen:
#  - If the project is mounted on a virtualbox shared folders dir,
#    mmap will not work, and https://github.com/facebook/buck/blob/master/src/com/facebook/buck/cxx/ObjectFileScrubbers.java
#    will fail
#  - If the project is mounted on NFS, mmap works, but when 'buck clean'
#    is run, watchman keeps handles on some files, and creates zombie
#    $PROJECT/.buckd/.nfs* files. Then buck clean fails because .buckd
#    cannot be deleted. Until one of these problems is fixed, it's a
#    worse user experience to use buckd
#ENV NO_BUCKD 1
