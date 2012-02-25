package Net::Google::Analytics;
use strict;

# ABSTRACT: Simple interface to the Google Analytics Core Reporting API

use JSON;
use LWP::UserAgent;
use Net::Google::Analytics::Request;
use Net::Google::Analytics::Response;
use Net::Google::Analytics::Row;
use URI;

sub new {
    my $package = shift;

    my $self = bless({}, $package);

    return $self;
}

sub auth_params {
    my $self = shift;

    my $auth_params = $self->{auth_params} || [];

    if (@_) {
        $self->{auth_params} = [ @_ ];
    }

    return @$auth_params;
}

sub token {
    my ($self, $token) = @_;

    $self->{auth_params} = [
        Authorization => "$token->{token_type} $token->{access_token}",
    ];
}

sub user_agent {
    my $self = $_[0];

    my $ua = $self->{user_agent};

    if (@_ > 1) {
        $self->{user_agent} = $_[1];
    }
    elsif (!defined($ua)) {
        $ua = LWP::UserAgent->new();
        $self->{user_agent} = $ua;
    }

    return $ua;
}

sub new_request {
    return Net::Google::Analytics::Request->new;
}

sub _uri {
    my ($self, $req, $start_index, $max_results) = @_;

    my $uri = URI->new('https://www.googleapis.com/analytics/v3/data/ga');
    my @params;
    push(@params, 'start-index' => $start_index) if defined($start_index);
    push(@params, 'max-results' => $max_results) if defined($max_results);

    $uri->query_form(
        $req->_params,
        @params,
    );

    return $uri;
}

sub uri {
    my ($self, $req) = @_;

    return $self->_uri($req, $req->start_index, $req->max_results);
}

sub _retrieve_http {
    my ($self, $req, $start_index, $max_results) = @_;

    my $uri         = $self->_uri($req, $start_index, $max_results);
    my @auth_params = $self->auth_params;

    return $self->user_agent->get($uri->as_string, @auth_params);
}

sub retrieve_http {
    my ($self, $req) = @_;

    return $self->_retrieve_http($req, $req->start_index, $req->max_results);
}

sub _retrieve {
    my ($self, $req, $start_index, $max_results) = @_;

    my $http_res = $self->_retrieve_http($req, $start_index, $max_results);
    my $res = Net::Google::Analytics::Response->new;
    $res->code($http_res->code);
    $res->message($http_res->message);

    if (!$http_res->is_success) {
        $res->content($http_res->decoded_content);
        return $res;
    }

    my $json = from_json($http_res->decoded_content);
    $res->_parse_json($json);

    $res->start_index($start_index);
    $res->is_success(1);

    return $res;
}

sub retrieve {
    my ($self, $req) = @_;

    return $self->_retrieve($req, $req->start_index, $req->max_results);
}

sub retrieve_paged {
    my ($self, $req) = @_;

    my $start_index = $req->start_index;
    $start_index = 1 if !defined($start_index);
    my $remaining_items = $req->max_results;
    my $max_items_per_page = 10_000;
    my $res;

    while (!defined($remaining_items) || $remaining_items > 0) {
        my $max_results =
            defined($remaining_items) &&
            $remaining_items < $max_items_per_page ?
                $remaining_items : $max_items_per_page;

        my $page = $self->_retrieve($req, $start_index, $max_results);

        if (!defined($res)) {
            $res = $page;
        }
        else {
            push(@{ $res->rows }, @{ $page->rows });
        }

        my $items_per_page = $page->items_per_page;
        last if $items_per_page < $max_results;

        $remaining_items -= $items_per_page if defined($remaining_items);
        $start_index     += $items_per_page;
    }

    $res->items_per_page(scalar(@{ $res->rows }));

    return $res;
}

1;

__END__

=head1 DESCRIPTION

This module provides a simple, straight-forward interface to the Google
Analytics Core Reporting API, Version 3.

See L<http://code.google.com/apis/analytics/docs/gdata/home.html>
for the complete API documentation.

