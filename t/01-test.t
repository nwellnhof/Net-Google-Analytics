#!perl -w
use strict;

use Test::More tests => 20;

sub get {
    my ($self, $url, %params) = @_;

    is(
        $url,
        'https://www.google.com/analytics/feeds/data?ids=ga%3A1234567&dimensions=ga%3Acountry&metrics=ga%3Avisits&sort=-ga%3Avisits&start-date=2010-01-01&end-date=2010-01-31&start-index=1&max-results=20&prettyprint=true',
        'url',
    );
    is_deeply(
        \%params,
        {
            'GData-Version' => 2,
            'Auth-Test'     => 'auth_value 123',
        },
        'auth_params',
    );

    return $self;
}

sub is_success {
    return 1;
}

sub content {
    return <<'EOF';
<?xml version='1.0' encoding='UTF-8'?>
<feed xmlns='http://www.w3.org/2005/Atom' xmlns:dxp='http://schemas.google.com/analytics/2009' xmlns:openSearch='http://a9.com/-/spec/opensearch/1.1/' xmlns:gd='http://schemas.google.com/g/2005' gd:etag='W/&quot;DUINSHcycSp7I2A9WxRWFEQ.&quot;' gd:kind='analytics#data'>
        <id>http://www.google.com/analytics/feeds/data?ids=ga:1174&amp;dimensions=ga:medium,ga:source&amp;metrics=ga:bounces,ga:visits&amp;filters=ga:medium%3D%3Dreferral&amp;start-date=2008-10-01&amp;end-date=2008-10-31</id>
        <updated>2008-10-31T16:59:59.999-07:00</updated>
        <title>Google Analytics Data for Profile 1174</title>
        <link rel='self' type='application/atom+xml' href='http://www.google.com/analytics/feeds/data?max-results=5&amp;sort=-ga%3Avisits&amp;end-date=2008-10-31&amp;start-date=2008-10-01&amp;metrics=ga%3Avisits%2Cga%3Abounces&amp;ids=ga%3A1174&amp;dimensions=ga%3Asource%2Cga%3Amedium&amp;filters=ga%3Amedium%3D%3Dreferral'/>
        <link rel='next' type='application/atom+xml' href='http://www.google.com/analytics/feeds/data?start-index=6&amp;max-results=5&amp;sort=-ga%3Avisits&amp;end-date=2008-10-31&amp;start-date=2008-10-01&amp;metrics=ga%3Avisits%2Cga%3Abounces&amp;ids=ga%3A1174&amp;dimensions=ga%3Asource%2Cga%3Amedium&amp;filters=ga%3Amedium%3D%3Dreferral'/>
        <author>
                <name>Google Analytics</name>
        </author>
        <generator version='1.0'>Google Analytics</generator>
        <openSearch:totalResults>6451</openSearch:totalResults>
        <openSearch:startIndex>1</openSearch:startIndex>
        <openSearch:itemsPerPage>5</openSearch:itemsPerPage>
        <dxp:aggregates>
                <dxp:metric confidenceInterval='0.0' name='ga:visits' type='integer' value='136540'/>
                <dxp:metric confidenceInterval='0.0' name='ga:bounces' type='integer' value='101535'/>
        </dxp:aggregates>
        <dxp:dataSource>
                <dxp:property name='ga:profileId' value='1174'/>
                <dxp:property name='ga:webPropertyId' value='UA-30481-1'/>
                <dxp:property name='ga:accountName' value='Google Store'/>
                <dxp:tableId>ga:1174</dxp:tableId>
                <dxp:tableName>www.googlestore.com</dxp:tableName>
        </dxp:dataSource>
        <dxp:endDate>2008-10-31</dxp:endDate>
        <dxp:startDate>2008-10-01</dxp:startDate>
        <entry gd:etag='W/&quot;C0UEQX47eSp7I2A9WxRWFEw.&quot;' gd:kind='analytics#datarow'>
                <id>http://www.google.com/analytics/feeds/data?ids=ga:1174&amp;ga:medium=referral&amp;ga:source=blogger.com&amp;filters=ga:medium%3D%3Dreferral&amp;start-date=2008-10-01&amp;end-date=2008-10-31</id>
                <updated>2008-10-30T17:00:00.001-07:00</updated>
                <title>ga:source=blogger.com | ga:medium=referral</title>
                <link rel='alternate' type='text/html' href='http://www.google.com/analytics'/>
                <dxp:dimension name='ga:source' value='blogger.com'/>
                <dxp:dimension name='ga:medium' value='referral'/>
                <dxp:metric confidenceInterval='0.0' name='ga:visits' type='integer' value='68140'/>
                <dxp:metric confidenceInterval='0.0' name='ga:bounces' type='integer' value='61095'/>
        </entry>
        <entry gd:etag='W/&quot;C0UEQX47eSp7I2A9WxRWFEw.&quot;' gd:kind='analytics#datarow'>
                <id>http://www.google.com/analytics/feeds/data?ids=ga:1174&amp;ga:medium=referral&amp;ga:source=google.com&amp;filters=ga:medium%3D%3Dreferral&amp;start-date=2008-10-01&amp;end-date=2008-10-31</id>
                <updated>2008-10-30T17:00:00.001-07:00</updated>
                <title>ga:source=google.com | ga:medium=referral</title>
                <link rel='alternate' type='text/html' href='http://www.google.com/analytics'/>
                <dxp:dimension name='ga:source' value='google.com'/>
                <dxp:dimension name='ga:medium' value='referral'/>
                <dxp:metric confidenceInterval='0.0' name='ga:visits' type='integer' value='29666'/>
                <dxp:metric confidenceInterval='0.0' name='ga:bounces' type='integer' value='14979'/>
        </entry>
        <entry gd:etag='W/&quot;C0UEQX47eSp7I2A9WxRWFEw.&quot;' gd:kind='analytics#datarow'>
                <id>http://www.google.com/analytics/feeds/data?ids=ga:1174&amp;ga:medium=referral&amp;ga:source=stumbleupon.com&amp;filters=ga:medium%3D%3Dreferral&amp;start-date=2008-10-01&amp;end-date=2008-10-31</id>
                <updated>2008-10-30T17:00:00.001-07:00</updated>
                <title>ga:source=stumbleupon.com | ga:medium=referral</title>
                <link rel='alternate' type='text/html' href='http://www.google.com/analytics'/>
                <dxp:dimension name='ga:source' value='stumbleupon.com'/>
                <dxp:dimension name='ga:medium' value='referral'/>
                <dxp:metric confidenceInterval='0.0' name='ga:visits' type='integer' value='4012'/>
                <dxp:metric confidenceInterval='0.0' name='ga:bounces' type='integer' value='848'/>
        </entry>
        <entry gd:etag='W/&quot;C0UEQX47eSp7I2A9WxRWFEw.&quot;' gd:kind='analytics#datarow'>
                <id>http://www.google.com/analytics/feeds/data?ids=ga:1174&amp;ga:medium=referral&amp;ga:source=google.co.uk&amp;filters=ga:medium%3D%3Dreferral&amp;start-date=2008-10-01&amp;end-date=2008-10-31</id>
                <updated>2008-10-30T17:00:00.001-07:00</updated>
                <title>ga:source=google.co.uk | ga:medium=referral</title>
                <link rel='alternate' type='text/html' href='http://www.google.com/analytics'/>
                <dxp:dimension name='ga:source' value='google.co.uk'/>
                <dxp:dimension name='ga:medium' value='referral'/>
                <dxp:metric confidenceInterval='0.0' name='ga:visits' type='integer' value='2968'/>
                <dxp:metric confidenceInterval='0.0' name='ga:bounces' type='integer' value='2084'/>
        </entry>
        <entry gd:etag='W/&quot;C0UEQX47eSp7I2A9WxRWFEw.&quot;' gd:kind='analytics#datarow'>
                <id>http://www.google.com/analytics/feeds/data?ids=ga:1174&amp;ga:medium=referral&amp;ga:source=google.co.in&amp;filters=ga:medium%3D%3Dreferral&amp;start-date=2008-10-01&amp;end-date=2008-10-31</id>
                <updated>2008-10-30T17:00:00.001-07:00</updated>
                <title>ga:source=google.co.in | ga:medium=referral</title>
                <link rel='alternate' type='text/html' href='http://www.google.com/analytics'/>
                <dxp:dimension name='ga:source' value='google.co.in'/>
                <dxp:dimension name='ga:medium' value='referral'/>
                <dxp:metric confidenceInterval='0.0' name='ga:visits' type='integer' value='2793'/>
                <dxp:metric confidenceInterval='0.0' name='ga:bounces' type='integer' value='1891'/>
        </entry>
</feed>
EOF
}

