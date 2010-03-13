package Net::Google::Analytics::Feed;
use strict;

use base qw(Class::Accessor Net::Google::Analytics::XML);

use URI;

__PACKAGE__->mk_accessors(qw(_analytics));

sub new {
    my $package = shift;

    return bless({}, $package);
}

sub retrieve {
    my ($self, $request) = @_;

    my $res;
    my @entries;
    
    my $ua = $self->_analytics->user_agent;
    my $xpc = $self->_xpc;

    my $uri = URI->new($self->_base_url);
    my @params = $request->_params;
    my @headers = (
        'GData-Version' => 2,
        $self->_analytics->auth_params,
    );

    my $start_index = $request->start_index;
    $start_index = 1 if !defined($start_index);
    my $remaining_results = $request->max_results;
    my $max_items_per_page = $self->_max_items_per_page;

    while(!defined($remaining_results) || $remaining_results > 0) {
        my $max_results =
            defined($remaining_results) &&
            $remaining_results < $max_items_per_page ?
                $remaining_results : $max_items_per_page;
        $uri->query_form(
            @params,
            'start-index' => $start_index,
            'max-results' => $max_results,
            'prettyprint' => 'true',
        );

        print($uri->as_string, "\n");
        my $page_res = $ua->get($uri->as_string, @headers);

        if(!$page_res->is_success) {
            my $status = $page_res->status_line;
            die("Analytics API request failed: $status\n");
        }

        my $doc = $self->_parser->parse_string($page_res->content);
        my $feed_node = $xpc->findnodes('/atom:feed', $doc)->get_node(1);
        my $entry_count = 0;

        if(!defined($res)) {
            $res = $self->_new_response();
            $res->_parse_feed($feed_node);
        }

        for my $entry_node ($xpc->findnodes('atom:entry', $feed_node)) {
            $res->_parse_entry($entry_node);
            ++$entry_count;
        }

        last if $entry_count < $max_results;

        $remaining_results -= $max_results if defined($remaining_results);
        $start_index       += $max_results;
    }

    return $res;
}

1;

__END__

=head1 NAME

Net::Google::Analytics::Feed - Google Analytics API feed

=head1 DESCRIPTION

This is a base class for the feeds of the Google Analytics Data Export API.
Account feeds are implemented in L<Net::Google::Analytics::AccountFeed>.
Data feeds are implemented in L<Net::Google::Analytics::DataFeed>.

See <http://code.google.com/apis/analytics/docs/gdata/gdataReference.html>.

=head1 METHODS

=head2 new_request

 my $req = $feed->new_request();

Creates and returns a new L<Net::Google::Analytics::FeedRequest> object
for this feed.

=head2 retrieve

 my $res = $feed->retrieve($req);

Retrieves data from the feed. $req is a
L<Net::Google::Analytics::FeedRequest> object. You should use a request
object returned from the L</new_request> method. This method returns a
L<Net::Google::Analytics::FeedResponse> object.

=cut

