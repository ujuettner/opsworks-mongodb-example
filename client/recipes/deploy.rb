execute 'kill node process' do
  command 'pkill node; /bin/true'
  action :nothing
end

node['deploy'].each do |application, deploy|
  unless deploy['application_type'] == 'nodejs' && deploy['application'] == node['mongodb']['app_name']
    Chef::Log.debug("Skipping application #{application} as we're not intereseted in it.")
    next
  end

  current_dir = ::File.join(deploy['deploy_to'], 'current')

  mongodb_instances = search(:node, 'role:mongodb')
  Chef::Log.debug("MongoDB instances found: #{mongodb_instances.inspect}")

  mongo_config = {}
  mongo_config['dbUrl'] = mongodb_instances.map{|mongodb_instance| "#{mongodb_instance['private_ip']}:#{node['mongodb']['config']['port']}/?auto_reconnect=true"}
  mongo_config['rsName'] = node['mongodb']['config']['replSet']
  Chef::Log.debug("Config: #{mongo_config.inspect}")

  template ::File.join(current_dir, 'mongo.json') do
    source 'mongo.json.erb'
    mode '0644'
    variables({
      :mongo_config => mongo_config.to_json
    })
    notifies :run, 'execute[kill node process]'
  end
end