=head1 SYNOPSIS

    use Net::Google::Analytics;

    my $analytics = Net::Google::Analytics->new();
    $analytics->auth_params(@auth_params);

    my $req = $analytics->new_request();
    # Insert your numeric Analytics profile ID here. You can find it under
    # profile settings. DO NOT use your account or property ID (UA-nnnnnn).
    $req->ids('ga:1234567'); # your Analytics profile ID
    $req->dimensions('ga:year,ga:month,ga:country');
    $req->metrics('ga:visits,ga:pageviews');
    $req->start_date('2011-01-01');
    $req->end_date('2011-12-31');

    my $res = $analytics->retrieve($req);
    die("GA error: " . $res->status_line) if !$res->is_success;

    for my $row (@{ $res->rows }) {
        print
            "year ",    $row->get_year,    ", ",
            "month ",   $row->get_month,   ", ",
            "country ", $row->get_country, ": ",
            $row->get_visits,    " visits, ",
            $row->get_pageviews, " pageviews\n";
    }

=head1 GETTING STARTED

L<Net::Google::Analytics::OAuth2> provides for easy authentication and
authorization using OAuth 2.0. First, you have to register your application
through the Google APIs Console:

L<https://code.google.com/apis/console/>

You will receive a client id and a client secret for your application in the
APIs Console. For command line testing, you should use "Installed application"
as application type. Then you can get a refresh token for your application
by running the following script with your client id and secret:

    use Net::Google::Analytics::OAuth2;

    my $oauth = Net::Google::Analytics::OAuth2->new(
        client_id     => 'Your client id',
        client_secret => 'Your client secret',
    );

    $oauth->interactive;

The script will display a URL and prompt for a code. Visit the URL in a
browser and follow the directions to grant access to your application. Then
you will be shown the code that you should enter in the Perl script.

You also have to provide the profile ID of your Analytics profile with every
request. You can find this decimal number hidden in the "profile settings"
dialog in Google Analytics. Note that this ID is different from your account or
property ID of the form UA-nnnnnn-n. Prepend your profile ID with "ga:" and
pass it to the "ids" method of the request object.

The "ids", "metrics", "start_date", and "end_date" parameters are required for
every request.

For the exact parameter syntax and a list of supported dimensions and metrics
you should consult the Google API documentation.

=head1 CONSTRUCTOR

=head2 new

    my $analytics = Net::Google::Analytics->new;

The constructor doesn't take any arguments.

=head1 METHODS

=head2 auth_params

    $analytics->auth_params(@auth_params);

Set the authentication parameters as key/value pairs. The values returned
from L<Net::Google::AuthSub/auth_params> can be used directly.

=head2 token

    $analytics->token($token);

Authenticate using a token returned from L<Net::Google::Analytics::OAuth2>.

=head2 new_request

    my $req = $analytics->new_request;

Creates and returns a new L<Net::Google::Analytics::Request> object.

=head2 retrieve

    my $res = $analytics->retrieve($req);

Sends the request. $req should be a L<Net::Google::Analytics::Request>
object. This method returns a L<Net::Google::Analytics::Response> object.

=head2 retrieve_http

    my $res = $analytics->retrieve_http($req);

Sends the request and returns an L<HTTP::Response> object. $req should be a
L<Net::Google::Analytics::Request> object.

=head2 retrieve_paged

    my $res = $analytics->retrieve_paged($req);

Works like C<retrieve> but works around the max-results limit. This
method concatenates the results of multiple requests if necessary.

=head2 uri

    my $uri = $analytics->uri($req);

Returns the URI of the request. $req should be a
L<Net::Google::Analytics::Request> object. This method returns a L<URI>
object.

=head2 user_agent

    $analytics->user_agent($ua);

Sets the L<LWP::UserAgent> object to use for HTTP(S) requests. You only
have to call this method if you want to provide your own user agent, e.g.
to change the HTTP user agent header.

=cut

