bash 'clear_iptables' do
  code <<-EOH
    iptables -F
  EOH
end

file '/etc/network/if-pre-up.d/iptablesload' do
  action :delete
end
