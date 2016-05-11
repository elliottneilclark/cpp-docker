resource_name :compile

property :name, String
property :deps, Array, :default => []
property :ldconfig, [TrueClass, FalseClass], :default => true
property :build_cmd, String
property :build_dir, String
property :mk_bindir, [TrueClass, FalseClass], :default => true
property :mk_libdir, [TrueClass, FalseClass], :default => true
property :output_file, String

default_action :build

action :build do
  config, build, env, recipes = BuildEnv.get_settings(node, name, deps)

  unless config['install'] then return end

  recipes.each do |recipe|
    include_recipe recipe
  end
  build_cwd = build_dir ? build_dir : config['src_dir']

  directory "#{build['install_prefix']}/bin" do
    recursive true
    only_if { mk_bindir }
  end

  directory "#{build['install_prefix']}/lib" do
    recursive true
    only_if { mk_libdir }
  end

  git_result = git name do
    repository config['repo']
    destination config['src_dir']
    enable_submodules true
    revision config['revision']
    action ['sync']
    timeout 3600
    if new_resource.name == 'boost' then depth 1 end
  end

  should_build = git_result.updated_by_last_action? || \
    !::File.exist?(new_resource.output_file)
  build_result = execute "build_#{new_resource.name}" do
    cwd build_cwd
    environment env
    command build_cmd
    timeout 3600
    only_if { should_build }
  end

  ruby_block 'send_notifications' do
    block { new_resource.updated_by_last_action(true) }
    only_if { build_result.updated_by_last_action? }
  end

  if ldconfig
    file "#{new_resource.name}_ldconfig_conf" do
      path "/etc/ld.so.conf.d/#{build['install_prefix'].tr('/', '_')}.conf"
      content "#{build['install_prefix']}/lib"
      action :create_if_missing
      only_if { build_result.updated_by_last_action? }
    end
    execute 'ldconfig' do
      command 'ldconfig'
      only_if { build_result.updated_by_last_action? }
    end
  end
end
