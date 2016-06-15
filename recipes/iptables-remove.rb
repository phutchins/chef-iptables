# Should only run this once... Don't want to step on other rules toes
# Maybe just remove /etc/iptables files
bash 'clear_iptables' do
  code <<-EOH
    iptables -P INPUT ACCEPT
    iptables -P FORWARD ACCEPT
    iptables -P OUTPUT ACCEPT
    iptables -t nat -F
    iptables -t mangle -F
    iptables -F
    iptables -X
  EOH
end

file '/etc/network/if-pre-up.d/iptablesload' do
  action :delete
end
