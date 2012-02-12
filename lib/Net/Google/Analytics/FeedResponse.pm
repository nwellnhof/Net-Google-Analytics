package Net::Google::Analytics::FeedResponse;
use strict;

# ABSTRACT: Google Analytics API feed response

use base qw(Class::Accessor Net::Google::Analytics::XML);

__PACKAGE__->mk_accessors(qw(
    is_success code message
    total_results start_index items_per_page entries
));

sub new {
    my $package = shift;

    return bless({ entries => [] }, $package);
}

sub _parse_feed {
    my ($self, $feed_node) = @_;

    $self->total_results(
        $self->_xpc->findvalue('openSearch:totalResults', $feed_node)
    );
}

sub status_line {
    my $self = shift;

    return join(' ', $self->code, $self->message);
}

1;

__END__

=head1 DESCRIPTION

This package is a base class for feed responses of the Google Analytics
Data Export API. Account feed responses are implemented in
L<Net::Google::Analytics::AccountFeedResponse>. Data feed responses are
implemented in L<Net::Google::Analytics::DataFeedResponse>.

=head1 ACCESSORS

=head2 is_success

Return false in case of an error

=head2 code

The HTTP status code

=head2 message

The HTTP status message

=head2 total_results

The total number of results for the query, regardless of the number of
results in the response.

=head2 start_index

The 1-based start index of the entries.

=head2 items_per_page

The number of entries.

=head2 entries

An arrayref of the entries.

=head1 METHODS

=head2 status_line

 my $status_line = $res->status_line();

Returns the string "<code> <message>".

=cut

