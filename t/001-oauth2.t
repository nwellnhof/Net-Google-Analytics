use strict;
use warnings;
use Test::More tests => 17;

my $post_form;

use Net::Google::Analytics::OAuth2;
pass 'Net::Google::Analytics::OAuth2 loaded successfully';

ok my $oauth = Net::Google::Analytics::OAuth2->new(
    client_id     => 'test_client_id',
    client_secret => 'test_client_secret',
), 'able to instantiate OAuth class';

isa_ok $oauth, 'Net::Google::Analytics::OAuth2';

is(
    $oauth->authorize_url,
    'https://accounts.google.com/o/oauth2/auth?response_type=code&client_id=test_client_id&redirect_uri=urn%3Aietf%3Awg%3Aoauth%3A2.0%3Aoob&scope=https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fanalytics.readonly',
    'oauth authorization url'
);

$oauth = Net::Google::Analytics::OAuth2->new(
    client_id     => 'test_client_id',
    client_secret => 'test_client_secret',
);

require HTTP::Tiny;
{ no warnings 'redefine', 'once';
  *HTTP::Tiny::post_form = sub {
    my ($self, @args) = @_;
    $post_form = \@args;
    return {
        success => 1,
        status  => 200,
        reason  => 'OK',
        content => '{"access_token":1234,"refresh_token":4321}',
    };
  };
}

my $res = $oauth->get_access_token('my_authorization_code');
is_deeply($res, { access_token => 1234, refresh_token => 4321 }, 'mock access token received');
is $post_form->[0], 'https://accounts.google.com/o/oauth2/token', 'sending to the proper endpoint';
my %submission = @{ $post_form->[1] };
is $submission{code}, 'my_authorization_code', 'got authorization code';
is $submission{client_id}, 'test_client_id', 'got client id';
is $submission{client_secret}, 'test_client_secret', 'got client secret';
is $submission{redirect_uri}, 'urn:ietf:wg:oauth:2.0:oob', 'got default redirect uri';
is $submission{grant_type}, 'authorization_code', 'got authorization code as grant type';

undef $post_form;
undef $res;

$res = $oauth->refresh_access_token('my_refresh_token');
is_deeply($res, { access_token => 1234, refresh_token => 4321 }, 'mock refresh token received');
is $post_form->[0], 'https://accounts.google.com/o/oauth2/token', 'sending to the proper endpoint (refresh token)';
%submission = @{ $post_form->[1] };
is $submission{refresh_token}, 'my_refresh_token', 'got refresh token';
is $submission{client_id}, 'test_client_id', 'got client id (refresh token)';
is $submission{client_secret}, 'test_client_secret', 'got client secret (refresh token)';
is $submission{grant_type}, 'refresh_token', 'got refresh_token as grant type';
