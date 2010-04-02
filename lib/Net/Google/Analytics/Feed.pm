package Net::Google::Analytics::Feed;
use strict;

use base qw(Class::Accessor Net::Google::Analytics::XML);

use Scalar::Util;
use URI;

sub _uri {
    my ($self, $req, $start_index, $max_results) = @_;

    my $uri = URI->new($self->_base_url);
    my @params;
    push(@params, 'start-index' => $start_index) if defined($start_index);
    push(@params, 'max-results' => $max_results) if defined($max_results);

    $uri->query_form(
        $req->_params,
        @params,
        'prettyprint' => 'true',
    );
    
    return $uri;
}

sub _analytics {
    my $self = $_[0];

    my $analytics = $self->{_analytics};

    if (@_ > 1) {
        $self->{_analytics} = $_[1];
        Scalar::Util::weaken($self->{_analytics});
    }

    return $analytics;
}

sub uri {
    my ($self, $req);

    return $self->_uri($req, $req->start_index, $req->max_results);
}

sub _retrieve_http {
    my ($self, $req, $start_index, $max_results) = @_;

    my $uri = $self->_uri($req, $start_index, $max_results);

    return $self->_analytics->user_agent->get($uri->as_string,
        'GData-Version' => 2,
        $self->_analytics->auth_params,
    );
}

sub retrieve_xml {
    my ($self, $req);

    my $http_res = $self->_retrieve_http(
        $req, $req->start_index, $req->max_results
    );

    if (!$http_res->is_success) {
        die('Analytics API request failed: ' . $http_res->status_line);
    }

    return $http_res->content;
}

sub _retrieve {
    my ($self, $req, $start_index, $max_results) = @_;

    my $http_res = $self->_retrieve_http($req, $start_index, $max_results);
    my $res = $self->_new_response();

    if (!$http_res->is_success) {
        $res->code($http_res->code);
        $res->message($http_res->message);

        return $res;
    }

    $res->is_success(1);

    my $doc = $self->_parser->parse_string($http_res->content);
    my $xpc = $self->_xpc;
    my $feed_node = $xpc->findnodes('/atom:feed', $doc)->get_node(1);

    $res->_parse_feed($feed_node);

    for my $entry_node ($xpc->findnodes('atom:entry', $feed_node)) {
        $res->_parse_entry($entry_node);
    }

    $start_index = $xpc->findvalue('openSearch:startIndex', $feed_node)
        if !defined($start_index);
    $res->start_index($start_index);
    $res->items_per_page(scalar(@{ $res->entries }));

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
    my $max_items_per_page = $self->_max_items_per_page;
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

=head1 NAME

Net::Google::Analytics::Feed - Google Analytics API feed

=head1 DESCRIPTION

This is a base class for the feeds of the Google Analytics Data Export API.
Account feeds are implemented in L<Net::Google::Analytics::AccountFeed>.
Data feeds are implemented in L<Net::Google::Analytics::DataFeed>.

See L<http://code.google.com/apis/analytics/docs/gdata/gdataReference.html>.

=head1 METHODS

=head2 new_request

 my $req = $feed->new_request();

Creates and returns a new L<Net::Google::Analytics::FeedRequest> object
for this feed.

=head2 uri

 my $uri = $feed->uri($req);

Returns the URI of the feed. $req is a
L<Net::Google::Analytics::FeedRequest> object. This method returns a L<URI>
object.

=head2 retrieve

 my $res = $feed->retrieve($req);

Retrieves data from the feed. $req is a
L<Net::Google::Analytics::FeedRequest> object. You should use a request
object returned from the L</new_request> method. This method returns a
L<Net::Google::Analytics::FeedResponse> object.

=head2 retrieve_xml

 my $res = $feed->retrieve_xml($req);

Retrieves the raw XML data as string from the feed. $req is a
L<Net::Google::Analytics::FeedRequest> object.

=head2 retrieve_paged

 my $res = $feed->retrieve_paged($req);

Works like C<retrieve> but works around the per-request entry limit. This
method concatenates the results of multiple requests if necessary.

=head1 AUTHOR

Nick Wellnhofer <wellnhofer@aevum.de>

=head1 COPYRIGHT AND LICENSE

Copyright (C) Nick Wellnhofer, 2010

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.0 or,
at your option, any later version of Perl 5 you may have available.

=cut

