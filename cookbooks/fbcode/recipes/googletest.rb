config, build, _, recipes = BuildEnv.get_settings(node, 'googletest', [])
unless config['install'] then return end
include_recipe recipes

compile 'googletest' do
  output_file "#{build['install_prefix']}/lib/libgtest.a"
  build_cmd <<-EOF
cmake \
  -DCMAKE_INSTALL_PREFIX="#{build['install_prefix']}" \
  -DCMAKE_BUILD_TYPE=Release \
  -Dgtest_build_samples=ON \
  .  && \
make #{build['make_parallelism']} && \
make install && \
make clean
EOF
end
