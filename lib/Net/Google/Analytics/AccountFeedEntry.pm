package Net::Google::Analytics::AccountFeedEntry;
use strict;

use base qw(Class::Accessor);

__PACKAGE__->mk_accessors(qw(
    account_id account_name profile_id web_property_id currency timezone
    table_id
));

sub new {
    my $package = shift;

    return bless({}, $package);
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

=cut

