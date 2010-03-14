package Net::Google::Analytics::Metric;
use strict;

use base qw(Class::Accessor);

__PACKAGE__->mk_accessors(qw(name type value confidence_interval));

sub _parse {
    my ($package, $node) = @_;

    my $self = {
        name  => $node->getAttribute('name'),
        type  => $node->getAttribute('type'),
        value => $node->getAttribute('value'),
        confidence_interval => $node->getAttribute('confidenceInterval'),
    };

    return bless($self, $package);
}

1;

__END__

=head1 NAME

Net::Google::Analytics::Metric - Google Analytics API metric

=head1 DESCRIPTION

This package implements metric data of the Google Analytics Data Export
API.

See
L<http://code.google.com/apis/analytics/docs/gdata/gdataReferenceDimensionsMetrics.html#metrics>
for a reference.

=head1 ACCESSORS

=head2 name

The name of the metric.

=head2 type

The type of the metric's value.

=head2 value

The value of the metric.

=head2 confidence_interval

The confidence interval of the metric's value.

=head1 AUTHOR

Nick Wellnhofer <wellnhofer@aevum.de>

=head1 COPYRIGHT AND LICENSE

Copyright (C) Nick Wellnhofer, 2010

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.0 or,
at your option, any later version of Perl 5 you may have available.

=cut

