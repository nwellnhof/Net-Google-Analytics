package Net::Google::Analytics::AccountFeedResponse;
use strict;

# ABSTRACT: Google Analytics API account feed response

use base qw(Net::Google::Analytics::FeedResponse);

use Net::Google::Analytics::AccountFeedEntry;

sub _parse_entry {
    my ($self, $entry_node) = @_;

    my $entry = Net::Google::Analytics::AccountFeedEntry->_parse($entry_node);
    push(@{ $self->entries }, $entry);

    return $entry;
}

1;

__END__

=head1 DESCRIPTION

This package is a subclass of L<Net::Google::Analytics::FeedResponse> and
implements parts of the account feed response of the Google Analytics Data
Export API. The entries in the feed response are of type
L<Net::Google::Analytics::AccountFeedEntry>.

See
L<http://code.google.com/apis/analytics/docs/gdata/gdataReferenceAccountFeed.html#accountResponse>
for a complete reference.

=cut

