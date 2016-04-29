dependencies = ['watchman']
config, build, _, recipes = BuildEnv.get_settings(node, 'buck', dependencies)
unless config['install'] then return end
include_recipe recipes

package [
  'ant',
  'build-essential',
  'openjdk-8-jdk',
  'python-dev',
]

compile 'buck' do
  deps dependencies
  output_file "#{config['src_dir']}/bin/buck"
  build_cmd "ant && { \"#{config['src_dir']}/bin/buck\" --help || true; }"
end

link 'buck_bin_link' do
  target_file "#{build['install_prefix']}/bin/buck"
  to "#{config['src_dir']}/bin/buck"
end

link 'buckd_bin_link' do
  target_file "#{build['install_prefix']}/bin/buckd"
  to "#{config['src_dir']}/bin/buckd"
end

if config['install_buckconfig']
  template '/root/.buckconfig' do
    source 'buckconfig.erb'
  end
end
