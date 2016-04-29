config, build, _, recipes = BuildEnv.get_settings(node, 'boost', [])
unless config['install'] then return end
include_recipe recipes

package [
  'libbz2-dev',
  'zlib1g-dev',
  'python-dev',
]

compile 'boost' do
  output_file "#{build['install_prefix']}/lib/libboost_atomic.a"
  build_cmd <<-EOF
./bootstrap.sh --with-toolset=gcc && \
./b2 \
  --toolset=gcc \
  link=shared,static \
  cxxflags="#{build['cxxflags']}" \
  cflags="#{build['cflags']}" \
  #{build['make_parallelism']} \
  headers && \
./b2 \
  --toolset=gcc \
  link=shared,static \
  cxxflags="#{build['cxxflags']}" \
  cflags="#{build['cflags']}" \
  #{build['make_parallelism']} && \
./b2 \
  --toolset=gcc \
  link=shared,static \
  cxxflags="#{build['cxxflags']}" \
  cflags="#{build['cflags']}" \
  install \
  --prefix="#{build['install_prefix']}" && \
./b2 clean
EOF
end
