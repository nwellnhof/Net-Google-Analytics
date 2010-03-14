package Net::Google::Analytics::Dimension;
use strict;

use base qw(Class::Accessor);

__PACKAGE__->mk_accessors(qw(name value));

sub _parse {
    my ($package, $node) = @_;

    my $self = {
        name  => $node->getAttribute('name'),
        value => $node->getAttribute('value'),
    };

    return bless($self, $package);
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

=head1 AUTHOR

Nick Wellnhofer <wellnhofer@aevum.de>

=head1 COPYRIGHT AND LICENSE

Copyright (C) Nick Wellnhofer, 2010

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.0 or,
at your option, any later version of Perl 5 you may have available.

=cut

