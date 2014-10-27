/*
 * Author: Edmond Negado
 * File: params.pp
 * Description: This class pp file is for openldap::params. This class
 *  holds all the variable declarations needed for the openldap client
 *  and openldap multi-master server(s).
 *
 * 
 *
 *
 *
 *
 */

class openldap::params
{

  # place default vars here. used for openldap::client and openldap::server
  $uri                       = []        # required
  $base                      = undef     # required

  # nslcd configuration and packages used for the openldap::client
  $nslcd_rootpwmoddn         = undef

  # Based on the operating system, set the correct params of where
  # and how to configure openldap
  case $::osfamily {

    'Debian': { # CLIENT setup ONLY. Server setup will be done with CentOS

      # TODO Need to finish the client configuration on Ubuntu 14.04
      $base_pkg_name            = undef
      $client_pkg_name          = 'ldap-auth-client'
      $server_pkg_name          = undef
      $base_ldap_path           = undef
      $nscd_pkg_name            = 'nscd'
      $client_ldap_cfg          = 'ldap.conf'

    } # End Debian/Ubuntu case

    'Solaris': {
      # Solaris openldap init stub TBA
      # TODO Need to finish the client configuration on Solaris
      # CLIENT setup ONLY. Server setup will be done with CentOS
    }

    'RedHat': {

      # initializing the openldap server/client section.
      $base_pkg_name            = 'openldap'
      $client_pkg_name          = 'openldap-clients'
      $server_pkg_name          = 'openldap-servers'
      $client_ldap_cfg          = 'ldap.conf'
      $base_ldap_path           = '/etc/openldap'
      $tls_cacert               = '/etc/pki/tls/certs/ca-bundle.crt'
      $tls_cacertdir            = '/etc/openldap/cacerts'
      $tls_reqcert              = 'demand'

      # initializing nslcd/nscd section used for the client
      $nscd_pkg_name            = 'nscd'
      $nslcd_ldap_cfg           = 'nslcd.conf'
      $nslcd_bind_timelimit     = 30
      $nslcd_timelimit          = 30
      $nslcd_idle_timelimit     = 3600
      $nslcd_ssl                = 'no'
      $nslcd_uid                = 'nslcd'
      $nslcd_gid                = 'ldap'
      $nslcd_tls_cacertdir      = '/etc/openldap/cacerts'
      $nslcd_tls_reqcert        = 'allow'

    } # End Redhat case

    default: {

      fail("The openldap module is not supported on an ${::osfamily} based system.")

    } # End of default case.

  } # End case statement for osfamily.

} # End of openldap::params class

