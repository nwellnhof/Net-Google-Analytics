package Net::Google::Analytics::DataFeedEntry;
use strict;

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

=head1 AUTHOR

Nick Wellnhofer <wellnhofer@aevum.de>

=head1 COPYRIGHT AND LICENSE

Copyright (C) Nick Wellnhofer, 2010

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.0 or,
at your option, any later version of Perl 5 you may have available.

=cut

