CLANG_VERSION = node['fb_code']['clang']['version']

apt_repository 'llvm' do
  uri "http://llvm.org/apt/#{node['lsb']['codename']}"
  distribution "llvm-toolchain-#{node['lsb']['codename']}-#{CLANG_VERSION}"
  components ['main']
  # llvm.org doesn't serve this over https...
  key 'http://llvm.org/apt/llvm-snapshot.gpg.key'
end

package [
  "clang-#{CLANG_VERSION}",
  "clang-format-#{CLANG_VERSION}",
  "clang-tidy-#{CLANG_VERSION}",
  'lldb',
  "llvm-#{CLANG_VERSION}-dev",
]
