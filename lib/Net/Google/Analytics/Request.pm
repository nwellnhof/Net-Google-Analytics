package Net::Google::Analytics::Request;

use strict;
use warnings;

use JSON ();

# ABSTRACT: Google Analytics API request

use Class::XSAccessor
    accessors => [ qw(
        property_id
        dimensions
        metrics
        date_ranges
        dimension_filter
        metric_filter
        offset
        limit
        metric_aggregations
        order_bys
        currency_code
        cohort_spec
        keep_empty_rows
        return_property_quota
    ) ],
    constructor => 'new';

my %param_map = (
    dimensions            => 'dimensions',
    metrics               => 'metrics',
    date_ranges           => 'dateRanges',
    dimension_filter      => 'dimensionFilter',
    metric_filter         => 'metricFilter',
    offset                => 'offset',
    limit                 => 'limit',
    metric_aggregations   => 'metricAggregations',
    order_bys             => 'orderBys',
    currency_code         => 'currencyCode',
    cohort_spec           => 'cohortSpec',
    keep_empty_rows       => 'keepEmptyRows',
    return_property_quota => 'returnPropertyQuota',
);

sub as_json {
    my ($self) = @_;
    my %obj;
    foreach my $k (keys %param_map) {
        if (my $v = $self->$k) {
            $obj{ $param_map{$k} } = $v;
        }
    }
    return JSON::encode_json(\%obj);
}

1;
__END__

=head1 SYNOPSIS

    # for booleans, use \0 or JSON::false and \1 or JSON::true.
    my $request = $ga4->new_request(
        property_id => '123456789',
        dimensions => [ {name => 'searchTerm'} ],
        dimension_filter => {
            filter => {
                fieldName => 'searchTerm',
                stringFilter => {
                    matchType => 'CONTAINS',
                    value => 'my query',
                    caseSensitive => JSON::true,
                }
            }
        },
        metrics    => [ {name => 'viewsPerSession', expression => 'screenPageViews/sessions'} ],
        metric_filter => {
            filter => {
                fieldName => 'viewsPerSession',
                numericFilter => {
                    operation => 'GREATER_THAN',
                    value => 100,
                },
            },
        },
        date_ranges => [ {startDate => '2023-01-01', endDate => '2023-05-31'} ],
        offset => 0,
        limit => 50,
        metric_aggregations => ['TOTAL', 'COUNT'],
        order_bys => [ {desc => \1, metric => { metricName => 'viewsPerSession' }} ],
        currency_code => 'USD',
        keep_empty_rows => \0,
        return_property_quota => \1,
    );

    my $res = $analytics->run_report($req);

=head1 DESCRIPTION

Request class for L<Net::Google::Analytics>.

=head1 CONSTRUCTOR

=head2 new

Creates a new request object with the given parameters. But you probably want
to reach the constructor via L<< Net::Google::Analytics/new_request >>.

=head1 METHODS

=head2 as_json

Returns a JSON representation of the object. Used mostly internally as payload
for the API, or if you are making the actual HTTPS request yourself.

=head1 ACCESSORS

=head2 property_id

The Google Analytics 4 propertyId to use when querying. To find yours, visit L<https://analytics.google.com/> then go to C<< admin :: property :: property settings >>, then copy the property id.

B<NOTE>: The GA4 property id is I<completely numeric>. If you see a property id starting with 'UA-', you're viewing the old "universal analytics", which doesn't work anymore.

=head2 dimensions

An array reference of hash references containing valid L<< GA4 dimensions | https://developers.google.com/analytics/devguides/reporting/data/v1/rest/v1beta/Dimension >>.

=head2 dimension_filter

A hash reference containing a valid L<< G4 filter expression | https://developers.google.com/analytics/devguides/reporting/data/v1/rest/v1beta/FilterExpression >>. This can be used to filter your dimensions.

=head2 metrics

An array reference of hash references containing valid L<< GA4 metrics | https://developers.google.com/analytics/devguides/reporting/data/v1/rest/v1beta/Metric >>.

=head2 metric_filter

A hash reference containing a valid L<< G4 filter expression | https://developers.google.com/analytics/devguides/reporting/data/v1/rest/v1beta/FilterExpression >>. This can be used to filter your metrics.

=head2 date_ranges

An array reference of hash references containing valid L<< GA4 date ranges | https://developers.google.com/analytics/devguides/reporting/data/v1/rest/v1beta/DateRange >>.

=head2 offset

The row count of the start row. The first row is counted as row 0.

=head2 limit

The number of rows to return. If unspecified, 10_000 rows are returned. The API returns a maximum of 250_000 rows per request, no matter how many you ask for.

=head2 metric_aggregations

An array reference of strings containing aggregation of metrics. Can be set to 'TOTAL' (sum), 'MINIMUM', 'MAXIMUM', or 'COUNT'. Aggregated metric values will be shown in rows where the dimensionValues are set to "RESERVED_(MetricAggregation)".

=head2 order_bys

An array reference of hash references containing valid L<< GA4 order by || https://developers.google.com/analytics/devguides/reporting/data/v1/rest/v1beta/OrderBy >> clauses. This lets you sort your results in many different ways.

=head2 currency_code

A string with a valid ISO4217 currency code. Uses the property's default currency when undef.

=head2 cohort_spec

A hash reference to a valid L<< GA4 cohort specification | https://developers.google.com/analytics/devguides/reporting/data/v1/rest/v1beta/CohortSpec >>.

=head2 keep_empty_rows

Boolean. Set to false to ignore rows where all metrics are 0.

=head2 return_property_quota

Boolean. When true, includes the current state of this Analytics Property's quota.
