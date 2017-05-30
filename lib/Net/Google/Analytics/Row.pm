package Net::Google::Analytics::Row;

use strict;
use warnings;

# ABSTRACT: Base class for Google Analytics API result rows

BEGIN {
    require Class::XSAccessor::Array;
}

my $class_count = 0;
my %class_cache;

# Dynamically generate a class with accessors
sub _gen_class {
    my (undef, $column_headers) = @_;

    # Cache lookup
    my $cache_key = join("\t", map { $_->{name} } @$column_headers);
    my $class = $class_cache{$cache_key};
    return $class if $class;

    # Generate unique package name
    $class = "Net::Google::Analytics::Row_$class_count";
    ++$class_count;

    {
        # Set globals of new class
        no strict 'refs';
        @{ "${class}::ISA" }            = qw(Net::Google::Analytics::Row);
        ${ "${class}::column_headers" } = $column_headers;
    }

    # Create accessors
    my %getters;
    for (my $i = 0; $i < @$column_headers; ++$i) {
        my $getter = 'get_' . $column_headers->[$i]->{name};
        $getters{$getter} = $i;
    }
    Class::XSAccessor::Array->import(
        class   => $class,
        getters => \%getters,
    );

    # Store in cache
    $class_cache{$cache_key} = $class;

    return $class;
}

sub new {
    my ($class, $row) = @_;
    return bless($row, $class);
}

sub _column_headers {
    my $self = shift;
    my $class = ref($self);
    no strict 'refs';
    return ${ "${class}::column_headers" };
}

sub get {
    my ($self, $name) = @_;

    my $column_headers = $self->_column_headers;

    for (my $i = 0; $i < @$column_headers; ++$i) {
        return $self->[$i] if $column_headers->[$i]->{name} eq $name;
    }

    return undef;
}

1;

__END__

=head1 DESCRIPTION

Result row class for L<Net::Google::Analytics> web service.

=head1 CONSTRUCTOR

=head2 new

=head1 GENERATED ACCESSORS

    my $year = $row->get_year;
    my $page_path = $row->get_page_path;

For every dimension and metric, an accessor of the form "get_..." is created.
The 'ga:' prefix is stripped from the dimension and metric names and camel
case is converted to lower case with underscores.

=head1 METHODS

=head2 get

    my $value = $row->get($dimension_name);
    my $value = $row->get($metric_name);

Returns the value of the dimension or metric with the given name. Use names
without the 'ga:' prefix and converted to lower case with underscores.

=cut

