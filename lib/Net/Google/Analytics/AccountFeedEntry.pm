package Net::Google::Analytics::AccountFeedEntry;
use strict;

use base qw(Class::Accessor Net::Google::Analytics::XML);

my @property_map = (
    account_id      => 'accountId',
    account_name    => 'accountName',
    profile_id      => 'profileId',
    web_property_id => 'webPropertyId',
    currency        => 'currency',
    timezone        => 'timezone',
);

__PACKAGE__->mk_accessors(qw(
    account_id account_name profile_id web_property_id currency timezone
    table_id
));

sub _parse {
    my ($package, $node) = @_;

    my $self = {};
    my $xpc = $package->_xpc;

    for (my $i=0; $i<@property_map; $i+=2) {
        my $from = $property_map[$i+1];
        my $to   = $property_map[$i];

        $self->{$to} = $xpc->findvalue(
            "dxp:property[\@name='ga:$from']/\@value",
            $node
        );
    }

    $self->{table_id} = $node->findvalue('dxp:tableId');

    return bless($self, $package);
}

1;

__END__

=head1 NAME

Net::Google::Analytics::AccountFeedEntry - Google Analytics API account feed
entry

=head1 DESCRIPTION

This package implements account feed entries of the Google Analytics Data
Export API.

=head1 ACCESSORS

=head2 account_id

=head2 account_name

=head2 profile_id

=head2 web_property_id

=head2 currency

=head2 timezone

=head2 table_id

=head1 AUTHOR

Nick Wellnhofer <wellnhofer@aevum.de>

=head1 COPYRIGHT AND LICENSE

Copyright (C) Nick Wellnhofer, 2010

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.0 or,
at your option, any later version of Perl 5 you may have available.

=cut

