config, build, _, recipes = BuildEnv.get_settings(node, 'watchman', [])
unless config['install'] then return end
include_recipe recipes

compile 'watchman' do
  output_file "#{build['install_prefix']}/bin/watchman"
  build_cmd <<-EOF
./autogen.sh && \
./configure --prefix="#{build['install_prefix']}" && \
make #{build['make_parallelism']} && \
make install && \
make clean
EOF
end
