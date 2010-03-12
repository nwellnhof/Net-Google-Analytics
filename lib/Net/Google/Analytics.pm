package Net::Google::Analytics;
use strict;

use base qw(Class::Accessor);

use Net::Google::Analytics::DataFeed;

__PACKAGE__->mk_accessors(qw(data_feed));

sub new {
    my $package = shift;

    my $self = bless({}, $package);
    $self->data_feed(Net::Google::Analytics::DataFeed->new());

    return $self;
}

sub auth_params {
    my $self = shift;

    my $auth_params = [ @_ ];
    $self->data_feed->auth_params($auth_params);
}

sub user_agent {
    my ($self, $ua) = @_;

    $self->data_feed->user_agent($ua);
}

1;

__END__

=head1 NAME

Net::Google::Analytics - Simple interface to the Google Analytics API

=head1 DESCRIPTION

=head1 SYNOPSIS

 use Net::Google::Analytics;
 use Net::Google::AuthSub;

 my $auth = Net::Google::AuthSub->new();
 $auth->login($user, $pass);

 my $analytics = Net::Google::Analytics->new();
 $analytics->auth_params($auth->auth_params);

 my $data_feed = $analytics->data_feed;
 my $req = $data_feed->new_request();
 $req->dimensions('');
 $req->metrics('');
 $req->start_date('YYYY-MM-DD');
 $req->end_date('YYYY-MM-DD');
 my $res = $data_feed->retrieve($req);

 my $entry = $res->entries->[$i];
 print $entry->dimensions->[0]->value;
 print $entry->metrics->[0]->value;

=head1 CONSTRUCTOR

