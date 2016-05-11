config, build, _, recipes = BuildEnv.get_settings(node, 'double_conversion', [])
unless config['install'] then return end
include_recipe recipes

compile 'double_conversion' do
  output_file "#{build['install_prefix']}/lib/libdouble-conversion.a"
  build_cmd <<-EOF
cmake \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="#{build['install_prefix']}" \
  . && \
make #{build['make_parallelism']} && \
make install && \
make clean && \
cmake -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_SHARED_LIBS=ON \
  -DCMAKE_INSTALL_PREFIX="#{build['install_prefix']}" \
  . && \
make #{build['make_parallelism']} && \
make install && \
make clean
EOF
end
