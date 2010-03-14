#!perl -w
use strict;

use Test::More tests => 31;

our $expect_url;
our $content;

sub get {
    my ($self, $url, %params) = @_;

    is($url, $expect_url, 'url');
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
    return $content;
}

use_ok("Net::Google::Analytics");

my $analytics = Net::Google::Analytics->new();
ok($analytics, 'new');

my $ua = $analytics->user_agent;
ok($ua, 'get user_agent');

$analytics->user_agent(__PACKAGE__);

$analytics->auth_params('Auth-Test' => 'auth_value 123');

my ($req, $res, $entries);

my $account_feed = $analytics->account_feed;
ok($account_feed, 'account fede');

$req = $account_feed->new_request();

$expect_url = 'https://www.google.com/analytics/feeds/accounts/default?start-index=1&max-results=1000&prettyprint=true';
$content = <<'EOF';
<?xml version='1.0' encoding='UTF-8'?>
<feed xmlns='http://www.w3.org/2005/Atom' xmlns:dxp='http://schemas.google.com/analytics/2009' xmlns:ga='http://schemas.google.com/ga/2009' xmlns:openSearch='http://a9.com/-/spec/opensearch/1.1/' xmlns:gd='http://schemas.google.com/g/2005' gd:etag='W/&quot;DUcCRX47eCp7I2A9WxNbFkk.&quot;' gd:kind='analytics#accounts'>
        <id>http://www.google.com/analytics/feeds/accounts/abc@test.com</id>
        <updated>2009-11-19T08:11:04.000-08:00</updated>
        <title>Profile list for abc@test.com</title>
        <link rel='self' type='application/atom+xml' href='http://www.google.com/analytics/feeds/accounts/default'/>
        <author>
                <name>Google Analytics</name>
        </author>
        <generator version='1.0'>Google Analytics</generator>
        <openSearch:totalResults>41</openSearch:totalResults>
        <openSearch:startIndex>1</openSearch:startIndex>
        <openSearch:itemsPerPage>3</openSearch:itemsPerPage>
        <dxp:segment id='gaid::-1' name='All Visits'>
                <dxp:definition> </dxp:definition>
        </dxp:segment>
        <dxp:segment id='gaid::-2' name='New Visitors'>
                <dxp:definition>ga:visitorType==New Visitor</dxp:definition>
        </dxp:segment>
        <dxp:segment id='gaid::-3' name='Returning Visitors'>
                <dxp:definition>ga:visitorType==Returning Visitor</dxp:definition>
        </dxp:segment>
        <dxp:segment id='gaid::-4' name='Paid Search Traffic'>
                <dxp:definition>ga:medium==cpa,ga:medium==cpc,ga:medium==cpm,ga:medium==cpp,ga:medium==cpv,ga:medium==ppc</dxp:definition>
        </dxp:segment>
        <dxp:segment id='gaid::-5' name='Non-paid Search Traffic'>
                <dxp:definition>ga:medium==organic</dxp:definition>
        </dxp:segment>
        <dxp:segment id='gaid::-6' name='Search Traffic'>
                <dxp:definition>ga:medium==cpa,ga:medium==cpc,ga:medium==cpm,ga:medium==cpp,ga:medium==cpv,ga:medium==organic,ga:medium==ppc</dxp:definition>
        </dxp:segment>
        <dxp:segment id='gaid::-7' name='Direct Traffic'>
                <dxp:definition>ga:medium==(none)</dxp:definition>
        </dxp:segment>
        <dxp:segment id='gaid::-8' name='Referral Traffic'>
                <dxp:definition>ga:medium==referral</dxp:definition>
        </dxp:segment>
        <dxp:segment id='gaid::-9' name='Visits with Conversions'>
                <dxp:definition>ga:goalCompletionsAll&gt;0</dxp:definition>
        </dxp:segment>
        <dxp:segment id='gaid::-10' name='Visits with Transactions'>
                <dxp:definition>ga:transactions&gt;0</dxp:definition>
        </dxp:segment>
        <dxp:segment id='gaid::-11' name='Visits from iPhones'>
                <dxp:definition>ga:operatingSystem==iPhone</dxp:definition>
        </dxp:segment>
        <dxp:segment id='gaid::-12' name='Non-bounce Visits'>
                <dxp:definition>ga:bounces==0</dxp:definition>
        </dxp:segment>
        <dxp:segment id='gaid::0' name='Sources Form Google'>
                <dxp:definition>ga:source=~^\Qgoogle\E</dxp:definition>
        </dxp:segment>
        <entry gd:etag='W/&quot;DUcCRX47eCp7I2A9WxNbFkk.&quot;' gd:kind='analytics#account'>
                <id>http://www.google.com/analytics/feeds/accounts/ga:1174</id>
                <updated>2009-11-19T08:11:04.000-08:00</updated>
                <title>www.googlestore.com</title>
                <link rel='alternate' type='text/html' href='http://www.google.com/analytics'/>
                <ga:goal active='true' name='Completing Order' number='1' value='10.0'>
                        <ga:destination caseSensitive='false' expression='/purchaseComplete.html' matchType='regex' step1Required='false'>
                                <ga:step name='View Product Categories' number='1' path='/Apps|Accessories'/>
                                <ga:step name='View Product' number='2' path='/Apps|Accessories/(.*)\.axd'/>
                                <ga:step name='View Shopping Cart' number='3' path='/shoppingcart.aspx'/>
                                <ga:step name='Login' number='4' path='/login.html'/>
                                <ga:step name='Place Order' number='5' path='/placeOrder.html'/>
                        </ga:destination>
                </ga:goal>
                <ga:goal active='true' name='Browsed my site over 5 minutes' number='2' value='0.0'>
                        <ga:engagement comparison='&gt;' thresholdValue='300' type='timeOnSite'/>
                </ga:goal>
                <ga:goal active='true' name='Visited &gt; 4 pages' number='3' value='0.25'>
                        <ga:engagement comparison='&gt;' thresholdValue='4' type='pagesVisited'/>
                </ga:goal>
                <dxp:property name='ga:accountId' value='30481'/>
                <dxp:property name='ga:accountName' value='Google Store'/>
                <dxp:property name='ga:profileId' value='1174'/>
                <dxp:property name='ga:webPropertyId' value='UA-30481-1'/>
                <dxp:property name='ga:currency' value='USD'/>
                <dxp:property name='ga:timezone' value='America/Los_Angeles'/>
                <dxp:tableId>ga:1174</dxp:tableId>
        </entry>
        <entry gd:etag='W/&quot;DkEASH47eCp7I2A9WxNbFUo.&quot;' gd:kind='analytics#account'>
                <id>http://www.google.com/analytics/feeds/accounts/ga:11380020</id>
                <updated>2009-11-18T12:04:09.000-08:00</updated>
                <title>Googlestore - overall</title>
                <link rel='alternate' type='text/html' href='http://www.google.com/analytics'/>
                <ga:goal active='false' name='goal2.html' number='1' value='0.0'>
                        <ga:destination caseSensitive='false' expression='/goal2.html' matchType='head' step1Required='false'/>
                </ga:goal>
                <dxp:property name='ga:accountId' value='30481'/>
                <dxp:property name='ga:accountName' value='Google Store'/>
                <dxp:property name='ga:profileId' value='11380020'/>
                <dxp:property name='ga:webPropertyId' value='UA-30481-1'/>
                <dxp:property name='ga:currency' value='USD'/>
                <dxp:property name='ga:timezone' value='America/Los_Angeles'/>
                <dxp:tableId>ga:11380020</dxp:tableId>
        </entry>
        <entry gd:etag='W/&quot;C04HRn47eCp7I2A9WxJbGUQ.&quot;' gd:kind='analytics#account'>
                <id>http://www.google.com/analytics/feeds/accounts/ga:11380025</id>
                <updated>2009-07-30T15:12:17.000-07:00</updated>
                <title>Googlestore - no filters</title>
                <link rel='alternate' type='text/html' href='http://www.google.com/analytics'/>
                <dxp:property name='ga:accountId' value='30481'/>
                <dxp:property name='ga:accountName' value='Google Store'/>
                <dxp:property name='ga:profileId' value='11380025'/>
                <dxp:property name='ga:webPropertyId' value='UA-30481-1'/>
                <dxp:property name='ga:currency' value='USD'/>
                <dxp:property name='ga:timezone' value='America/Los_Angeles'/>
                <dxp:tableId>ga:11380025</dxp:tableId>
        </entry>
</feed>
EOF

$res = $account_feed->retrieve($req);
ok($res, 'retrieve account');

is($res->total_results, 41, 'total_results');

$entries = $res->entries;
ok($entries, 'entries');

is(@$entries, 3, 'count entries');

is($entries->[0]->account_id, '30481');
is($entries->[1]->profile_id, '11380020');
is($entries->[2]->table_id, 'ga:11380025');

my $data_feed = $analytics->data_feed;
ok($data_feed, 'data_feed');

$req = $data_feed->new_request();
$req->ids('ga:1234567');
$req->dimensions('ga:country');
$req->metrics('ga:visits');
$req->sort('-ga:visits');
$req->max_results(20);
$req->start_date('2010-01-01');
$req->end_date('2010-01-31');

$expect_url = 'https://www.google.com/analytics/feeds/data?ids=ga%3A1234567&dimensions=ga%3Acountry&metrics=ga%3Avisits&sort=-ga%3Avisits&start-date=2010-01-01&end-date=2010-01-31&start-index=1&max-results=20&prettyprint=true';
$content = <<'EOF';
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

$res = $data_feed->retrieve($req);
ok($res, 'retrieve data');

is($res->total_results, 6451, 'total_results');

$entries = $res->entries;
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

