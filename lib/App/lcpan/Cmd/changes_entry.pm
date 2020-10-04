package App::lcpan::Cmd::changes_entry;

# AUTHORITY
# DATE
# DIST
# VERSION

use 5.010001;
use strict;
use warnings;

require App::lcpan;
require App::lcpan::Cmd::changes;

our %SPEC;

$SPEC{handle_cmd} = {
    v => 1.1,
    summary => "Show a single entry from a distribution/module's Changes file",
    args => {
        %App::lcpan::common_args,
        %App::lcpan::mod_or_dist_or_script_args,
        version => {
            summary => 'Specify which version',
            schema => 'str*',
            pos => 1,
            description => <<'_',

If unspecified, will show the latest entry.

_
        },
    },
};
sub handle_cmd {
    my %args = @_;

    my $version = delete $args{version};
    my $res = App::lcpan::Cmd::changes::handle_cmd(%args);
    return $res unless $res->[0] == 200;

    require CPAN::Changes;
    my $changes = CPAN::Changes->load_string($res->[2]);

    my %releases;
    for my $release (reverse $changes->releases) {
        $version //= $release->version;
        $releases{ $release->version } = $release;
    }

    if ($releases{$version}) {
        [200, "OK", $releases{$version}->serialize];
    } else {
        [404, "No entry for version $version in the Changes for $args{module_or_dist_or_script}"];
    }
}

1;
# ABSTRACT:
