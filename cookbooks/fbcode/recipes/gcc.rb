if node['fb_code']['gcc']['build_gcc']
  include_recipe 'fbcode::build_gcc'
  return
end

package [
  'apt-utils',
  'python-software-properties',
  'software-properties-common',
]

apt_repository 'gcc-releases' do
  uri 'ppa:ubuntu-toolchain-r/test'
  distribution node['lsb']['codename']
end

package [
  'g++-5',
  'gdb',
  'gcc',
]
