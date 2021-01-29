#
# Cookbook:: cassandradb
# Recipe:: default
#
# Copyright:: 2020, The Authors, All Rights Reserved.

include_recipe "cassandradb::user-recipe"

#include_recipe "cassandradb::system_unit"

appname = node['cassandra']['properties']['appname']
cassandradirectory = node['cassandra']['properties']['cassandrahome']
version = node['cassandra']['properties']['version']
binaryartifact = node['cassandra']['properties']['binaryartifact']

apt_update 'update' do
  action "update"
end

execute "timedatectl set-timezone #{node['timezone']['tz']}"

directory "#{cassandradirectory}" do
  recursive true
  action :create
end

directory "/tmp/extracted" do
  recursive true
  action :create
end


execute "download_source" do
  command "wget http://apachemirror.wuchna.com/cassandra/#{version}/#{binaryartifact}"
  cwd "/tmp/extracted/"
end


bash "unpack cassandra source" do

   code <<-EOS

   tar --absolute-names -xzf /tmp/extracted/#{binaryartifact} -C /tmp/extracted/
   cp -r /tmp/extracted/apache-cassandra-#{version}/* #{cassandradirectory}

   EOS

end
#execute 'extract_tar' do
#  command "sudo tar --absolute-names -xf /tmp/extracted/#{binaryartifact} -C ./"
#  cwd "/tmp/extracted/#{appname}"
#end

#execute "move_sourcefile" do
#  command "cp -r /tmp/extracted/#{appname}/* #{cassandradirectory}"
#  cwd "/tmp/extracted"
#end

include_recipe "cassandradb::jmx_exporter"

execute "chown -R cassandra:cassandra #{cassandradirectory}" do
  cwd "#{cassandradirectory}"
end


apt_repository "openjdk-r" do
  uri "ppa:openjdk-r/ppa"
end

apt_package 'openjdk-8-jre-headless'

execute "java_8_default" do
  command "sudo update-java-alternatives -s java-1.8.0-openjdk-amd64 && touch /usr/local/src/java_alternatives.lock"
  not_if { ::File.exists?('/usr/local/src/java_alternatives.lock')}
end

template "#{cassandradirectory}/conf/cassandra.yaml" do
  source "cassandra.yaml.erb"
  owner 'cassandra'
  group 'cassandra'
#  notifies :reload, 'service[cassandra]', :delayed
end

# systemd unit for the Cassandra

systemd_unit "#{appname}.service" do
  content <<-EOU.gsub(/^\s+/, '')
  [Unit]
  Description=Cassandra Database Service
  After=network-online.target
  Requires=network-online.target

  [Service]
  User=cassandra
  Group=cassandra
  ExecStart=/usr/local/cassandra/bin/cassandra -f
  ExecReload=/bin/kill -HUP $MAINPID
  KillMode=control-group
  Restart=always

  [Install]
  WantedBy=multi-user.target
  EOU
  action %i[create enable]
end


# starting the systemd service
service "#{appname}" do
  supports status: true, restart: true, reload: true
  action :restart
end
