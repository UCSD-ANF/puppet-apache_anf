/*

== Definition: apache_anf::directive

Convenient wrapper around apache_anf::conf resources to add random configuration
snippets to an apache virtualhost.

Parameters:
- *ensure*: present/absent.
- *directive*: apache directive(s) to be applied in the corresponding
  <VirtualHost> section.
- *vhost*: the virtualhost to which this directive will apply. Mandatory.
- *filename*: basename of the file in which the directive(s) will be put.
  Useful in the case directive order matters: apache reads the files in conf/
  in alphabetical order.

Requires:
- Class["apache"]
- matching Apache::Vhost[] instance

Example usage:

  apache_anf::directive { "example 1":
    ensure    => present,
    directive => "
      RewriteEngine on
      RewriteRule ^/?$ https://www.example.com/
    ",
    vhost     => "www.example.com",
  }

  apache_anf::directive { "example 2":
    ensure    => present,
    directive => content("example/snippet.erb"),
    vhost     => "www.example.com",
  }

*/
define apache_anf::directive ($ensure="present", $directive="", $filename="", $vhost) {

  include apache_anf::params

  if ($ensure == 'present' and $directive == '') {
    fail 'empty "directive" parameter'
  }

  apache_anf::conf {$name:
    ensure        => $ensure,
    path          => "${apache_anf::params::vroot}/${vhost}/conf",
    prefix        => 'directive',
    filename      => $filename,
    configuration => $directive,
    require       => Apache::Vhost[$vhost],
  }
}
