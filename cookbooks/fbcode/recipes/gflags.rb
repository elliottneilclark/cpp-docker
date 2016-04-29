config, build, _, recipes = BuildEnv.get_settings(node, 'gflags', [])
unless config['install'] then return end
include_recipe recipes

compile 'gflags' do
  output_file "#{build['install_prefix']}/lib/libgflags.a"
  build_cmd <<-EOF
cmake \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="#{build['install_prefix']}" \
  -DBUILD_STATIC_LIBS=ON \
  -DBUILD_SHARED_LIBS=ON \
  -DBUILD_TESTING=ON \
  . && \
make #{build['make_parallelism']} && \
make install && \
make clean
EOF
end
