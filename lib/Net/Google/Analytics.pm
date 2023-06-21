package Net::Google::Analytics;

use strict;
use warnings;

# ABSTRACT: Simple interface to the Google Analytics API (GA4)

use HTTP::Tiny;
use Net::Google::Analytics::Request;
use Net::Google::Analytics::Response;

sub new {
    my ($class, %args) = @_;

    my $self = bless {
        user_agent => HTTP::Tiny->new(
            agent      => __PACKAGE__,
            verify_SSL => 1,
        ),
    }, $class;

    $self->token($args{token}) if $args{token};

    return $self;
}

sub token {
    my ($self, $token) = @_;

    $self->{auth_params} = [
        Authorization => "$token->{token_type} $token->{access_token}",
    ];

    return $self;
}

sub new_request {
    my $self = shift;

    return Net::Google::Analytics::Request->new(@_);
}

sub run_report {
    my ($self, $request) = @_;

    return $self->_execute_request( $request->property_id . ':runReport', $request->as_json );
}

sub batch_run_reports {
    my ($self, @requests) = @_;

    @requests = @{$requests[0]} if @requests == 1 && ref $requests[0] eq 'ARRAY';
    die 'batch requests are limited to 5 requests' if @requests > 5;

    my @json;
    my $property_id = $requests[0]->property_id;
    foreach my $req (@requests) {
        die 'all batch requests must be of the same property'
            if $req->property_id != $property_id;
        push @json, $req->as_json;
    }

    return $self->_execute_request(
        $property_id . ':batchRunReports',
        '{"requests":[' . join(',' => @json) . ']}'
    );
}

sub _execute_request {
    my ($self, $endpoint, $content) = @_;

    my $res = $self->{user_agent}->request(
        'POST',
        'https://analyticsdata.googleapis.com/v1beta/properties/' . $endpoint,
        {
          headers => {
              'Content-Type' => 'application/json',
              'Accept' => 'application/json',
              @{$self->{auth_params}}
          },
          content => $content,
        }
    );
    return Net::Google::Analytics::Response->new_from_http_response($res);
}

1;
__END__

=head1 SYNOPSIS

    use Net::Google::Analytics;
    use Net::Google::Analytics::OAuth2;

    my $oauth = Net::Google::Analytics::OAuth2->new(
        client_id     => 'your_client_id_here',
        client_secret => 'your_client_secret_here',
    );
    my $token = $oauth->refresh_access_token('your_refresh_secret_here');

    my $ga4 = Net::Google::Analytics->new;
    $ga4->token($token);

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

    my $res = $ga4->run_report($request);

=head1 DESCRIPTION

This module provides a simple, straightforward interface to the Google Analytics Data API for Google Analytics 4 (GA4).

This was previously referred to as "Core Reporting API" on Google Analytics version 3 and Universal Analytics. B<< On July 1, 2023, standard Universal Analytics properties stopped processing data and must be updated to GA4 >>.

B<< PLEASE UPDATE THIS MODULE TO VERSION 4.0 OR HIGHER TO CONTINUE USING GOOGLE ANALYTICS. >>

See L<https://developers.google.com/analytics/devguides/reporting/data/v1>

=head1 GETTING STARTED

This module uses Google Analytics' API from a single Google User Account.
This means you will need a Google account user that has (at least) read
access to the Google Analytics profile you want to query. What we'll do
is, through L<OAuth2|Net::Google::Analytics::OAuth2>, have that user
grant Analytics access to your Perl app.

=head2 Getting your client id and client secret

First, you have to register your project through the
L<Google Developers Console|https://console.developers.google.com/>.

Next, on your project's API Manager page, go over to "credentials" and click
on the "I<Create credentials>" button. When the drop down menu appears,
click on "I<Help me choose>".

=for html
<p>
<img src="https://raw.githubusercontent.com/nwellnhof/Net-Google-Analytics/master/doc_images/credent
ials-howto-1.png" alt="screenshot of Google's API Manager menu" />
</p>

Select "Analytics API" under "I<Which API are you using?>", and select
"Other UI (CLI)" under "I<Where will you be calling the API from?>". Finally,
when they ask you "I<What data will you be accessing?>", choose "User data".

