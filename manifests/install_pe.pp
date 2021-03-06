class lms::install_pe {
  
  $prod_module_path = '/etc/puppetlabs/puppet/environments/production/modules'

  exec {'install-pe':
    # This is a workaround for PE 3.2.0+ offline installations to work"
    # If you don't reset the rubylib, it'll inherit the one used during kickstart and the installer will blow up.
    environment => ["RUBYLIB=''"],
    command     => "/root/puppet-enterprise/puppet-enterprise-installer -D -a /root/lms.answers",
    creates     => '/usr/local/bin/puppet',
    logoutput   => true,
    timeout     => '14400',
    require     => [Class['bootstrap::get_pe'],Class['localrepo']],
  }

  augeas { "environment timeout":
    context => "/files/etc/puppetlabs/puppet/puppet.conf/agent",
    changes => [
      "set environment_timeout 0",
    ],
    require => Exec['install-pe'],
  }
  augeas { "disable deprecation warnings":
    context => "/files/etc/puppetlabs/puppet/puppet.conf/main",
    changes => [
      "set disable_warnings deprecations",
    ],
    require => Exec['install-pe'],
  }

  # to use pe_gem to install the following gems, we first need pe_gem installed
  # using execs now till there is a more graceful solution
  
  exec { 'install trollop':
    command => '/opt/puppet/bin/gem install trollop -v 2.0',
    unless  => '/opt/puppet/bin/gem list trollop -i',
    require => Exec['install-pe'],
  }
  
  exec { 'install serverspec':
    command => '/opt/puppet/bin/gem install serverspec -v 1.16.0',
    unless  => '/opt/puppet/bin/gem list serverspec -i',
    require => Exec['install rspec-its'],
  }
  exec { 'install rspec-its':
    command => '/opt/puppet/bin/gem install rspec-its -v 1.0.1',
    unless  => '/opt/puppet/bin/gem list rspec-its -i',
    require => Exec['install rspec-core'],
  }
  exec { 'install rspec-core':
    command => '/opt/puppet/bin/gem install rspec-core -v 2.99.0',
    unless  => '/opt/puppet/bin/gem list rspec -i',
    require => Exec['install rspec'],
  }
  exec { 'install rspec':
    command => '/opt/puppet/bin/gem install rspec -v 2.99.0',
    unless  => '/opt/puppet/bin/gem list rspec -i',
    require => Exec['install-pe'],
  }

}
