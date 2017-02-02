#!/usr/bin/env perl

use Modern::Perl;
use experimental 'signatures';

use FindBin;
BEGIN { unshift @INC, "$FindBin::Bin/../lib" }

use YeahYeahYeahmail;

sub main ($filename) {
    my $yyym = YeahYeahYeahmail->new(filename => $filename);

    die "Cannot read from file: '$filename'"
        unless $yyym->can_read_from_file;

    die 'Email addresses not found'
        unless my $found = $yyym->read_addresses_from_file;

    print_separator();
    say "Email addresses found: $found";
    print_separator();

    for my $domain ($yyym->domains) {
        say "$domain->{name} $domain->{popularity}";
    }
    print_separator();
}

sub print_separator () {
    say '-' x 80;
}

main(@ARGV);
