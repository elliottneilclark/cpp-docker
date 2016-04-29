config, build, _, recipes = BuildEnv.get_settings(node, 'glog', [])
unless config['install'] then return end
include_recipe recipes

compile 'glog' do
  output_file "#{build['install_prefix']}/lib/libglog.a"
  build_cmd <<-EOF
autoreconf -ivf && \
./configure --prefix="#{build['install_prefix']}" && \
make #{build['make_parallelism']} && \
make install && \
make clean
EOF
end
