package Net::Google::Analytics::FeedRequest;
use strict;

use base qw(Class::Accessor);

__PACKAGE__->mk_accessors(qw(start_index max_results));

sub _params {
    return ();
}

1;

__END__

=head1 NAME

Net::Google::Analytics::FeedRequest - Google Analytics API feed request

=head1 DESCRIPTION

This is a base class for feed requests of the Google Analytics Data Export
API. Account feed requests are implemented in this class. Data feed requests
are implemented in L<Net::Google::Analytics::DataFeedRequest>.

=head1 ACCESSORS

=head2 start_index

=head2 max_results

=cut

