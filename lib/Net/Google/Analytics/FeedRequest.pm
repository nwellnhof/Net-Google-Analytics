package Net::Google::Analytics::FeedRequest;
use strict;

use base qw(Class::Accessor);

__PACKAGE__->mk_accessors(qw(start_index max_results prettyprint));

sub new {
    my $package = shift;

    return bless({}, $package);
}

sub params {
    return {};
}

1;

