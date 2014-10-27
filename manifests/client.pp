/*
 * Author: Edmond Negado
 * File: client.pp
 * Description: This class module preps the openldap client on either
 *  a Redhat/CentOS based system or a ubuntu system.
 *
 * Hiera Example - use the parameters which are set in the params list
 *  of openldap. any params not set in hiera, will use the default params
 *  set in openldap::params.
 *
 * classes:
 *   - openldap::client
 *
 * openldap::client::uri: 'ldaps://dapper.crbs.ucsd.edu'
 * openldap::client::base: 'dc=ldap,dc=crbs,dc=ucsd,dc=edu'
 *
 *  Optional Variables that can be set via hiera (as seen by the example above.)
 *
 *  $uri                  = (REQUIRED) Array of ldaps/uris to be used for server lookups
 *  $base                 = (REQUIRED) base ldap directory ex: dc=ldap,dc=crbs,dc=ucsd,dc=edu
 *  $tls_cacert           = tls_cacert file location ex: /etc/openldap/certs/cert.crt
 *  $tls_reqcert          = options are: never | allow | try | demand 
 *  $tls_cacertdir        = tls_cacertdir to set the tls directory /etc/openldap/certs
 *  $base_pkg_name        = name of the base openldap package ie: 'openldap'
 *  $client_pkg_name      = name of the client ldap package, ie 'openldap-clients'
 *  $base_ldap_path       = base path to the openldap dir. /etc/openldap
 *
 *  $nslcd_rootpwmoddn    = (REQUIRED) ldap root Manager dn. ie cn=Manager,dc=ldap,dc=crbs,dc=ucsd,dc=edu
 *  $nslcd_ldap_cfg       = name of the nslcd config file: ie 'nslcd.conf'
 *  $nscd_pkg_name        = name of nscd package (if any)
 *  $nslcd_bind_timelimit = number in seconds (30)
 *  $nslcd_timelimit      = number in seconds (30)
 *  $nslcd_idle_timelimit = number in seconds (3600)
 *  $nslcd_tls_reqcert    = options are: never | allow | try | demand 
 *  $nslcd_uid            = nslcd user for nslcd service
 *  $nslcd_gid            = group user for nslcd service
 *  $nslcd_ssl            = enable ssl:  yes | no
 *  $nslcd_tls_cacertdir  = directory path to tls_cacertdir ie: /etc/openldap/certs
 *
 */

class openldap::client (

  $uri                  = $openldap::params::uri,
  $base                 = $openldap::params::base,
  $tls_cacert           = $openldap::params::tls_cacert,
  $tls_reqcert          = $openldap::params::tls_reqcert,
  $tls_cacertdir        = $openldap::params::tls_cacertdir,
  $base_pkg_name        = $openldap::params::base_pkg_name,
  $client_pkg_name      = $openldap::params::client_pkg_name,
  $base_ldap_path       = $openldap::params::base_ldap_path,

  $nscd_pkg_name        = $openldap::params::nscd_pkg_name,
  $nslcd_ldap_cfg       = $openldap::params::nslcd_ldap_cfg,
  $nslcd_rootpwmoddn    = $openldap::params::nslcd_rootpwmoddn,
  $nslcd_bind_timelimit = $openldap::params::nslcd_bind_timelimit,
  $nslcd_timelimit      = $openldap::params::nslcd_timelimit,
  $nslcd_idle_timelimit = $openldap::params::nslcd_idle_timelimit,
  $nslcd_tls_reqcert    = $openldap::params::nslcd_tls_reqcert,
  $nslcd_uid            = $openldap::params::nslcd_uid,
  $nslcd_gid            = $openldap::params::nslcd_gid,
  $nslcd_ssl            = $openldap::params::nslcd_ssl,
  $nslcd_tls_cacertdir  = $openldap::params::nslcd_tls_cacertdir

) inherits openldap::params {

  ## Lets validate the data that is passed in.
  ## TODO Validation of data coming in.

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

  ## Based on the operating system, do the following configuration
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
        subscribe => File["$nslcd_ldap_cfg"],
      }

    } ## End of default case - centos/redhat

  } ## End of case-statement

} ## End of openldap::client class



