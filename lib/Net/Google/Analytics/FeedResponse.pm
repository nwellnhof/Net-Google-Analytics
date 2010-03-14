package Net::Google::Analytics::FeedResponse;
use strict;

use base qw(Class::Accessor Net::Google::Analytics::XML);

__PACKAGE__->mk_accessors(qw(total_results entries));

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

1;

__END__

=head1 NAME

Net::Google::Analytics::FeedResponse - Google Analytics API feed response

=head1 DESCRIPTION

This package is a base class for feed responses of the Google Analytics
Data Export API. Account feed responses are implemented in
L<Net::Google::Analytics::AccountFeedResponse>. Data feed responses are
implemented in L<Net::Google::Analytics::DataFeedResponse>.

=head1 ACCESSORS

=head2 total_results

The total number of results for the query, regardless of the number of
results in the response.

=head2 entries

An arrayref of the entries in the feed response.

=head1 AUTHOR

Nick Wellnhofer <wellnhofer@aevum.de>

=head1 COPYRIGHT AND LICENSE

Copyright (C) Nick Wellnhofer, 2010

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.0 or,
at your option, any later version of Perl 5 you may have available.

=cut

