package Net::Google::Analytics::AccountFeedResponse;
use strict;

use base qw(Net::Google::Analytics::FeedResponse);

use Net::Google::Analytics::AccountFeedEntry;

my @property_map = (
    account_id      => 'accountId',
    account_name    => 'accountName',
    profile_id      => 'profileId',
    web_property_id => 'webPropertyId',
    currency        => 'currency',
    timezone        => 'timezone',
);

#__PACKAGE__->mk_accessors(qw());

sub _parse_entry {
    my ($self, $entry_node) = @_;

    my $xpc = $self->_xpc;

    my $entry = Net::Google::Analytics::AccountFeedEntry->new();

    for(my $i=0; $i<@property_map; $i+=2) {
        my $from = $property_map[$i+1];
        my $to   = $property_map[$i];

        $entry->set(
            $to,
            $xpc->findvalue(
                "dxp:property[\@name='ga:$from']/\@value",
                $entry_node
            )
        );
    }

    $entry->table_id($entry_node->findvalue('dxp:tableId'));

    push(@{ $self->entries }, $entry);

    return $entry;
}

1;

__END__

=head1 NAME

Net::Google::Analytics::AccountFeedResponse - Google Analytics API account
feed response

=head1 DESCRIPTION

This package is a subclass of L<Net::Google::Analytics::FeedResponse> and
implements parts of the account feed response of the Google Analytics Data
Export API. The entries in the feed response are of type
L<Net::Google::Analytics::AccountFeedEntry>.

See
L<http://code.google.com/apis/analytics/docs/gdata/gdataReferenceAccountFeed.html#accountResponse>
for a complete reference.

=cut

