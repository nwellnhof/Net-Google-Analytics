package Net::Google::Analytics;
use strict;

# ABSTRACT: Simple interface to the Google Analytics Core Reporting API

use base qw(Class::Accessor);

use JSON;
use LWP::UserAgent;
use Net::Google::Analytics::Request;
use Net::Google::Analytics::Response;
use Net::Google::Analytics::Row;
use Scalar::Util;
use URI;

__PACKAGE__->mk_accessors(qw(terminal));

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

    my $uri = $self->_uri($req, $start_index, $max_results);
    my @auth_params = $self->auth_params;
    my $terminal = $self->terminal;

    if (!@auth_params && $terminal) {
        @auth_params = $terminal->auth_params('analytics');
        $self->auth_params(@auth_params);
    }

    my $http_res;

    while (1) {
        $http_res = $self->user_agent->get($uri->as_string,
            'GData-Version' => 2,
            @auth_params,
        );
        last if
            $http_res->is_success ||
            $http_res->code ne '401' ||
            !$terminal;

        @auth_params = $terminal->new_auth_params('analytics',
            error => $http_res->message,
        );
        $self->auth_params(@auth_params);
    }

    return $http_res;
}

sub retrieve_http {
    my ($self, $req) = @_;

    return $self->_retrieve_http($req, $req->start_index, $req->max_results);
}

sub _retrieve {
    my ($self, $req, $start_index, $max_results) = @_;

    my $http_res = $self->_retrieve_http($req, $start_index, $max_results);
    my $res = Net::Google::Analytics::Response->new;

    if (!$http_res->is_success) {
        $res->code($http_res->code);
        $res->message($http_res->message);

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
            push(@{ $res->entries }, @{ $page->entries });
        }

        my $items_per_page = $page->items_per_page;
        last if $items_per_page < $max_results;

        $remaining_items -= $items_per_page if defined($remaining_items);
        $start_index     += $items_per_page;
    }

    $res->items_per_page(scalar(@{ $res->entries }));

    return $res;
}

1;

__END__

=head1 DESCRIPTION

This module provides a simple, straight-forward interface to the Google
Analytics Data Export API, using L<LWP::UserAgent> and L<XML::LibXML> for
the heavy lifting.

See
L<http://code.google.com/apis/analytics/docs/gdata/gdataDeveloperGuide.html>
for the complete API documentation.

=head1 SYNOPSIS

    use Net::Google::Analytics;
    use Net::Google::AuthSub;

    my $auth = Net::Google::AuthSub->new(service => 'analytics');
    $auth->login($user, $pass);

    my $analytics = Net::Google::Analytics->new();
    $analytics->auth_params($auth->auth_params);

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

    for my $entry (@{ $res->entries }) {
        my $dimensions = $entry->dimensions;
        my $metrics    = $entry->metrics;
        print
            "year ",    $dimensions->[0]->value, ", ",
            "month ",   $dimensions->[1]->value, ", ",
            "country ", $dimensions->[2]->value, ": ",
            $metrics->[0]->value, " visits, ",
            $metrics->[1]->value, " pageviews\n";
    }

=head1 GETTING STARTED

Net::Google::Analytics doesn't support authentication by itself. You simply
pass it the HTTP headers needed for authorization using the L<auth_params>
method. See the synopsis for how to quickly create authorization headers with
L<Net::Google::AuthSub> using your username and password. But you can also
authenticate with OAuth.

You have to provide the profile ID of your Analytics profile with every
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

 my $analytics = Net::Google::Analytics->new();

The constructor doesn't take any arguments.

=head1 ACCESSORS

=head2 terminal

Object that implements the following callback methods for interactive
authentication:

=head3 $terminal->auth_params

 my @auth_params = $terminal->auth_params();

This method is called before a request and the result is stored in
auth_params if auth_params has not been sent. It may return cached auth
params.

=head3 $terminal->new_auth_params

 my @auth_params = $terminal->new_auth_params($service, error => $error);

This method is called if a HTTP request returns a 401 status
code. Then auth_params is reset and the HTTP request is retried.

=head1 METHODS

=head2 auth_params

 $analytics->auth_params(@auth_params);

Set the authentication parameters as key/value pairs. The values returned
from L<Net::Google::AuthSub/auth_params> can be used directly.

=head2 user_agent

 $analytics->user_agent($ua);

Sets the L<LWP::UserAgent> object to use for HTTP(S) requests. You only
have to call this method if you want to provide your own user agent, e.g.
to change the HTTP user agent header.

=head2 new_request

 my $req = $analytics->new_request;

Creates and returns a new L<Net::Google::Analytics::Request> object.

=head2 uri

 my $uri = $analytics->uri($req);

Returns the URI of the request. $req is a
L<Net::Google::Analytics::Request> object. This method returns a L<URI>
object.

=head2 retrieve

 my $res = $analytics->retrieve($req);

Sends the request. $req is a
L<Net::Google::Analytics::Request> object. You should use a request
object returned from the L<new_request> method. This method returns a
L<Net::Google::Analytics::Response> object.

=head2 retrieve_xml

 my $res = $analytics->retrieve_xml($req);

Sending the request and returns a JSON object. $req is a
L<Net::Google::Analytics::Request> object.

=head2 retrieve_paged

 my $res = $analytics->retrieve_paged($req);

Works like C<retrieve> but works around the per-request entry limit. This
method concatenates the results of multiple requests if necessary.

=cut

