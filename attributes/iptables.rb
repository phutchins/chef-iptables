default['base']['iptables']['rules_v4_file'] = 'rules.v4'
default['base']['iptables']['rules_v6_file'] = 'rules.v6'
default['base']['iptables']['rules_dir'] = '/etc/iptables'
default['base']['iptables']['network']['pubnet']['iface'] = 'eth0'
#default['base']['iptables']['network']['service']['iface'] = 'eth1'
#default['base']['iptables']['network']['privnet']['iface'] = 'eth2'

default['base']['iptables']['rules_prerouting_policy'] = <<-RULES
RULES

default['base']['iptables']['rules_prerouting_base'] = <<-RULES
<% if @vpn_ip %>
<% end %>
RULES

default['base']['iptables']['rules_filter_policy'] = <<-RULES
RULES

default['base']['iptables']['rules_filter_base'] = <<-RULES
# SSH
-A pubnet -p tcp -m tcp --dport 22 -j ACCEPT

# Monitoring
-A pubnet -p tcp -m tcp --dport 10050 -j ACCEPT
RULES

default['base']['iptables']['rules_filter_vpn_base'] = <<-RULES
RULES
