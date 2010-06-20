package Net::Google::Analytics::DataFeedEntry;
use strict;

# ABSTRACT: Google Analytics API data feed entry

use base qw(Class::Accessor Net::Google::Analytics::XML);

use Net::Google::Analytics::Dimension;
use Net::Google::Analytics::Metric;

__PACKAGE__->mk_accessors(qw(dimensions metrics));

sub _parse {
    my ($package, $node) = @_;

    my $xpc = $package->_xpc;

    my @dimensions = map {
        Net::Google::Analytics::Dimension->_parse($_);
    } $xpc->findnodes('dxp:dimension', $node);

    my @metrics = map {
        Net::Google::Analytics::Metric->_parse($_);
    } $xpc->findnodes('dxp:metric', $node);

    my $self = {
        dimensions => \@dimensions,
        metrics    => \@metrics,
    };
        
    return bless($self, $package);
}

1;

__END__

=head1 DESCRIPTION

This package implements data feed entries of the Google Analytics Data Export
API.

=head1 ATTRIBUTES

=head2 dimensions

An arrayref of L<Net::Google::Analytics::Dimension> objects.

=head2 metrics

An arrayref of L<Net::Google::Analytics::Metric> objects.

=cut

