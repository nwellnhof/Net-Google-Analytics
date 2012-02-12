package Net::Google::Analytics;
use strict;

# ABSTRACT: Simple interface to the Google Analytics Data Export API

use base qw(Class::Accessor);

use LWP::UserAgent;
use Net::Google::Analytics::AccountFeed;
use Net::Google::Analytics::DataFeed;

__PACKAGE__->mk_accessors(qw(account_feed data_feed terminal));

sub new {
    my $package = shift;

    my $self = bless({}, $package);

    my $account_feed = Net::Google::Analytics::AccountFeed->new();
    $account_feed->_analytics($self);
    $self->account_feed($account_feed);

    my $data_feed = Net::Google::Analytics::DataFeed->new();
    $data_feed->_analytics($self);
    $self->data_feed($data_feed);

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

    my $data_feed = $analytics->data_feed;
    my $req = $data_feed->new_request();
    # Insert your numeric Analytics profile ID here. You can find it under
    # profile settings. DO NOT use your account or property ID (UA-nnnnnn).
    $req->ids('ga:1234567'); # your Analytics profile ID
    $req->dimensions('ga:year,ga:month,ga:country');
    $req->metrics('ga:visits,ga:pageviews');
    $req->start_date('2011-01-01');
    $req->end_date('2011-12-31');

    my $res = $data_feed->retrieve($req);
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

You have to provide the profile ID of your Analytics profile with every data
feed request. You can find this decimal number hidden in the "profile settings"
dialog in Google Analytics. Note that this ID is different from your account or
property ID of the form UA-nnnnnn-n. Prepend your profile ID with "ga:" and
pass it to the "ids" method of the request object.

The "ids", "metrics", "start_date", and "end_date" parameters are required for
every data feed request.

For the exact parameter syntax and a list of supported dimensions and metrics
you should consult the Google API documentation.

=head1 CONSTRUCTOR

=head2 new

 my $analytics = Net::Google::Analytics->new();

The constructor doesn't take any arguments.

=head1 ACCESSORS

=head2 account_feed

The Analytics account feed, an object of type
L<Net::Google::Analytics::AccountFeed>.

=head2 data_feed

The Analytics data feed, an object of type
L<Net::Google::Analytics::DataFeed>.

=head2 terminal

Object that implements the following callback methods for interactive
authentication:

=head3 $terminal->auth_params

 my @auth_params = $terminal->auth_params();

This method is called before a feed request and the result is stored in
auth_params if auth_params has not been sent. It may return cached auth
params.

=head3 $terminal->new_auth_params

 my @auth_params = $terminal->new_auth_params($service, error => $error);

This method is called if a HTTP request for a feed returns a 401 status
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

=cut

