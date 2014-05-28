class apache_anf::webdav::ssl inherits apache_anf::ssl {
  case $operatingsystem {
    Debian,Ubuntu:  { include apache_anf::webdav::ssl::debian}
    default: { fail "Unsupported operatingsystem ${operatingsystem}" }
  }
}
