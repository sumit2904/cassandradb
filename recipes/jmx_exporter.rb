#
# Cookbook:: cassandradb
# Recipe:: jmx_exporter
#
# Copyright:: 2020, The Authors, All Rights Reserved.


cassandradirectory = node['cassandra']['properties']['cassandrahome']


directory "#{cassandradirectory}/jmx-exporter/" do
  recursive true
  action :create
end

execute "jmx_exporter" do
  command "wget https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.12.0/jmx_prometheus_javaagent-0.12.0.jar"
  cwd "/tmp/extracted/"
end

execute "cp -pr jmx_prometheus_javaagent-0.12.0.jar #{cassandradirectory}/jmx-exporter/" do
  cwd "/tmp/extracted/"
end

template "#{cassandradirectory}/conf/jvm.options" do
  source "jvm.options.erb"
  owner 'cassandra'
  group 'cassandra'
#  notifies :reload, 'service[cassandra]', :delayed
end

template "#{cassandradirectory}/jmx-exporter/cassandra.yml" do
  source "cassandra.yml.erb"
  owner 'cassandra'
  group 'cassandra'
#  notifies :reload, 'service[cassandra]', :delayed
end
