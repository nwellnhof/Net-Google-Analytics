package Net::Google::Analytics::Row;

use strict;
use warnings;

# ABSTRACT: Base class for Google Analytics API result rows

BEGIN {
    require Class::XSAccessor::Array;
}

my $class_count = 0;
my %class_cache;

sub gen_class {
    my (undef, %params) = @_;
    my @class_fields = (@{$params{dimensions}}, @{$params{metrics}});

    # Cache lookup
    my $cache_key = join('.', @class_fields);
    return $class_cache{$cache_key} if $class_cache{$cache_key};

    # Generate unique package name
    my $class = 'Net::Google::Analytics::Row_' . $class_count++;

    { no strict 'refs';
      @{ "${class}::ISA" } = 'Net::Google::Analytics::Row';
    }

    # Create getters
    my %getters;
    foreach my $i (0 .. $#class_fields) {
        $getters{ 'get_' . $class_fields[$i] } = $i;
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
    my ($class, $row_data) = @_;
    return bless [
      map $_->{value}, @{$row_data->{dimensionValues}}, @{$row_data->{metricValues}}
    ], $class;
}

sub get {
    my ($self, $name) = @_;
    my $getter = 'get_' . $name;
    return $self->$getter if $self->can($getter);
    return undef;
}

1;

__END__

=head1 DESCRIPTION

Result row class for L<Net::Google::Analytics> web service.

=head1 CONSTRUCTOR

Row class constructors are used internally by L<Net::Google::Analytics>
to dynamically create row objects with custom methods for the requested
dimensions and metrics.

=head2 gen_class

Receives a hash with dimension and metric names as array references. Generates
a row class containing the appropriate accessors (getters), and returns that
class name (so you can call C<< $classname->new >>).

=head2 new

Receives a row data structure as returned by L<Net::Google::Analytics>' API,
and populates the accessors (getters) accordingly, returning a new object.
This construction should only be called by classes generated via L</gen_class>.

=head1 GENERATED ACCESSORS

    my $year = $row->get_year;
    my $page_path = $row->get_page_path;

For every dimension and metric, an accessor of the form "get_..." is created.
Camel case is converted to lower case with underscores
(e.g. you access 'screenPageViews' via the 'get_screen_page_views' method).

=head1 METHODS

=head2 get

    my $value = $row->get($dimension_name);
    my $value = $row->get($metric_name);

Returns the value of the dimension or metric with the given name. Make sure to
use names converted to lower case with underscores
(e.g. 'page_path', not 'pagePath').
