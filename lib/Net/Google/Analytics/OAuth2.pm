package Net::Google::Analytics::OAuth2;
use strict;

# ABSTRACT: OAuth2 for Google Analytics API

use JSON;
use LWP::UserAgent;
use URI;

sub new {
    my $class = shift;
    my $self  = { @_ };

    die("client_id missing")     if !$self->{client_id};
    die("client_secret missing") if !$self->{client_secret};

    $self->{redirect_uri} ||= 'urn:ietf:wg:oauth:2.0:oob';

    return bless($self, $class);
}

sub authorize_url {
    my $self = shift;

    my $uri = URI->new('https://accounts.google.com/o/oauth2/auth');
    $uri->query_form(
        response_type => 'code',
        client_id     => $self->{client_id},
        redirect_uri  => $self->{redirect_uri},
        scope         => 'https://www.googleapis.com/auth/analytics.readonly',
    );

    return $uri->as_string;
}

sub get_access_token {
    my ($self, $code) = @_;

    my $ua  = LWP::UserAgent->new;
    my $res = $ua->post('https://accounts.google.com/o/oauth2/token', [
        code          => $code,
        client_id     => $self->{client_id},
        client_secret => $self->{client_secret},
        redirect_uri  => $self->{redirect_uri},
        grant_type    => 'authorization_code',
    ]);

    die('error getting token: ' . $res->status_line) unless $res->is_success;

    return from_json($res->decoded_content);
}

sub refresh_access_token {
    my ($self, $refresh_token) = @_;

    my $ua = LWP::UserAgent->new;
    my $res = $ua->post('https://accounts.google.com/o/oauth2/token', [
        refresh_token => $refresh_token,
        client_id     => $self->{client_id},
        client_secret => $self->{client_secret},
        grant_type    => 'refresh_token',
    ]);

    die('error getting token: ' . $res->status_line) unless $res->is_success;

    return from_json($res->decoded_content);
}

sub interactive {
    my $self = shift;

    my $url = $self->authorize_url;

    print(<<"EOF");
Please visit the following URL, grant access to this application, and enter
the code you will be shown:

$url

EOF

    print("Enter code: ");
    my $code = <STDIN>;
    chomp($code);

    print("\nUsing code: $code\n\n");

    my $res = $self->get_access_token($code);

    print("Access token:  ", $res->{access_token},  "\n");
    print("Refresh token: ", $res->{refresh_token}, "\n");
}

1;

