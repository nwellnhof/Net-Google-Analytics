package Net::Google::Analytics::Response;

use strict;
use warnings;

use Net::Google::Analytics::Row;
use JSON ();

# ABSTRACT: Google Analytics API response

use Class::XSAccessor
    accessors => [ qw(
      is_success
      code
      message
      content
      content_data
      error_message
      dimension_headers
      metric_headers
      rows_ref
      totals
      maximums
      minimums
      row_count
      metadata
      property_quota
      kind
    ) ],
    constructor => 'new';

sub new_from_http_response {
    my ($class, $response) = @_;

    my $json = JSON::decode_json($response->{content});

    my %parsers = (
        'analyticsData#batchRunReports' => \&_new_batch_run_reports,
        'analyticsData#runReport'       => \&_new_run_report,
    );
    my $parser = $parsers{ $json->{kind} } || \&_new_error;
    return $parser->($class, $response, $json);
}

sub _new_error {
    my ($class, $response, $json) = @_;

    return $class->new(
        is_success        => $response->{success},
        code              => $response->{status},
        message           => $response->{reason},
        content           => $response->{content},
        error_message     => ($json->{error} ? $json->{error}{status} . ': ' . $json->{error}{message} : 'unable to parse response'),
        content_data      => $json,
    );
}

sub _new_batch_run_reports {
    my ($class, $response, $json) = @_;

    my @reports;
    foreach my $report (@{$json->{reports}}) {
        push @reports, _new_run_report($class, $response, $report);
    }
    return \@reports;
}

sub _new_run_report {
    my ($class, $response, $json) = @_;

    my $self = $class->new(
        is_success        => $response->{success},
        code              => $response->{status},
        message           => $response->{reason},
        content           => $response->{content},
        error_message     => ($json->{error} ? $json->{error}{status} . ': ' . $json->{error}{message} : ''),
        content_data      => $json,

        dimension_headers => $json->{dimensionHeaders},
        metric_headers    => $json->{metricHeaders},
        totals            => $json->{totals},
        maximums          => $json->{maximums},
        minimums          => $json->{minimums},
        row_count         => $json->{rowCount},
        metadata          => $json->{metadata},
        property_quota    => $json->{propertyQuota},
        kind              => $json->{kind},
    );
    $self->_build_rows;
    return $self;
}

sub _build_rows {
    my ($self) = @_;
    my $row_class = Net::Google::Analytics::Row->gen_class(
        dimensions => [ $self->dimensions ],
        metrics    => [ $self->metrics    ],
    );
    my @rows;
    foreach my $row_data (@{$self->content_data->{rows}}) {
        push @rows, $row_class->new($row_data);
    }
    $self->rows_ref(\@rows);
    return;
}

sub rows {
    my ($self) = @_;
    return @{$self->rows_ref};
}

sub dimensions {
    my ($self) = @_;
    if (!$self->{_cached_dimensions}) {
        $self->{_cached_dimensions} = [map _camel2snake($_->{name}), @{$self->{dimension_headers}}];
    }
    return @{$self->{_cached_dimensions}};
}

sub metrics {
    my ($self) = @_;
    if (!$self->{_cached_metrics}) {
        $self->{_cached_metrics} = [map _camel2snake($_->{name}), @{$self->{metric_headers}}];
    }
    return @{$self->{_cached_metrics}};
}

sub _camel2snake {
    my ($src) = @_;
    $src =~ s{([^A-Z]?)([A-Z]+)}{
        my ($prev, $upper) = ($1, $2);
        $prev . ($prev =~ /[a-z]/ ? '_' : '') . lc($upper);
    }ge;
    return $src;
}

1;
__END__

=head1 DESCRIPTION

Response class for L<Net::Google::Analytics> web service.

=head1 SYNOPSIS

    my $res = $analytics->retrieve($req);
    die "GA error: " . $res->error_message unless $res->is_success;

    say "Showing results: 1.." . scalar($res->rows)
      . " of " . $res->row_count;

    foreach my $row ($res->rows) {
        say $row->get_source  . ": "
          . $row->get_visits  . " visits, "
          . $row->get_bounces . " bounces";
    }

    say "Total: "
      . $res->totals("visits"),  " visits, "
      . $res->totals("bounces"), " bounces";

=head1 ACCESSORS

=head2 is_success

True for successful requests, false in case of an error.

=head2 code

The HTTP status code.

=head2 message

The HTTP status message.

=head2 error_message

The full error message.

=head2 row_count

The total number of results for the query, regardless of the number of
results you got in the response.

=head2 rows

An arrayref of result rows of type L<Net::Google::Analytics::Row>.

=head2 dimensions

An array of all dimension names, converted to lower case with underscores.

=head2 metrics

An array of all metric names,converted to lower case with underscores.

=head2 totals

If you specified your request with C<metric_aggregation> as 'TOTAL', this
accessor will contain the aggregated value.

=head2 maximums

If you specified your request with C<metric_aggregation> as 'MAXIMUM', this
accessor will contain the aggregated value.

=head2 minimums

If you specified your request with C<metric_aggregation> as 'MINIMUM', this
accessor will contain the aggregated value.

=head2 metadata

Additional information about the report content, like currency code and timezone.

=head2 property_quota

The quota for this analytics' property. Only returned when your request contains
C<return_property_quota> set to true.

=head2 kind

A string with the kind of resource this message is (e.g. 'analyticsData#runReport').
Useful for distinguishing response types, if you need to.

=head1 ACCESSORS FOR RAW CONTENT

Sometimes you want to check the actual response data by yourself. To help
those cases, the following accessors are provided:

=head2 content

This field contains the content body string, as received in the HTTP response.
Useful for debugging, as it may contain additional information in case of errors.
(though you should first check the 'error_message' accessor).

=head2 content_data

This is the exact data structure received in the HTTP response, translated from JSON
to a hash reference.

You can see the official documentation for the API's response L<here|https://developers.google.com/analytics/devguides/reporting/data/v1/rest/v1beta/RunReportResponse>.

=head2 rows_ref

Array reference containing the raw rows as received from the HTTP response,
whithout any parsing. You should probably use L</rows> instead.

=head2 dimension_headers

Array reference of hash references containing the header of each dimension.
You should probably use L</dimensions> instead.

=head2 metric_headers

Array reference of hash references containing the header of each metric.
You should probably use L</metrics> instead.

=head1 CONSTRUCTORS

B<You are not meant to create these objects yourself>. Instead, they will spawn
from calling the methods listed in L<Net::Google::Analytics>.

=head2 new

Instantiates a new object. May receive a hash with accessor data and extra
information. You are likely more interested in L</new_from_http_response>,
if at all.

=head2 new_from_http_response

Receives an HTTP::Tiny response data structure from any GA4 API query, and
parses that into one or more Response objects.
