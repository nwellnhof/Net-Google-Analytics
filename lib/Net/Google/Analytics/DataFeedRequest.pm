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

sub params {
    my $self = shift;

    my $params = $self->SUPER::params();
    
    for(my $i=0; $i<@param_map; $i+=2) {
        my $from = $param_map[$i];
        my $to   = $param_map[$i+1];
        $params->{$to} = $self->{$from};
    }

    return $params;
}

1;

