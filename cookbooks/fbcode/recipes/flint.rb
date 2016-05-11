config, build, _, recipes = BuildEnv.get_settings(node, 'flint', [])
unless config['install'] then return end
include_recipe recipes

compile 'flint' do
  output_file "#{build['install_prefix']}/bin/flint++"
  build_dir "#{config['src_dir']}/flint"
  build_cmd 'make clean && make'
  notifies :create, 'remote_file[install_flint]', :immediately
end

remote_file 'install_flint' do
  source "file:///#{config['src_dir']}/flint/flint++"
  path "#{build['install_prefix']}/bin/flint++"
  action :nothing
  mode '0755'
end
