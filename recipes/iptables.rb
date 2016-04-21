# Create network script to add iptables
require 'erubis'

directory '/etc/network/if-pre-up.d' do
  action :create
  recursive true
end

directory '/etc/iptables' do
  action :create
end

template '/etc/network/if-pre-up.d/iptablesload' do
  action :create
  mode 0700
  variables ({
    :iptables_v4_file => node['base']['iptables']['rules_v4_file'],
    :iptables_dir => node['base']['iptables']['rules_dir']
  })
  owner 'root'
  group 'root'
end

# Create iptables configuration rules file
#internal_ip = node['rackspace']['private_ip'] if node['rackspace']
if platform?("ubuntu")
  vpn_ip_cmd = Mixlib::ShellOut.new("ifconfig | grep 'inet'| grep -v '127.0.0.1' | grep 10.10. | cut -d: -f2 | awk '{ print $1}'")
elsif platform?("fedora")
  vpn_ip_cmd = Mixlib::ShellOut.new("ifconfig | grep 'inet'| grep -v '127.0.0.1' | grep 10.10. | cut -d: -f2 | awk '{ print $2}'")
end

vpn_ip_cmd.run_command
vpn_ip = vpn_ip_cmd.stdout.delete!("\n")
ip = node['ipaddress']
node.set['base']['iptables']['vpn_ip'] = vpn_ip
node.set['base']['iptables']['ip'] = ip

rules_filter = ''
rules_prerouting = ''
rules_filter = Erubis::Eruby.new(node['base']['iptables']['rules_filter']).result(node['base']['iptables'].to_hash) unless node['base']['iptables']['rules_filter'].nil?
rules_prerouting = Erubis::Eruby.new(node['base']['iptables']['rules_prerouting']).result(node['base']['iptables'].to_hash) unless node['base']['iptables']['rules_prerouting'].nil?
rules = Erubis::Eruby.new(node['base']['iptables']['rules']).result(node['base']['iptables'].to_hash) unless node['base']['iptables']['rules'].nil?

template '/etc/iptables/rules.v4' do
  source 'rules.v4.erb'
  mode 0600
  owner 'root'
  group 'root'
  variables ({
    :rules_filter_policy => Erubis::Eruby.new(node['base']['iptables']['rules_filter_policy']).result(node['base']['iptables'].to_hash),
    :rules_filter_base => Erubis::Eruby.new(node['base']['iptables']['rules_filter_base']).result(node['base']['iptables'].to_hash),
    :rules_filter_vpn_base => Erubis::Eruby.new(node['base']['iptables']['rules_filter_vpn_base']).result(node['base']['iptables'].to_hash),
    :rules_filter => rules_filter,
    :rules_prerouting_policy => Erubis::Eruby.new(node['base']['iptables']['rules_prerouting_policy']).result(node['base']['iptables'].to_hash),
    :rules_prerouting_base => Erubis::Eruby.new(node['base']['iptables']['rules_prerouting_base']).result(node['base']['iptables'].to_hash),
    :rules_prerouting => rules_prerouting,
    :rules_networks => node['base']['iptables']['network'],
    :vpn_enabled => node['base']['vpn_enabled'],
    :rules => rules
  })
  notifies :run, "execute[load_iptables]"
end

# Run the iptables load script
# Can make this optional and use netfilter-persistent also
execute "load_iptables" do
  command "/etc/network/if-pre-up.d/iptablesload"
  action :nothing
end
