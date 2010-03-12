package Net::Google::Analytics::Feed;
use strict;

use base qw(Class::Accessor);

use LWP::UserAgent;
use URI;
use XML::LibXML;

my $parser = XML::LibXML->new();
my $xpc = XML::LibXML::XPathContext->new();
$xpc->registerNs(atom => 'http://www.w3.org/2005/Atom');
$xpc->registerNs(dxp  => 'http://schemas.google.com/analytics/2009');

__PACKAGE__->mk_accessors(qw(auth_params ua));

sub new {
    my $package = shift;

    return bless({}, $package);
}

sub user_agent {
    my $self = $_[0];

    my $ua = $self->{ua};

    if(@_ > 1) {
        $self->{ua} = $_[1];
    }
    elsif(!defined($ua)) {
        $ua = LWP::User::Agent->new();
        $self->{ua} = $ua;
    }

    return $ua;
}

sub retrieve {
    my ($self, $request) = @_;

    my $res;
    my @entries;
    
    my $ua = $self->ua;
    if(!defined($ua)) {
        $ua = LWP::UserAgent->new();
        $self->ua($ua);
    }

    my $uri = URI->new($self->base_url);
    my $params = $request->params;
    my $headers = $self->auth_params;

    my $start_index = $request->start_index;
    $start_index = 1 if !defined($start_index);
    my $remaining_results = $request->max_results;
    my $max_items_per_page = $self->max_items_per_page;

    while(!defined($remaining_results) || $remaining_results > 0) {
        my $max_results =
            defined($remaining_results) &&
            $remaining_results < $max_items_per_page ?
                $remaining_results : $max_items_per_page;
        $uri->query_form(
            %$params,
            'start-index' => $start_index,
            'max-results' => $max_results,
        );

        print($uri->as_string, "\n");
        my $page_res = $self->ua->get($uri->as_string, @$headers);

        if(!$page_res->is_success) {
            my $status = $page_res->status_line;
            die("Analytics API request failed: $status\n");
        }

        my $doc = $parser->parse_string($page_res->content);
        my $feed_node = $xpc->findnodes('/atom:feed', $doc)->get_node(1);
        my $entry_count = 0;

        if(!defined($res)) {
            $res = $self->parse_feed($feed_node);
        }

        for my $entry_node ($xpc->findnodes('atom:entry', $feed_node)) {
            my $entry = $self->parse_entry($entry_node);
            push(@entries, $entry);
            ++$entry_count;
        }

        last if $entry_count < $max_results;

        $remaining_results -= $max_results if defined($remaining_results);
        $start_index       += $max_results;
    }

    $res->entries(\@entries);
}

1;

