package Net::Google::Analytics::DataFeed;
use strict;

use base qw(Net::Google::Analytics::Feed);

use Net::Google::Analytics::DataFeedRequest;
use Net::Google::Analytics::DataFeedResponse;

sub _base_url {
    return 'https://www.google.com/analytics/feeds/data';
}

sub _max_items_per_page {
    return 10_000;
}

sub new_request {
    return Net::Google::Analytics::DataFeedRequest->new();
}

sub _new_response {
    return Net::Google::Analytics::DataFeedResponse->new();
}

1;

__END__

=head1 NAME

Net::Google::Analytics::DataFeed - Google Analytics API data feed

=head1 DESCRIPTION

This package is a subclass of L<Net::Google::Analytics::Feed> and
implements data feeds of the Google Analytics Data Export API.

=head1 METHODS

=head2 new_request

 my $req = $data_feed->new_request();

Creates and returns a L<Net::Google::Analytics::DataFeedRequest> object.

=head2 retrieve

 my $res = $data_feed->retrieve($req);

Retrieves the data feed. Returns a
L<Net::Google::Analytics::DataFeedResponse> object.

=head1 AUTHOR

Nick Wellnhofer <wellnhofer@aevum.de>

=head1 COPYRIGHT AND LICENSE

Copyright (C) Nick Wellnhofer, 2010

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.0 or,
at your option, any later version of Perl 5 you may have available.

=cut

