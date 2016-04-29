dependencies = ['boost', 'double_conversion', 'glog', 'gflags', 'googletest']
config, build, _, recipes = BuildEnv.get_settings(node, 'folly', dependencies)
unless config['install'] then return end
include_recipe recipes

package [
  'libevent-dev',
  'libjemalloc-dev',
  'libtool',
  'libunwind8-dev',
  'libssl-dev',
]

compile 'folly' do
  deps dependencies
  output_file "#{build['install_prefix']}/lib/libfolly.a"
  build_dir "#{config['src_dir']}/folly"
  build_cmd <<-EOF
autoreconf -ivf && \
./configure --prefix="#{build['install_prefix']}" && \
make #{build['make_parallelism']} && \
make install && \
make clean
EOF
end
