#
# Cookbook:: cassandradb
# Recipe:: system_unit
#
# Copyright:: 2020, The Authors, All Rights Reserved.


app_name =  node['cassandra']['properties']['app_name']

# systemd unit for the Cassandra
systemd_unit "#{app_name}.service" do
  content <<-EOU.gsub(/^\s+/, '')
  [Unit]
  Description=#{app_name}

  [Service]
  ExecStart=/usr/local/cassandra/bin/cassandra -f
  ExecReload=/bin/kill -HUP $MAINPID
  KillMode=control-group
  Restart=always

  [Install]
  WantedBy=multi-user.target
  EOU
  action %i[create enable]
end
