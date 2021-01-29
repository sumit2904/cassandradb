
user 'cassandra' do
  comment 'cassandra user'
  manage_home true
  #gid 'cassandra'
  home  '/home/cassandra/'
  shell '/bin/bash'
end
