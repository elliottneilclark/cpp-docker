config, = BuildEnv.get_settings(node, 'folly', [])
unless config['install'] then return end

package [
  'libgmp-dev',
  'libmpfr-dev',
  'libmpc-dev',
  'flex',
  'zlib1g-dev',
  'unzip',
  'zip',
  'pkg-config',
]

git 'gcc' do
  repository config['repo']
  destination config['src_dir']
  branch config['revision']
  action [:sync]
  notifies :run, 'build_gcc', :immediately
end

execute 'build_gcc' do
  command <<-EOF
export BUILD_DIR="$(mktemp -d)" &&
cd "$BUILD_DIR" &&
"#{config['src_dir']}/configure"
 -v \
 --with-pkgversion="#{config['release_string']}" \
 --enable-languages=c,c++ \
 --prefix=/opt/facebook/gcc \
 --program-suffix=-5.3.0 \
 --enable-shared \
 --enable-linker-build-id \
 --without-included-gettext \
 --enable-threads=posix \
 --enable-nls \
 --with-sysroot=/ \
 --enable-clocale=gnu \
 --enable-libstdcxx-debug \
 --enable-libstdcxx-time=yes \
 --with-default-libstdcxx-abi=new \
 --enable-gnu-unique-object \
 --disable-vtable-verify \
 --enable-libmpx \
 --enable-plugin \
 --with-system-zlib \
 --disable-browser-plugin \
 --with-arch-directory=amd64 \
 --enable-multiarch \
 --disable-werror \
 --enable-multilib \
 --with-arch-32=i686 \
 --with-abi=m64 \
 --with-multilib-list=m32,m64 \
 --with-tune=generic \
 --enable-checking=release \
 --build=x86_64-linux-gnu \
 --host=x86_64-linux-gnu \
 --target=x86_64-linux-gnu &&
make &&
make install &&
rm -rf "$BUILD_DIR"
EOF
end
