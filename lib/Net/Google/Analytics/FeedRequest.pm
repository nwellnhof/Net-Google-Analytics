package Net::Google::Analytics::FeedRequest;
use strict;

use base qw(Class::Accessor);

__PACKAGE__->mk_accessors(qw(start_index max_results prettyprint));

sub new {
    my $package = shift;

    return bless({}, $package);
}

sub _params {
    return {};
}

1;

__END__

=head1 NAME

Net::Google::Analytics::FeedRequest - Google Analytics API feed request

=head1 DESCRIPTION

This is a base class for feed requests of the Google Analytics Data Export
API.

Currently, only data feed requests are implemented in
L<Net::Google::Analytics::DataFeedRequest>.

=cut

