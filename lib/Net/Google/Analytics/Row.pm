package Net::Google::Analytics::Row;

BEGIN {
    require Class::XSAccessor::Array;
}

my $class_count = 0;

# Dynamically generate a class with accessors
sub gen_class {
    my (undef, $column_headers) = @_;

    # Generate unique package name
    my $class = "Net::Google::Analytics::Row_$class_count";
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
        my $getter = 'ga_' . $column_headers->[$i]->{name};
        $getters{$getter} = $i;
    }
    Class::XSAccessor::Array->import(
        class   => $class,
        getters => \%getters,
    );

    return $class;
}

sub new {
    my ($class, $row) = @_;
    return bless($row, $class);
}

sub column_headers {
    my $self = shift;
    my $class = ref($self);
    no strict 'refs';
    return ${ "${class}::column_headers" };
}

sub get {
    my ($self, $name) = @_;

    my $column_headers = $self->column_headers;

    for (my $i = 0; $i < @$column_headers; ++$i) {
        return $self->[$i] if $column_headers->[$i]->{name} eq $name;
    }

    return undef;
}

1;

