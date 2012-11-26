## Cookbook Name:: quantum
## Recipe:: ovs-plugin
##
## Copyright 2012, Rackspace US, Inc.
##
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
##
include_recipe "osops-utils"

if not node["package_component"].nil?
	    release = node["package_component"]
else
	    release = "folsom"
end

plugin = node["quantum"]["plugin"]
node["quantum"][plugin].each do |pkg| 
    package pkg do
        action :upgrade
        options platform_options["package_overrides"]
    end
end

service "quantum-plugin-openvswitch-agent" do
    service_name node["quantum"]["ovs"]["service_name"]
    supports :status => true, :restart => true
    action :nothing
end

mysql_info = get_access_endpoint("mysql-master", "mysql", "db")

template "/etc/quantum/plugins/openvswitch/ovs_quantum_plugin.ini" do
    source "#{release}/ovs_quantum_plugin.ini.erb"
    owner "root"
    group "root"
    mode "0644"
    variables(
	    "db_ip_address" => mysql_info["host"],
	    "db_user" => node["quantum"]["db"]["username"],
	    "db_password" => node["quantum"]["db"]["password"],
	    "db_name" => node["quantum"]["db"]["name"],
	    "ovs_network_type" => node["quantum"]["ovs"]["network_type"],
	    "ovs_enable_tunneling" => node["quantum"]["ovs"]["tunneling"],
	    "ovs_tunnel_ranges" => node["quantum"]["ovs"]["tunnel_ranges"],
	    "ovs_integration_bridge" => node["quantum"]["ovs"]["integration_bridge"],
	    "ovs_tunnel_bridge" => node["quantum"]["ovs"]["tunnel_bridge"],
	    "ovs_local_ip" => get_ip_for_net('nova', node)
    )
end
