package Net::Google::Analytics::Row;

BEGIN {
    require Class::XSAccessor::Array;
}

my $class_count = 0;

sub new {
    my ($class, $row) = @_;
    return bless($row, $class);
}

# We have to call import from the newly generated class
sub _create_accessors {
    shift; # ignore
    Class::XSAccessor::Array->import(@_);
}

# Dynamically generate a class with accessors
sub gen_class {
    shift; # ignore

    # Generate unique package name
    my $class = "Net::Google::Analytics::Row_$class_count";
    ++$class_count;

    {
        # Set ISA of new class
        no strict 'refs';
        @{ "${class}::ISA" } = qw(Net::Google::Analytics::Row);
    }

    # Create accessors
    my %getters;
    for (my $i = 0; $i < @_; ++$i) {
        my $column_name = 'ga_' . $_[$i];
        $getters{$column_name} = $i;
    }
    $class->_create_accessors(getters => \%getters);

    return $class;
}

1;

