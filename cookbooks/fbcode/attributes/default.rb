default['fb_code'] = {}
fbcode = default['fb_code']

fbcode['gcc']['install'] = true
fbcode['gcc']['build_gcc'] = false
fbcode['gcc']['repo'] = 'git://gcc.gnu.org/git/gcc.git'
fbcode['gcc']['src_path'] = '/usr/src/gcc'
fbcode['gcc']['revision'] = 'gcc_5_3_0_release'
fbcode['gcc']['release_string'] = 'fbcode 5.3.0'

fbcode['clang']['install'] = true
fbcode['clang']['version'] = '3.8'

fbcode['build']['cflags'] = '-D_GLIBCXX_USE_CXX11_ABI=0 -fPIC -g -fno-omit-frame-pointer -O3 -pthread'
fbcode['build']['cxxflags'] = '-std=c++14 -D_GLIBCXX_USE_CXX11_ABI=0 -fPIC -g -fno-omit-frame-pointer -O3 -pthread'
fbcode['build']['cc'] = '/usr/bin/gcc-5'
fbcode['build']['cxx'] = '/usr/bin/g++-5'
fbcode['build']['install_prefix'] = '/opt/facebook'
fbcode['build']['make_parallelism'] = '-j2'

fbcode['buck']['install'] = true
fbcode['buck']['repo'] = 'https://github.com/facebook/buck.git'
fbcode['buck']['revision'] = '673c14330b16b9e86ea425ad3d369dc28f8ae83a'
fbcode['buck']['src_dir'] = '/usr/src/buck'
fbcode['buck']['install_buckconfig'] = true
fbcode['buck']['clang']['cc'] = "/usr/bin/clang-#{fbcode['clang']['version']}"
fbcode['buck']['clang']['cxx'] = "/usr/bin/clang++-#{fbcode['clang']['version']}"
fbcode['buck']['gcc']['cc'] = '/usr/bin/gcc-5'
fbcode['buck']['gcc']['cxx'] = '/usr/bin/g++-5'
fbcode['buck']['default_compiler'] = 'clang'

fbcode['watchman']['install'] = true
fbcode['watchman']['repo'] = 'https://github.com/facebook/watchman.git'
fbcode['watchman']['revision'] = 'v4.5.0'
fbcode['watchman']['src_dir'] = '/usr/src/watchman'

fbcode['gflags']['install'] = true
fbcode['gflags']['repo'] = 'https://github.com/gflags/gflags.git'
fbcode['gflags']['revision'] = 'v2.1.2'
fbcode['gflags']['src_dir'] = '/usr/src/gflags'

fbcode['glog']['install'] = true
fbcode['glog']['repo'] = 'https://github.com/google/glog.git'
fbcode['glog']['revision'] = 'v0.3.4'
fbcode['glog']['src_dir'] = '/usr/src/glog'

fbcode['folly']['install'] = true
fbcode['folly']['repo'] = 'https://github.com/facebook/folly.git'
fbcode['folly']['revision'] = 'd78429749bc315b744e1c7ae5f0969fbdf31ca3d'
fbcode['folly']['src_dir'] = '/usr/src/folly'

fbcode['wangle']['install'] = true
fbcode['wangle']['repo'] = 'https://github.com/facebook/wangle.git'
fbcode['wangle']['revision'] = '29451338fdb05ca1691c102ab98e824b438ff90a'
fbcode['wangle']['src_dir'] = '/usr/src/wangle'

fbcode['proxygen']['install'] = true
fbcode['proxygen']['repo'] = 'https://github.com/facebook/proxygen.git'
fbcode['proxygen']['revision'] = '57f368a7b7cf2b6d6a1ae4d4bd5acf9289ba9b42'
fbcode['proxygen']['src_dir'] = '/usr/src/proxygen'

fbcode['googletest']['install'] = true
fbcode['googletest']['repo'] = 'https://github.com/google/googletest.git'
fbcode['googletest']['revision'] = 'd225acc90bc3a8c420a9bcd1f033033c1ccd7fe0'
fbcode['googletest']['src_dir'] = '/usr/src/googletest'

fbcode['double_conversion']['install'] = true
fbcode['double_conversion']['repo'] = 'https://github.com/google/double-conversion.git'
fbcode['double_conversion']['revision'] = '7499d0b6926e1a5a3d9deeb4c29b4f8bfc742c42'
fbcode['double_conversion']['src_dir'] = '/usr/src/double_conversion'

fbcode['boost']['install'] = true
fbcode['boost']['repo'] = 'https://github.com/boostorg/boost.git'
fbcode['boost']['revision'] = 'boost-1.60.0'
fbcode['boost']['src_dir'] = '/usr/src/boost'

fbcode['flint']['install'] = true
fbcode['flint']['revision'] = 'master'
fbcode['flint']['src_dir'] = '/usr/src/flint'
fbcode['flint']['repo'] = 'https://github.com/L2Program/FlintPlusPlus.git'
