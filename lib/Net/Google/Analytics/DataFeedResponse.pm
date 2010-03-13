package Net::Google::Analytics::DataFeedResponse;
use strict;

use base qw(Net::Google::Analytics::FeedResponse);

use Net::Google::Analytics::Feed;

my $xpc = $Net::Google::Analytics::Feed::xpc;

#__PACKAGE__->mk_accessors(qw());

sub parse_entry {
    my ($self, $entry_node) = @_;

    my @dimensions = map {
        {
            name  => $_->getAttribute('name'),
            value => $_->getAttribute('value'),
        };
    } $xpc->findnodes('dxp:dimension', $entry_node);

    my @metrics = map {
        {
            name  => $_->getAttribute('name'),
            type  => $_->getAttribute('type'),
            value => $_->getAttribute('value'),
            confidence_interval => $_->getAttribute('confidenceInterval'),
        };
    } $xpc->findnodes('dxp:metric', $entry_node);

    my $entry = {
        dimensions => \@dimensions,
        metrics    => \@metrics,
    };

    push(@{ $self->entries }, $entry);

    return $entry;
}

1;

