package Net::Google::Analytics;
use strict;

use base qw(Class::Accessor);

use LWP::UserAgent;
use Net::Google::Analytics::AccountFeed;
use Net::Google::Analytics::DataFeed;

__PACKAGE__->mk_accessors(qw(account_feed data_feed));

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

sub finish {
    my $self = shift;

    $self->account_feed(undef);
    $self->data_feed   (undef);
}

sub auth_params {
    my $self = shift;

    my $auth_params = $self->{auth_params} || [];

    if(@_) {
        $self->{auth_params} = [ @_ ];
    }

    return @$auth_params;
}

sub user_agent {
    my $self = $_[0];

    my $ua = $self->{user_agent};

    if(@_ > 1) {
        $self->{user_agent} = $_[1];
    }
    elsif(!defined($ua)) {
        $ua = LWP::UserAgent->new();
        $self->{user_agent} = $ua;
    }

    return $ua;
}

1;

__END__

=head1 NAME

Net::Google::Analytics - Simple interface to the Google Analytics Data Export API

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
 $req->dimensions('ga:...');
 $req->metrics('ga:...');
 $req->start_date('YYYY-MM-DD');
 $req->end_date('YYYY-MM-DD');
 my $res = $data_feed->retrieve($req);

 my $entry = $res->entries->[$i];
 print $entry->dimensions->[0]->value;
 print $entry->metrics->[0]->value;

 $analytics->finish();

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

=head1 METHODS

=head2 finish

 $analytics->finish();

Cleans up circular references between the $analytics object and the feeds.
This should be called to make sure the object is destroyed after use.

=head2 auth_params

 $analytics->auth_params(@auth_params);

Set the authentication parameters as key/value pairs. The values returned
from L<Net::Google::AuthSub/auth_params> can be used directly.

=head2 user_agent

 $analytics->user_agent($ua);

Sets the L<LWP::UserAgent> object to use for HTTP(S) requests. You only
have to call this method if you want to provide your own user agent, e.g.
to change the HTTP user agent header.

=head1 AUTHOR

Nick Wellnhofer <wellnhofer@aevum.de>

=head1 COPYRIGHT AND LICENSE

Copyright (C) Nick Wellnhofer, 2010

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.0 or,
at your option, any later version of Perl 5 you may have available.

=cut

