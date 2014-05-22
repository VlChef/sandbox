ntp = node['ntp']


include_recipe 'git'


admins = Chef::EncryptedDataBagItem.load('admins', 'generic')

Chef::Log.warn(admins)
Chef::Log.warn(admins['test'])
package 'ntp' do
  action :install
end

template '/etc/ntp.conf' do
  variables(
      driftfile: ntp['driftfile']
  )
  action :create
  notifies :restart, 'service[ntp]'
end

service 'ntp' do
  action :nothing
end
