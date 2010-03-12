package Net::Google::Analytics::DataFeed;
use strict;

use base qw(Net::Google::Analytics::Feed);

use Net::Google::Analytics::DataFeedRequest;

sub base_url {
    return 'https://www.google.com/analytics/feeds/data';
}

sub max_items_per_page {
    return 10_000;
}

sub new_request {
    return Net::Google::Analytics::DataFeedRequest->new();
}

1;

