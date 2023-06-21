use strict;
use warnings;
use Test::More tests => 24;

my $post_form;

use Net::Google::Analytics;
pass 'Net::Google::Analytics loaded successfully';

ok my $ga = Net::Google::Analytics->new, 'able to instantiate object';
isa_ok $ga, 'Net::Google::Analytics';

ok $ga->token({
    token_type => 'some_type',
    access_token => 1234
}), 'token() called successfully';

my $request = $ga->new_request(
    property_id => '123456789',
    dimensions  => [{name => 'sessionSource'}],
    metrics     => [{name => 'screenPageViews'}],
    date_ranges => [ {startDate => '2023-01-01', endDate => '2023-05-31'} ],
    limit       => 50,
    order_bys   => [ {desc => \1, metric => { metricName => 'screenPageViews' }} ],
);

require HTTP::Tiny;
{ no warnings 'redefine', 'once';
  *HTTP::Tiny::request = sub {
    my ($self, @args) = @_;
    $post_form = \@args;
    return {
        success => 1,
        status  => 200,
        reason  => 'OK',
        content => '{"kind":"analyticsData#runReport","dimensionHeaders":[{"name":"sessionSource"}],"metricHeaders":[{"name":"screenPageViews"}],"rowCount":2,"rows":[{"dimensionValues":[{"value":"valForDim1"}],"metricValues":[{"value":"valForMet1"}]},{"dimensionValues":[{"value":"valForDim2"}],"metricValues":[{"value":"valForMet2"}]}]}',
    };
  };
}

ok my $res = $ga->run_report($request), 'got response after running report';
is $post_form->[0], 'POST', 'sent the proper request method';
is $post_form->[1], 'https://analyticsdata.googleapis.com/v1beta/properties/123456789:runReport', 'sending to the proper endpoint';
like $post_form->[2]{content}, qr/\A\{.+\}\z/, 'content looks like json';
is $post_form->[2]{headers}{Authorization}, 'some_type 1234', 'token used in auth';

isa_ok $res, 'Net::Google::Analytics::Response';
is_deeply [$res->dimensions], ['session_source'], 'dimensions parsed ok';
is_deeply [$res->metrics], ['screen_page_views'], 'metrics parsed ok';

my @rows = $res->rows;
my @expected = (
    {session_source => 'valForDim1', 'screen_page_views' => 'valForMet1'},
    {session_source => 'valForDim2', 'screen_page_views' => 'valForMet2'},
);

foreach my $i (0 .. $#rows) {
    my $row = $rows[$i];
    isa_ok $row, 'Net::Google::Analytics::Row';
    can_ok $row, qw(get_session_source get_screen_page_views get);
    is $row->get_session_source, $row->get('session_source'), "alias for dimension ($i)";
    is $row->get_screen_page_views, $row->get('screen_page_views'), "alias for metric ($i)";
    is $row->get_session_source, $expected[$i]{session_source}, "dimension value ($i)";
    is $row->get_screen_page_views, $expected[$i]{screen_page_views}, "metric value ($i)";
}
