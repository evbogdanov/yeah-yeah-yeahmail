# yeah_yeah_yeahmail

Find popular email domains.

## Dependencies
```
$ cpanm Modern::Perl
$ cpanm Email::Valid
```

## Usage in Perl code
```perl
use YeahYeahYeahmail;

my $yyym = YeahYeahYeahmail->new(filename => '/path/to/file-with-email-addresses');

if ($yyym->read_addresses_from_file) {
    for my $domain ($yyym->domains) {
        say "$domain->{name} $domain->{popularity}";
    }
}
```

## Usage from the command line
```
$ script/yeah_yeah_yeahmail.pl /path/to/file-with-email-addresses
```

## Examples
```
$ script/yeah_yeah_yeahmail.pl t/invalid_addresses.txt
--------------------------------------------------------------------------------
Email addresses found: 9
--------------------------------------------------------------------------------
INVALID 9
--------------------------------------------------------------------------------

$ script/yeah_yeah_yeahmail.pl t/valid_addresses.txt
--------------------------------------------------------------------------------
Email addresses found: 13
--------------------------------------------------------------------------------
example.com 7
example.org 3
example.example 1
strange.example.com 1
strange-example.com 1
INVALID 0
--------------------------------------------------------------------------------
```

## Testing
```
$ prove -wl t
```
