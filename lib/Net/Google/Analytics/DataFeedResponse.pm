package Net::Google::Analytics::DataFeedResponse;
use strict;

use base qw(Net::Google::Analytics::FeedResponse);

use Net::Google::Analytics::DataFeedEntry;

#__PACKAGE__->mk_accessors(qw());

sub _parse_entry {
    my ($self, $entry_node) = @_;

    my $entry = Net::Google::Analytics::DataFeedEntry->_parse($entry_node);
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

