dependencies = ['wangle', 'folly']
config, build, _, recipes = BuildEnv.get_settings(node, :proxygen, dependencies)
unless config['install'] then return end
include_recipe recipes

package [
  'autoconf-archive',
  'libcap-dev',
  'gperf',
  'wget',
  'unzip',
]

# TODO: Patch for proxygen. Looks like gflags somehow gets
#      included in httpclient/samples/curl/CurlClient.cpp
#      when in /usr/local/include rather than /opt/facebook/include
compile 'proxygen' do
  deps dependencies
  output_file "#{build['install_prefix']}/lib/libproxygenlib.a"
  build_dir "#{config['src_dir']}/proxygen"
  build_cmd <<-EOF
if ! grep 'gflags\.h' httpclient/samples/curl/CurlClient.cpp; then \
  sed -i '1s|^|#include <gflags/gflags.h>\\n|' \
    httpclient/samples/curl/CurlClient.cpp; \
fi; \
autoreconf -ivf && \
./configure --prefix="#{build['install_prefix']}" && \
make #{build['make_parallelism']} && \
make install && \
make clean
EOF
end
