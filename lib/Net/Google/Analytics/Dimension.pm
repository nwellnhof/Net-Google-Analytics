package Net::Google::Analytics::Dimension;
use strict;

use base qw(Class::Accessor);

__PACKAGE__->mk_accessors(qw(name value));

sub new {
    my $package = shift;

    return bless({}, $package);
}

1;

__END__

=head1 NAME

Net::Google::Analytics::Dimension - Google Analytics API dimension

=head1 DESCRIPTION

This package implements dimension data of the Google Analytics Data Export
API.

See
L<http://code.google.com/apis/analytics/docs/gdata/gdataReferenceDimensionsMetrics.html#dimensions>
for a reference.

=head1 ACCESSORS

=head2 name

The name of the dimension.

=head2 value

The value of the dimension.

=cut