=for html
<p>
<img src="https://raw.githubusercontent.com/nwellnhof/Net-Google-Analytics/master/doc_images/credent
ials-howto-2.png" alt="screenshot of Google's API options" />
</p>

At the end of this process, you will receive a B<client id> and a B<client secret>
for your application in the API Manager Console.

=head2 Get the refresh token

The final step is to get a refresh token. This is required because OAuth
access is granted only for a limited time, and the refresh token allows your
app to renew that access whenever it needs.

You can obtain a refresh token for your application by running the following
script with your client id and secret:

    use Net::Google::Analytics::OAuth2;

    my $oauth = Net::Google::Analytics::OAuth2->new(
        client_id     => 'Your client id',
        client_secret => 'Your client secret',
    );

    $oauth->interactive;

The script will display a URL and prompt for a code. Visit the URL in a
browser and follow the directions to grant access to your application. You will
be shown the code that you should enter in the Perl script. Then the script
retrieves and prints a refresh token which can be used for non-interactive
access.

=head2 Find your GA4 Property Id

Every request you make to the API needs to contain a property Id. To find yours,
visit L<https://analytics.google.com/> then go to C<< admin :: property :: property settings >>,
then copy the property id.

B<NOTE>: The GA4 property id is I<completely numeric>. If you see a property id starting with 'UA-', you're viewing the old "universal analytics", which doesn't work anymore.

=head2 Make sure everything is ok

To try out your new credentials, you can run the following code:

    use Net::Google::Analytics;
    use Net::Google::Analytics::OAuth2;

    my $client_id     = 'put your client id here';
    my $client_secret = 'put your client secret here';
    my $token_id      = 'put your access token here';
    my $property_id   = 'put your property id here';

    my $oauth = Net::Google::Analytics::OAuth2->new(
        client_id     => $client_id,
        client_secret => $client_secret,
    );

    my $ga4 = Net::Google::Analytics->new(
        token => $oauth->refresh_access_token($token_id)
    );

    my $req = $ga4->new_request(
        property_id => $property_id,
        dimensions  => [{ name => 'sessionSource'   }],
        metrics     => [{ name => 'screenPageViews' }],
        limit       => 3,
    );

    my $res = $ga4->run_report($req);
    foreach my $row ($res->rows) {
        say $row->get_session_source . ' => ' . $row->get_screen_page_views;
    }

If all went well, the program above ran without errors and showed your
application's top 3 session sources for screen page views. If you got no output,
maybe you just haven't had any views on that property id.

But if you got an error, please make sure you have followed the steps above and
replaced in the code your client_id, client_secret token and property id.

=head1 CONSTRUCTOR

=head2 new

    my $analytics = Net::Google::Analytics->new;

The constructor may optionally contain a C<token> argument:

    my $analytics = Net::Google::Analytics->new( token => $my_token );

Which is just a shortcut to C<< ->new->token($token) >>.

=head1 METHODS

=head2 token

    $analytics->token($token);

Authenticate using a token returned from L<Net::Google::Analytics::OAuth2>.
Returns the object itself to allow method chaining.

=head2 new_request

    my $req = $analytics->new_request( param => $value, ... );

Creates and returns a new L<Net::Google::Analytics::Request> object.

Available parameters are the same as L<the official API|https://developers.google.com/analytics/devguides/reporting/data/v1/rest/v1beta/properties/runReport>, but in
lower case with underscores ('snake_case') instead of camelCase.

=head2 run_report

    my $res = $analytics->run_report( $req );

Sends the request, which must be a L<Net::Google::Analytics::Request> object.
This method returns a L<Net::Google::Analytics::Response> object.

=head2 batch_run_reports

    my $res = $analytics->batch_run_reports( $req1, $req2, ... );
    my $res = $analytics->batch_run_reports( \@requests );

Receives a list or an array reference of L<Net::Google::Analytics::Request>
objects, and sends them as a single request to the API instead of hitting it
with every request.

Returns an array reference of L<Net::Google::Analytics::Response> objects,
one for each request, in the same order.

B<NOTE>: batch requests must all refer to the same property id, and are
limited to 5 requests at most.
