# Generic packages required to build most c++ programs
package [
  'autoconf',
  'automake',
  'bison',
  'build-essential',
  'cmake',
  'curl',
  'flex',
  'gdb',
  'gdc',
  'git',
  'make',
  'pkg-config',
]

include_recipe 'fbcode::clang'
include_recipe 'fbcode::gcc'
