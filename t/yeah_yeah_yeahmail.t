#!/usr/bin/env perl

use Modern::Perl;
use Test::More;

## WORKING DIRECTORY
## -----------------------------------------------------------------------------

use FindBin;
my $wd = $FindBin::Bin;

## OOP
## -----------------------------------------------------------------------------

BEGIN { use_ok 'YeahYeahYeahmail' }

my $yyym = YeahYeahYeahmail->new(filename => 'addresses1');

isa_ok $yyym, 'YeahYeahYeahmail', 'right class';

## GETTERS AND SETTERS
## -----------------------------------------------------------------------------

is $yyym->filename, 'addresses1', 'right filename getter';

is $yyym->filename('addresses2'), 'addresses2', 'right filename setter';

is $yyym->filename, 'addresses2', 'right filename getter after setter';

is_deeply $yyym->addresses, [], 'right addresses getter';

is_deeply $yyym->addresses(['evb@cpan.org']), ['evb@cpan.org'], 'right addresses setter';

is_deeply $yyym->addresses, ['evb@cpan.org'], 'right addresses getter after setter';

## FILE READABILITY
## -----------------------------------------------------------------------------

ok !$yyym->can_read_from_file, "cannot read file 'addresses2'";

$yyym->filename("$wd/no_addresses.txt");
ok $yyym->can_read_from_file, "can read file '$wd/no_addresses.txt'";

## DOMAINS: NO ADDRESSES
## -----------------------------------------------------------------------------

is $yyym->read_addresses_from_file, 0, 'right number of found addresses';

my @domains1 = $yyym->domains;

is_deeply \@domains1, [{name => 'INVALID', popularity => 0}], 'right domains';

## DOMAINS: INVALID ADDRESSES
## -----------------------------------------------------------------------------

$yyym->filename("$wd/invalid_addresses.txt");

is $yyym->read_addresses_from_file, 9, 'right number of found addresses';

my @domains2 = $yyym->domains;

is_deeply \@domains2, [{name => 'INVALID', popularity => 9}], 'right domains';

## DOMAINS: VALID ADDRESSES
## -----------------------------------------------------------------------------

$yyym->filename("$wd/valid_addresses.txt");

is $yyym->read_addresses_from_file, 13, 'right number of found addresses';

my @domains3 = $yyym->domains;

is $domains3[0]->{name}, 'example.com', 'right name';
is $domains3[0]->{popularity}, 7, 'right popularity';

is $domains3[1]->{name}, 'example.org', 'right name';
is $domains3[1]->{popularity}, 3, 'right popularity';

is $domains3[-1]->{name}, 'INVALID', 'right name';
is $domains3[-1]->{popularity}, 0, 'right popularity';

## DOMAINS: SORTING
## -----------------------------------------------------------------------------

$yyym->addresses([
    'a@a.com',
    'b@a.com',
    'c@a.com',
    'd@b.com',
    'e@b.com',
    'f@c.com',
]);

my $domains_expected = [
    {name => 'a.com',   popularity => 3},
    {name => 'b.com',   popularity => 2},
    {name => 'c.com',   popularity => 1},
    {name => 'INVALID', popularity => 0},
];

my @domains = $yyym->domains();

is_deeply \@domains, $domains_expected, 'right sorting';

done_testing();
