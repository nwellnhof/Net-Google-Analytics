package Net::Google::Analytics::DataFeedRequest;
use strict;

use base qw(Net::Google::Analytics::FeedRequest);

my @param_map = (
    ids        => 'ids',
    dimensions => 'dimensions',
    metrics    => 'metrics',
    sort       => 'sort',
    filters    => 'filters',
    segment    => 'segment',
    start_date => 'start-date',
    end_date   => 'end-date',
);

__PACKAGE__->mk_accessors(qw(
    ids dimensions metrics sort filters segment start_date end_date
));

sub _params {
    my $self = shift;

    my @params = $self->SUPER::_params();
    
    for (my $i=0; $i<@param_map; $i+=2) {
        my $from = $param_map[$i];
        my $to   = $param_map[$i+1];

        my $value = $self->get($from);
        push(@params, $to => $value) if defined($value);
    }

    return @params;
}

1;

__END__

=head1 NAME

Net::Google::Analytics::DataFeedRequest - Google Analytics API data feed
request

=head1 DESCRIPTION

This package is a subclass of L<Net::Google::Analytics::FeedRequest> and
implements data feed requests of the Google Analytics Data Export API.

See
L<http://code.google.com/apis/analytics/docs/gdata/gdataReferenceDataFeed.html#dataRequest>
for a reference.

=head1 ACCESSORS

=head2 ids

=head2 dimensions

=head2 metrics

=head2 sort

=head2 filters

=head2 segment

=head2 start_date

=head2 end_date

 $req->ids('ga:...');
 $req->dimensions('ga:...');

See the API reference for a description of the request parameters. The
provided parameter values must not be URL encoded.

=head1 AUTHOR

Nick Wellnhofer <wellnhofer@aevum.de>

=head1 COPYRIGHT AND LICENSE

Copyright (C) Nick Wellnhofer, 2010

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.0 or,
at your option, any later version of Perl 5 you may have available.

=cut

