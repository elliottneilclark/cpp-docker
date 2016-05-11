dependencies = ['folly', 'boost']
config, build, env, recipes = BuildEnv.get_settings(node, 'wangle', dependencies)
unless config['install'] then return end
include_recipe recipes

package [
]

# Download and install wangle, build with clang or gcc-5
# Wangle has a hard coded CXXFLAGS so we have to sed them for now.
# When they have an over-ridable default then this can go back to normal
#
# Also wangle's build of gmock doesn't seem to work at all.
# Should figure out why.
compile 'wangle' do
  deps dependencies
  output_file "#{build['install_prefix']}/lib/libwangle.a"
  build_dir "#{config['src_dir']}/wangle"
  build_cmd <<-EOF
sed -i \
    -e 's|set(CMAKE_CXX_FLAGS .*)|set(CMAKE_CXX_FLAGS "#{build['cxxflags']}")|' \
    -e 's/wangle SHARED/wangle STATIC/' \
    "#{config['src_dir']}/wangle/CMakeLists.txt" && \
cmake \
  -DCMAKE_INSTALL_PREFIX="#{build['install_prefix']}" \
  -DBUILD_TESTS=OFF \
  -DBOOST_ROOT="#{env['BOOST_ROOT']}" \
  -DFOLLY_LIBRARYDIR="#{build['libdirs']['folly']}" \
  -DFOLLY_INCLUDE_DIR="#{build['includes']['folly']}" \
  . && \
make #{build['make_parallelism']} && \
make install && \
make clean && \
sed -i 's/wangle STATIC/wangle SHARED/' "#{config['src_dir']}/wangle/CMakeLists.txt" && \
cmake \
  -DCMAKE_INSTALL_PREFIX="#{build['install_prefix']}" \
  -DBUILD_TESTS=OFF \
  -DBOOST_ROOT="#{env['BOOST_ROOT']}" \
  -DFOLLY_LIBRARYDIR="#{build['libdirs']['folly']}" \
  -DFOLLY_INCLUDE_DIR="#{build['includes']['folly']}" \
  . && \
make #{build['make_parallelism']} && \
make install && \
make clean
EOF
end
