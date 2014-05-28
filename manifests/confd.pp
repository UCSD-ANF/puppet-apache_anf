/*

== Definition: apache_anf::confd

Convenient wrapper around apache_anf::conf definition to put configuration snippets in
${apache_anf::params::conf}/conf.d directory

Parameters:
- *ensure*: present/absent.
- *configuration*: apache configuration(s) to be applied
- *filename*: basename of the file in which the configuration(s) will be put.
  Useful in the case configuration order matters: apache reads the files in conf.d/
  in alphabetical order.

Requires:
- Class["apache"]

Example usage:

  apache_anf::confd { "example 1":
    ensure        => present,
    path          => /var/www/foo/conf
    configuration => "WSGIPythonEggs /var/cache/python-eggs",
  }

*/
define apache_anf::confd($ensure=present, $configuration, $filename="") {
  include apache_anf::params
  apache_anf::conf {$name:
    ensure        => $ensure,
    path          => "${apache_anf::params::conf}/conf.d",
    filename      => $filename,
    configuration => $configuration,
    notify        => Service["apache"],
  }
}
