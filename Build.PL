use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'DateTime::TimeAgo',
    license             => 'perl',
    dist_author         => q{Jan Oldrich Kruza <sixtease@cpan.org>},
    dist_version_from   => 'lib/DateTime/TimeAgo.pm',
    requires => {
        'DateTime' => 0,
        'DateTime::Duration' => 0,
    },
    build_requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'DateTime-TimeAgo-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
