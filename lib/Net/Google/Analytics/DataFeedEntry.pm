package Net::Google::Analytics::DataFeedEntry;
use strict;

use base qw(Class::Accessor);

__PACKAGE__->mk_accessors(qw(dimensions metrics));

sub new {
    my $package = shift;

    return bless({}, $package);
}

1;

__END__

=head1 NAME

Net::Google::Analytics::DataFeedEntry - Google Analytics API data feed entry

=head1 DESCRIPTION

This package implements data feed entries of the Google Analytics Data Export
API.

=head1 ACCESSORS

=head2 dimensions

An arrayref of L<Net::Google::Analytics::Dimension> objects.

=head2 metrics

An arrayref of L<Net::Google::Analytics::Metric> objects.

=cut

