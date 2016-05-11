
module BuildEnv
  def self.install_prefix(node, lib)
    return node['fb_code'][lib].fetch(
      'install_prefix',
      node['fb_code']['build']['install_prefix'])
  end

  def self.get_settings(node, project, dependencies)
    build_settings = { 'libdirs' => {}, 'includes' => {} }
    env = {}
    recipes = ['fbcode::build']
    fbcode = node['fb_code']

    fbcode['build'].each do |k, v|
      build_settings[k] = fbcode[project].fetch(k, v)
    end

    dependencies.map do |dep|
      prefix = install_prefix(node, dep)
      build_settings['libdirs'][dep] = "#{prefix}/lib"
    end

    dependencies.map do |dep|
      prefix = install_prefix(node, dep)
      build_settings['includes'][dep] = "#{prefix}/include"
    end

    includes_string = \
      build_settings['includes'].values.uniq.map { |i| "-I#{i}" }.join(' ')

    build_settings['ldflags'] = \
      build_settings['libdirs'].values.uniq.map { |l| "-L#{l}" }.join(' ')
    build_settings['cflags'] = \
      "#{build_settings['cflags']} #{includes_string}"
    build_settings['cxxflags'] = \
      "#{build_settings['cxxflags']} #{includes_string}"

    recipes += dependencies.map { |dep| "fbcode::#{dep}" }

    {
      'CC' => 'cc',
      'CXX' => 'cxx',
      'CFLAGS' => 'cflags',
      'CXXFLAGS' => 'cxxflags',
      'LDFLAGS' => 'ldflags',
    }.each do |k, v|
      env[k] = build_settings[v]
    end

    env['BOOST_ROOT'] = install_prefix(node, 'boost')
    env['BOOST_LDFLAGS'] = env['LDFLAGS']
    env['BOOST_CPPFLAGS'] = env['CXXFLAGS']

    [fbcode[project], build_settings, env, recipes]
  end
end
