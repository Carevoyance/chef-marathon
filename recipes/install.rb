#
# Cookbook Name:: marathon
# Recipe:: install
#
# Copyright (C) 2015 Medidata Solutions, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe 'chef-sugar'
include_recipe 'java::default'

#
# Install default repos
#

include_recipe 'marathon::repo' if node['marathon']['repo']

#
# Install package
#

case node['platform']
when 'debian', 'ubuntu'
  %w( unzip default-jre-headless libcurl3 libsvn1).each do |pkg|
    package pkg do
      action :install
    end
  end

  package 'marathon' do
    action :install
    # --no-install-recommends to skip installing zk. unnecessary.
    options '--no-install-recommends'
    # Glob is necessary to select the deb version string
    version "#{node['marathon']['version']}*"
  end
when 'rhel', 'redhat', 'centos', 'amazon', 'scientific'
  # get the version-release string via repoquery
  cmd = Mixlib::ShellOut.new("repoquery --queryformat '%{VERSION}-%{RELEASE}' -q marathon-#{node['marathon']['version']}*")
  cmd.run_command
  cmd.error!
  rpm_version = cmd.stdout.strip

  yum_package 'marathon' do
    version rpm_version
    not_if { ::File.exist? '/usr/local/sbin/marathon' }
  end
end


