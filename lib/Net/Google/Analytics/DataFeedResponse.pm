package Net::Google::Analytics::DataFeedResponse;
use strict;

use base qw(Net::Google::Analytics::FeedResponse);

use Net::Google::Analytics::DataFeedEntry;

__PACKAGE__->mk_accessors(qw(aggregates));

sub _parse_feed {
    my ($self, $feed_node) = @_;

    $self->SUPER::_parse_feed($feed_node);

    my @aggregates = map {
        Net::Google::Analytics::Metric->_parse($_);
    } $feed_node->findnodes('dxp:aggregates/dxp:metric');

    $self->aggregates(\@aggregates);
}

sub _parse_entry {
    my ($self, $entry_node) = @_;

    my $entry = Net::Google::Analytics::DataFeedEntry->_parse($entry_node);
    push(@{ $self->entries }, $entry);

    return $entry;
}

sub project {
    my ($self, $projection) = @_;

    # Projected dimensions and the sum of their metrics are collected in
    # hash %proj_metrics. The keys of the hash are the the projected
    # dimension values joined with zero bytes.

    my %proj_metrics;

    for my $entry (@{ $self->entries }) {
        my $metrics = $entry->metrics;
        my @proj_dim_values = $projection->($entry->dimensions);
        my $key = join("\0", @proj_dim_values);

        my $proj_metrics = $proj_metrics{$key};

        if (!$proj_metrics) {
            $proj_metrics{$key} = $metrics;
        }
        else {
            for (my $i=0; $i<@$metrics; ++$i) {
                $proj_metrics->[$i]->value(
                    $proj_metrics->[$i]->value + $metrics->[$i]->value
                );
            }
        }
    }

    # iterate over %proj_metrics and push new entries onto @proj_entries

    my @proj_entries;

    while (my ($key, $metrics) = each(%proj_metrics)) {
        my $entry = Net::Google::Analytics::DataFeedEntry->new();

        my @dimensions = map {
            my $dim = Net::Google::Analytics::Dimension->new();
            $dim->name('projection');
            $dim->value($_);
            $dim;
        } split("\0", $key);

        $entry->dimensions(\@dimensions);
        $entry->metrics($metrics);

        push(@proj_entries, $entry);
    }

    $self->entries(\@proj_entries);
}

1;

__END__

=head1 NAME

Net::Google::Analytics::DataFeedResponse - Google Analytics API data feed
response

=head1 DESCRIPTION

This package is a subclass of L<Net::Google::Analytics::FeedResponse> and
implements parts of the data feed response of the Google Analytics Data
Export API. The entries in the feed response are of type
L<Net::Google::Analytics::DataFeedEntry>.

See
L<http://code.google.com/apis/analytics/docs/gdata/gdataReferenceDataFeed.html#dataResponse>
for a complete reference.

=head1 ACCESSORS

=head2 aggregates

 my $aggregates = $res->aggregates;

Returns an arrayref of L<Net::Google::Analytics::Metric> objects.

=head1 METHODS

=head2 project

 $res->project($projection);
 $res->project(\&projection);
 $res->project(sub { ... });

Projects the dimension values of every entry to a set of new dimension values
using subroutine reference $projection. The metrics of entries that are
mapped to the same dimension values are summed up.

The projection subroutine takes as single argument an arrayref of dimension
objects and must return an array of dimension values.

The following example maps a single dimension of type ga:pagePath to
categories.

 $res->project(sub {
     my $dimensions = shift;
     
     my $page_path = $dimensions->[0]->value;

     return ('flowers') if $page_path =~ m{^/(tulips|roses)};
     return ('fruit')   if $page_path =~ m{^/(apples|oranges)};

     return ('other');
 });

=head1 AUTHOR

Nick Wellnhofer <wellnhofer@aevum.de>

=head1 COPYRIGHT AND LICENSE

Copyright (C) Nick Wellnhofer, 2010

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.0 or,
at your option, any later version of Perl 5 you may have available.

=cut

