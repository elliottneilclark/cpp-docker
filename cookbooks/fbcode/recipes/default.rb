#
# Cookbook Name:: fbcode
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

include_recipe 'fbcode::boost'
include_recipe 'fbcode::buck'
include_recipe 'fbcode::double_conversion'
include_recipe 'fbcode::flint'
include_recipe 'fbcode::folly'
include_recipe 'fbcode::gflags'
include_recipe 'fbcode::glog'
include_recipe 'fbcode::googletest'
include_recipe 'fbcode::watchman'
include_recipe 'fbcode::wangle'
include_recipe 'fbcode::proxygen'
