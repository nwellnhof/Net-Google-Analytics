package Net::Google::Analytics::Response;
use strict;

# ABSTRACT: Google Analytics API response

use Class::XSAccessor
    accessors => [ qw(
        is_success code message
        total_results start_index items_per_page
        _column_headers rows _totals
    ) ],
    constructor => 'new';

sub status_line {
    my $self = shift;

    return join(' ', $self->code, $self->message);
}

sub _parse_json {
    my ($self, $json) = @_;

    $self->items_per_page($json->{itemsPerPage});
    $self->total_results($json->{totalResults});
    $self->_totals($json->{totalsForAllResults});

    my @column_headers;

    for my $column_header (@{ $json->{columnHeaders} }) {
        die("invalid column name: $column_header->{name}")
            unless $column_header->{name} =~ /^ga:(\w{1,64})\z/;
        my $column_name = $1;

        push(@column_headers, {
            name        => $column_name,
            column_type => $column_header->{columnType},
            data_type   => $column_header->{dataType},
        });
    }

    $self->_column_headers(\@column_headers);

    my $class = Net::Google::Analytics::Row->gen_class(\@column_headers);

    my @rows = map { $class->new($_) } @{ $json->{rows} };
    $self->rows(\@rows);
}

sub metrics {
    my $self = shift;

    return $self->_columns('METRIC');
}

sub dimensions {
    my $self = shift;

    return $self->_columns('DIMENSION');
}

sub totals {
    my ($self, $metric) = @_;

    return $self->_totals->{"ga:$metric"};
}

sub _columns {
    my ($self, $type) = @_;

    my $column_headers = $self->_column_headers;
    my @results;

    for my $column_header (@$column_headers) {
        if ($column_header->{column_type} eq $type) {
            push(@results, $column_header->{name});
        }
    }

    return @results;
}

sub project {
    my ($self, $proj_dim_names, $projection) = @_;

    my (@metric_indices, @proj_column_headers);
    my $column_headers = $self->_column_headers;

    for (my $i = 0; $i < @$column_headers; ++$i) {
        my $column_header = $column_headers->[$i];

        if ($column_header->{column_type} eq 'METRIC') {
            push(@metric_indices, $i);
            push(@proj_column_headers, { %$column_header });
        }
    }

    for my $name (@$proj_dim_names) {
        push(@proj_column_headers, {
            name        => $name,
            column_type => 'DIMENSION',
        });
    }

    my $class = Net::Google::Analytics::Row->gen_class(\@proj_column_headers);

    # Projected rows are collected in hash %proj_rows. The keys of the hash
    # are the the projected dimension values joined with zero bytes.

    my %proj_rows;

    for my $row (@{ $self->rows }) {
        my @proj_dim_values = $projection->($row);
        my $key = join("\0", @proj_dim_values);

        my $proj_row = $proj_rows{$key};

        if (!$proj_row) {
            my @proj_metric_values = map { $row->[$_] } @metric_indices;
            $proj_rows{$key} = $class->new(
                [ @proj_metric_values, @proj_dim_values ],
            );
        }
        else {
            for (my $i = 0; $i < @metric_indices; ++$i) {
                my $mi = $metric_indices[$i];
                $proj_row->[$i] += $row->[$mi];
            }
        }
    }

    $self->rows([ values(%proj_rows) ]);
}

1;

__END__

=head1 DESCRIPTION

Response class for L<Net::Google::Analytics> web service.

=head1 ACCESSORS

=head2 is_success

True for successful requests, false in case of an error

=head2 code

The HTTP status code

=head2 message

The HTTP status message

=head2 status_line

The string "<code> <message>".

=head2 total_results

The total number of results for the query, regardless of the number of
results in the response.

=head2 start_index

The 1-based start index of the entries.

=head2 items_per_page

The number of rows.

=head2 rows

An arrayref of result rows.

=head2 dimensions

An array of all dimension names (without 'ga:')

=head2 metrics

An array of all metric names (without 'ga:')

=head1 METHODS

=head2 totals

    my $total = $res->totals($metric);

Returns the total of all results for $metric.

=head2 project

    $res->project(\@proj_dim_names, \&projection);

Projects the dimension values of every entry to a set of new dimension values
using subroutine reference \&projection. The metrics of entries that are
mapped to the same dimension values are summed up.

Argument \@proj_dim_names is an arrayref containing the names of the
new dimensions.

The projection subroutine takes as single argument a
L<Net::Google::Analytics::Row> object and must return an array of dimension
values.

The following example maps a single dimension of type ga:pagePath to
categories.

    $res->project([ 'category' ], sub {
        my $row = shift;

        my $page_path = $row->get_pagePath;

        return ('flowers') if $page_path =~ m{^/(tulips|roses)};
        return ('fruit')   if $page_path =~ m{^/(apples|oranges)};

        return ('other');
    });

=cut

