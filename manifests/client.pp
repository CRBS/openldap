
class openldap::client (

  $uri_list        = $openldap::params::uri_list,
  $base            = $openldap::params::base,
  $tls_cacert      = $openldap::params::tls_cacert,
  $tls_reqcert     = $openldap::params::tls_reqcert,
  $tls_cacertdir   = $openldap::params::tls_cacertdir,
  $base_pkg_name   = $openldap::params::base_pkg_name,
  $client_pkg_name = $openldap::params::client_pkg_name,
  $nscd_pkg_name   = $openldap::params::nscd_pkg_name,
  $base_ldap_path  = $openldap::params::base_ldap_path
  $nslcd_ldap_cfg  = $openldap::params::nslcd_ldap_cfg


) inherits openldap::params {

  ## ensure that the proper packages are installed for the client
  ## if thier is a base ldap package, install it. if not, skip.
  if $base_pkg_name {
    package { $base_pkg_name:  ensure => installed }
  }

  ## ensure that all client and required packages are installed.
  ## this should be all the common packages that all osfamily has.
  ## Otherwise wrap the package like seen above (base_pkg_name)
  package { $client_pkg_name:  ensure => installed }
  package { $nscd_pkg_name:    ensure => installed }

  ## build out the ldap.conf file and ensure the path is set
  file { $base_ldap_path:
    ensure => "directory",
    owner  => "root",
    group  => "root",
    mode   => 750,
  }

  ## ensure that the ldap.conf file is templated and configured.
  file { $client_ldap_cfg: 
    path    => "$base_ldap_path/$client_ldap_cfg",
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => File["$base_ldap_path"],
    content => template('openldap/client_ldap_cfg.erb'),
  }  



  case $::osfamily {
    'solaris': {
      # do something RHEL specific
    }
    'debian': {
      # do something Debian specific 
    }
    default: { ## the default is centos/redhat variant


      ## ensure that the Service [nscd] is stopped and disabled.
      ## ldap uses nslcd in place of nscd.
      service { "nscd":
        ensure => "stopped",
        enable => false,
      }

      ## configure nslcd to be running and the config to be
      ## configured for openldap
      file { $nslcd_ldap_cfg:
        path    => "/etc/$nslcd_ldap_cfg",
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('openldap/nslcd_ldap_cfg.erb'),
      }

      ## ensure nslcd is running and enabled by default
      service { "nslcd":
        ensure => "running",
        enable => true,
      }

      
    } ## End of default case - centos/redhat
} ## End of case-statement













} ## End of openldap::client class



