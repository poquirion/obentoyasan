class base {
  include epel
  package { 'python3': }
  package { 'vim': }

  $instances = lookup('terraform.instances')
  $host_template = @(END)
127.0.0.1 localhost localhost.localdomain localhost4 localhost4.localdomain4
<% @instances.each do |key, values| -%>
<%= values['local_ip'] %> <%= key %> <% if values['tags'].include?('puppet') %>puppet<% end %>
<% end -%>
END

  file { '/etc/hosts':
    ensure  => file,
    content => inline_template($host_template)
  }


}


class proxy {
  include nginx

}



node default {
  include base

  if 'puppet' in $instance_tags {
    include profile::consul::server
  } else {
    include profile::consul::client
  }

  if 'bento' in $instance_tags {
    include profile::singularity
  }

  if 'proxy' in $instance_tags {
    include proxy
  }


}
