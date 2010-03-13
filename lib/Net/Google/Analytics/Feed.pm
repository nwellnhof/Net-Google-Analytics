package Net::Google::Analytics::Feed;
use strict;

use base qw(Class::Accessor);

use LWP::UserAgent;
use URI;
use XML::LibXML;

our $parser = XML::LibXML->new();
our $xpc = XML::LibXML::XPathContext->new();
$xpc->registerNs(atom       => 'http://www.w3.org/2005/Atom');
$xpc->registerNs(dxp        => 'http://schemas.google.com/analytics/2009');
$xpc->registerNs(openSearch => 'http://a9.com/-/spec/opensearch/1.1/');

__PACKAGE__->mk_accessors(qw(auth_params));

sub new {
    my $package = shift;

    return bless({}, $package);
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

sub retrieve {
    my ($self, $request) = @_;

    my $res;
    my @entries;
    
    my $uri = URI->new($self->base_url);
    my $params = $request->params;
    my @headers = (
        'GData-Version' => 2,
        @{ $self->auth_params },
    );

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
            'prettyprint' => 'true',
        );

        print($uri->as_string, "\n");
        my $page_res = $self->user_agent->get($uri->as_string, @headers);

        if(!$page_res->is_success) {
            my $status = $page_res->status_line;
            die("Analytics API request failed: $status\n");
        }

        my $doc = $parser->parse_string($page_res->content);
        my $feed_node = $xpc->findnodes('/atom:feed', $doc)->get_node(1);
        my $entry_count = 0;

        if(!defined($res)) {
            $res = $self->new_response();
            $res->parse_feed($feed_node);
        }

        for my $entry_node ($xpc->findnodes('atom:entry', $feed_node)) {
            $res->parse_entry($entry_node);
            ++$entry_count;
        }

        last if $entry_count < $max_results;

        $remaining_results -= $max_results if defined($remaining_results);
        $start_index       += $max_results;
    }

    return $res;
}

1;

