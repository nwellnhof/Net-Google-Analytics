package Net::Google::Analytics::Metric;
use strict;

use base qw(Class::Accessor);

__PACKAGE__->mk_accessors(qw(name type value confidence_interval));

sub new {
    my $package = shift;

    return bless({}, $package);
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

=cut

