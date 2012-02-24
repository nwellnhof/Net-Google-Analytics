package Net::Google::Analytics::Response;
use strict;

# ABSTRACT: Google Analytics API response

use Class::XSAccessor
    accessors => [ qw(
        is_success code message
        total_results start_index items_per_page
        column_headers rows totals
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
    $self->totals($json->{totalsForAllResults});

    my (@column_headers, @columns_names);

    for my $column_header (@{ $json->{columnHeaders} }) {
        die("invalid column name: $column_header->{name}")
            unless $column_header->{name} =~ /^ga:(\w{1,64})\z/;
        my $column_name = $1;
        push(@columns_names, $column_name);

        push(@column_headers, {
            name        => $column_name,
            column_type => $column_header->{columnType},
            data_type   => $column_header->{dataType},
        });
    }

    $self->column_headers(\@column_headers);

    my $class = Net::Google::Analytics::Row->gen_class(@columns_names);

    my @rows = map { $class->new($_) } @{ $json->{rows} };
    $self->rows(\@rows);
}

sub project {
    my ($self, $projection, $proj_dim_names) = @_;

    my (@metric_indices, @column_names);
    my $column_headers = $self->column_headers;

    for (my $i = 0; $i < @$column_headers; ++$i) {
        my $column_header = $column_headers->[$i];

        if ($column_header->{column_type} eq 'METRIC') {
            push(@metric_indices, $i);
            push(@column_names, $column_header->{name});
        }
    }

    push(@column_names, @$proj_dim_names);

    my $class = Net::Google::Analytics::Row->gen_class(@column_names);

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

This package is a subclass of L<Net::Google::Analytics::FeedResponse> and
implements parts of the data feed response of the Google Analytics Data
Export API. The entries in the feed response are of type
L<Net::Google::Analytics::DataFeedEntry>.

See
L<http://code.google.com/apis/analytics/docs/gdata/gdataReferenceDataFeed.html#dataResponse>
for a complete reference.

=head1 ACCESSORS

=head2 is_success

Return false in case of an error

=head2 code

The HTTP status code

=head2 message

The HTTP status message

=head2 total_results

The total number of results for the query, regardless of the number of
results in the response.

=head2 start_index

The 1-based start index of the entries.

=head2 items_per_page

The number of entries.

=head2 entries

An arrayref of the entries.

=head2 aggregates

 my $aggregates = $res->aggregates;

Returns an arrayref of L<Net::Google::Analytics::Metric> objects.

=head1 METHODS

=head2 status_line

 my $status_line = $res->status_line();

Returns the string "<code> <message>".

=head2 project

 $res->project($projection);
 $res->project(\&projection);
 $res->project(sub { ... });

Projects the dimension values of every entry to a set of new dimension values
using subroutine reference $projection. The metrics of entries that are
mapped to the same dimension values are summed up.

The projection subroutine takes as single argument an arrayref of dimension
objects and must return an array of dimension values.

The following example maps a single dimension of type ga:pagePath to
categories.

 $res->project(sub {
     my $dimensions = shift;

     my $page_path = $dimensions->[0]->value;

     return ('flowers') if $page_path =~ m{^/(tulips|roses)};
     return ('fruit')   if $page_path =~ m{^/(apples|oranges)};

     return ('other');
 });

=cut

