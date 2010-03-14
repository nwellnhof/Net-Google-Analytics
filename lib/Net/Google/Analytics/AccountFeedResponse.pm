package Net::Google::Analytics::AccountFeedResponse;
use strict;

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

=head1 AUTHOR

Nick Wellnhofer <wellnhofer@aevum.de>

=head1 COPYRIGHT AND LICENSE

Copyright (C) Nick Wellnhofer, 2010

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.0 or,
at your option, any later version of Perl 5 you may have available.

=cut

