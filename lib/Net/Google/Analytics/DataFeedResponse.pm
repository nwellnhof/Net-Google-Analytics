package Net::Google::Analytics::DataFeedResponse;
use strict;

use base qw(Net::Google::Analytics::FeedResponse);

#__PACKAGE__->mk_accessors(qw());

sub _parse_entry {
    my ($self, $entry_node) = @_;

    my @dimensions = map {
        {
            name  => $_->getAttribute('name'),
            value => $_->getAttribute('value'),
        };
    } $self->_xpc->findnodes('dxp:dimension', $entry_node);

    my @metrics = map {
        {
            name  => $_->getAttribute('name'),
            type  => $_->getAttribute('type'),
            value => $_->getAttribute('value'),
            confidence_interval => $_->getAttribute('confidenceInterval'),
        };
    } $self->_xpc->findnodes('dxp:metric', $entry_node);

    my $entry = {
        dimensions => \@dimensions,
        metrics    => \@metrics,
    };

    push(@{ $self->entries }, $entry);

    return $entry;
}

1;

__END__

=head1 NAME

Net::Google::Analytics::DataFeedResponse - Google Analytics API data feed
response

=head1 DESCRIPTION

This package is a subclass of L<Net::Google::Analytics::FeedResponse> and
implements parts of the data feed response of the Google Analytics Data
Export API. The entries in the feed response are of type
L<Net::Google::Analytics::DataFeedEntry>.

See
L<http://code.google.com/apis/analytics/docs/gdata/gdataReferenceDataFeed.html#dataResponse>
for a complete reference.

=cut

