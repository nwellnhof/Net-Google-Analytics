package Net::Google::Analytics::XML;
use strict;

use XML::LibXML;

my $parser = XML::LibXML->new();
my $xpc = XML::LibXML::XPathContext->new();
$xpc->registerNs(atom       => 'http://www.w3.org/2005/Atom');
$xpc->registerNs(dxp        => 'http://schemas.google.com/analytics/2009');
$xpc->registerNs(openSearch => 'http://a9.com/-/spec/opensearch/1.1/');

sub _parser {
    return $parser;
}

sub _xpc {
    return $xpc;
}

1;

