package Net::Google::Analytics::DataFeedResponse;
use strict;

use base qw(Net::Google::Analytics::FeedResponse);

use Net::Google::Analytics::DataFeedEntry;
use Net::Google::Analytics::Dimension;
use Net::Google::Analytics::Metric;

#__PACKAGE__->mk_accessors(qw());

sub _parse_entry {
    my ($self, $entry_node) = @_;

    my $xpc = $self->_xpc;

    my @dimensions = map {
        my $dimension = Net::Google::Analytics::Dimension->new();
        $dimension->name ($_->getAttribute('name'));
        $dimension->value($_->getAttribute('value'));
        $dimension;
    } $xpc->findnodes('dxp:dimension', $entry_node);

    my @metrics = map {
        my $metric = Net::Google::Analytics::Metric->new();
        $metric->name ($_->getAttribute('name'));
        $metric->type ($_->getAttribute('type'));
        $metric->value($_->getAttribute('value'));
        $metric->confidence_interval($_->getAttribute('confidenceInterval'));
        $metric;
    } $xpc->findnodes('dxp:metric', $entry_node);

    my $entry = Net::Google::Analytics::DataFeedEntry->new();
    $entry->dimensions(\@dimensions);
    $entry->metrics   (\@metrics);

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