use_ok("Net::Google::Analytics");

my $analytics = Net::Google::Analytics->new();
ok($analytics, 'new');

my $ua = $analytics->user_agent;
ok($ua, 'get user_agent');

$analytics->user_agent(__PACKAGE__);

$analytics->auth_params('Auth-Test' => 'auth_value 123');

my ($req, $res);

my $data_feed = $analytics->data_feed;
$req = $data_feed->new_request();
$req->ids('ga:1234567');
$req->dimensions('ga:country');
$req->metrics('ga:visits');
$req->sort('-ga:visits');
$req->max_results(20);
$req->start_date('2010-01-01');
$req->end_date('2010-01-31');
$res = $data_feed->retrieve($req);
ok($res, 'retrieve');

is($res->total_results, 6451, 'total_results');

my $entries = $res->entries;
ok($entries, 'entries');

is(@$entries, 5, 'count entries');

is($entries->[0]->dimensions->[1]->name, 'ga:medium');
is($entries->[1]->dimensions->[0]->value, 'google.com');
is($entries->[2]->metrics->[1]->name, 'ga:bounces');
is($entries->[3]->metrics->[0]->type, 'integer');
is($entries->[4]->metrics->[1]->value, '1891');
is($entries->[0]->metrics->[0]->confidence_interval, '0.0');

my $aggregates = $res->aggregates;
ok($aggregates, 'aggregates');

is($aggregates->[0]->name, 'ga:visits');
is($aggregates->[1]->value, '101535');

$analytics->finish();
is($analytics->account_feed, undef, 'finish');
is($analytics->data_feed, undef, 'finish');

