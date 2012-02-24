#!perl -w
use strict;

use Test::More tests => 28;

our $expect_url;
our $content;

sub get {
    my ($self, $url, %params) = @_;

    is($url, $expect_url, 'url');
    is_deeply(
        \%params,
        {
            'Auth-Test' => 'auth_value 123',
        },
        'auth_params',
    );

    return $self;
}

sub is_success {
    return 1;
}

sub decoded_content {
    return $content;
}

use_ok("Net::Google::Analytics");

my $analytics = Net::Google::Analytics->new();
ok($analytics, 'new');

my $ua = $analytics->user_agent;
ok($ua, 'get user_agent');

$analytics->user_agent(__PACKAGE__);

$analytics->auth_params('Auth-Test' => 'auth_value 123');

my ($req, $res, $rows);

$req = $analytics->new_request();
$req->ids('ga:1234567');
$req->dimensions('ga:country');
$req->metrics('ga:visits');
$req->sort('-ga:visits');
$req->start_index(1);
$req->max_results(20);
$req->start_date('2010-01-01');
$req->end_date('2010-01-31');

$expect_url = 'https://www.googleapis.com/analytics/v3/data/ga?ids=ga%3A1234567&start-date=2010-01-01&end-date=2010-01-31&metrics=ga%3Avisits&dimensions=ga%3Acountry&sort=-ga%3Avisits&start-index=1&max-results=20';
$content = <<'EOF';
{
 "kind": "analytics#gaData",
 "id": "https://www.googleapis.com/analytics/v3/data/ga?ids=ga:1234567&dimensions=ga:medium,ga:source&metrics=ga:bounces,ga:visits&sort=-ga:visits&filters=ga:medium%3D%3Dreferral&start-date=2008-10-01&end-date=2008-10-31&start-index=1&max-results=5",
 "query": {
  "start-date": "2008-10-01",
  "end-date": "2008-10-31",
  "ids": "ga:1234567",
  "dimensions": "ga:medium,ga:source",
  "metrics": [
   "ga:bounces",
   "ga:visits"
  ],
  "sort": [
   "-ga:visits"
  ],
  "filters": "ga:medium==referral",
  "start-index": 1,
  "max-results": 5
 },
 "itemsPerPage": 5,
 "totalResults": 6451,
 "selfLink": "https://www.googleapis.com/analytics/v3/data/ga?ids=ga:1234567&dimensions=ga:medium,ga:source&metrics=ga:bounces,ga:visits&sort=-ga:visits&filters=ga:medium%3D%3Dreferral&start-date=2008-10-01&end-date=2008-10-31&start-index=1&max-results=5",
 "nextLink": "https://www.googleapis.com/analytics/v3/data/ga?ids=ga:1234567&dimensions=ga:medium,ga:source&metrics=ga:bounces,ga:visits&sort=-ga:visits&filters=ga:medium%3D%3Dreferral&start-date=2008-10-01&end-date=2008-10-31&start-index=6&max-results=5",
 "profileInfo": {
  "profileId": "1234567",
  "accountId": "7654321",
  "webPropertyId": "UA-7654321-1",
  "internalWebPropertyId": "9999999",
  "profileName": "Test Profile",
  "tableId": "ga:1234567"
 },
 "containsSampledData": false,
 "columnHeaders": [
  {
   "name": "ga:medium",
   "columnType": "DIMENSION",
   "dataType": "STRING"
  },
  {
   "name": "ga:source",
   "columnType": "DIMENSION",
   "dataType": "STRING"
  },
  {
   "name": "ga:bounces",
   "columnType": "METRIC",
   "dataType": "INTEGER"
  },
  {
   "name": "ga:visits",
   "columnType": "METRIC",
   "dataType": "INTEGER"
  }
 ],
 "totalsForAllResults": {
  "ga:bounces": "101535",
  "ga:visits": "136540"
 },
 "rows": [
  [
   "referral",
   "blogger.com",
   "61095",
   "68140"
  ],
  [
   "referral",
   "google.com",
   "14979",
   "29666"
  ],
  [
   "referral",
   "stumbleupon.com",
   "848",
   "4012"
  ],
  [
   "referral",
   "google.co.uk",
   "2084",
   "2968"
  ],
  [
   "referral",
   "google.co.in",
   "1891",
   "2793"
  ]
 ]
}
EOF

$res = $analytics->retrieve($req);
ok($res, 'retrieve data');
ok($res->is_success, 'retrieve success');

is($res->total_results, 6451, 'total_results');
is($res->start_index, 1, 'start_index');
is($res->items_per_page, 5, 'items_per_page');

my $column_headers = $res->column_headers;
ok($column_headers, 'column headers');
is($column_headers->[0]->{name}, 'medium');
is($column_headers->[2]->{column_type}, 'METRIC');
is($column_headers->[3]->{data_type}, 'INTEGER');

$rows = $res->rows;
ok($rows, 'rows');

is(@$rows, 5, 'count rows');

is($rows->[0]->ga_medium, 'referral');
is($rows->[1]->ga_source, 'google.com');
is($rows->[2]->ga_visits, '4012');
is($rows->[4]->ga_bounces, '1891');

my $totals = $res->totals;
ok($totals, 'totals');

#is($totals->[0]->name, 'ga:visits');
is($totals->{'ga:bounces'}, '101535');

SKIP: {
    skip('project not yet implemented', 6);

    $res->project(sub {
        my $dimensions = shift;

        my $source = $dimensions->[0]->value;

        return ($source =~ /\.co\.[a-z]+\z/i ? 'dot-co-domain' : 'other');
    });

    $rows = $res->rows;
    ok($rows, 'rows');

    is(@$rows, 2, 'count rows');

    for my $row (@$rows) {
        if ($row->dimensions->[0]->value eq 'dot-co-domain') {
            is($row->ga_visits, 5_761);
            is($row->ga_bounces, 3_975);
        }
        else {
            is($row->ga_visits, 101_818);
            is($row->ga_bounces,  76_922);
        }
    }
};

