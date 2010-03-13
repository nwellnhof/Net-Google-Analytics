package Net::Google::Analytics::FeedResponse;
use strict;

use base qw(Class::Accessor);

use Net::Google::Analytics::Feed;

my $xpc = $Net::Google::Analytics::Feed::xpc;

__PACKAGE__->mk_accessors(qw(total_results entries));

sub new {
    my $package = shift;

    return bless({ entries => [] }, $package);
}

sub parse_feed {
    my ($self, $feed_node) = @_;

    $self->total_results($xpc->findvalue('atom:totalResults', $feed_node));
}

1;

