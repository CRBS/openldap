
class openldap::params
{

  ## place default vars here.
  $uri                = []        ## required
  $base               = ''     ## required



  ## nslcd configuration and packages
 # $nslcd_rootpwmoddn       = undef


  ## Based on the operating system, set the correct params of where
  ## and how to configure openldap
  case $::osfamily {

    'Debian': {

      $base_pkg_name       = undef
      $client_pkg_name     = 'ldap-auth-client'
      $server_pkg_name     = undef
      $base_ldap_path      = undef
      $nscd_pkg_name       = 'nscd'

    } ## End Debian/Ubuntu case

    'RedHat': {

      $base_pkg_name       = 'openldap'
      $client_pkg_name     = 'openldap-clients'
      $server_pkg_name     = 'openldap-servers'
      $client_ldap_cfg         = 'ldap.conf'
      $base_ldap_path      = '/etc/openldap'
      $tls_cacert          = '/etc/pki/tls/certs/ca-bundle.crt'
      $tls_cacertdir       = '/etc/openldap/cacerts'
      $tls_reqcert         = 'demand'
      $nscd_pkg_name       = 'nscd'
      $nslcd_ldap_cfg      = 'nslcd.conf'
      $nslcd_bind_timelimit    = 30
      $nslcd_timelimit         = 30
      $nslcd_idle_timelimit    = 3600
      $nslcd_ssl           = 'no'
      $nslcd_uid           = 'nslcd'
      $nslcd_gid           = 'ldap'
      $nslcd_tls_cacertdir = '/etc/openldap/cacerts'
      $nslcd_tls_reqcert   = 'allow'





    } ## End Redhat case

  } ## End case statement for osfamily.






} ## End of openldap::params class

