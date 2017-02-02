package YeahYeahYeahmail;

use Modern::Perl;
use experimental 'signatures';
use Email::Valid;

our $VERSION = 0.01;

# Constructor.
sub new ($class, %attrs) {
    my $self = {
        filename  => $attrs{filename},
        addresses => []
    };
    return bless $self, $class;
}

# Filename getter / setter.
sub filename ($self, $filename = undef) {
    if (defined $filename) {
        $self->{filename} = $filename;
    }
    return $self->{filename};
}

# Addresses getter / setter.
sub addresses ($self, $addresses = undef) {
    if (defined $addresses and ref $addresses eq 'ARRAY') {
        $self->{addresses} = $addresses;
    }
    return $self->{addresses};
}

# File readability test.
sub can_read_from_file ($self) {
    return (-e -f -r $self->filename);
}

# Maybe set $self->addresses from $self->filename. Return the number of email
# addresses found in a given file.
sub read_addresses_from_file ($self) {
    return 0 unless $self->can_read_from_file;

    # Even if file readability guaranteed by previous check, it's better safe
    # than sorry.
    open my $fh, '<', $self->filename or return 0;

    my @addresses;
    while (my $address = readline($fh)) {
        chomp $address;
        push @addresses, $address;
    }
    close $fh;
    $self->addresses(\@addresses);
    return scalar @addresses;
}

# Return array of domains sorted by popularity. If an email address doesn't look
# good, then it goes to 'INVALID' domain.
sub domains ($self) {
    # Collect statistics.
    my %stats = (INVALID => 0);
    for my $address (@{$self->addresses}) {
        unless (Email::Valid->address($address)) {
            $stats{INVALID} += 1;
            next;
        }
        # Email looks good. Cut domain name from it.
        # How regex ninjas do that:
        # http://stackoverflow.com/questions/10306690/domain-name-validation-with-regex
        $address =~ m/@([a-z0-9.-]+)$/i;
        my $domain_name = lc $1;
        $stats{$domain_name} += 1;
    }

    # Convert statistics to domains.
    my @domains = map {
        {
            name       => $_,
            popularity => $stats{$_}
        }
    } keys %stats;

    # And don't forget to sort.
    @domains = sort {
        # 'INVALID' domain: it always comes last.
        if ($a->{name} eq 'INVALID') {
            1;
        }
        elsif ($b->{name} eq 'INVALID') {
            -1;
        }
        # Normal domains.
        else {
            $b->{popularity} <=> $a->{popularity}
        }
    } @domains;

    return @domains;
}

1;

=encoding utf8

=head1 NAME

YeahYeahYeahmail -- Perl class to find popular email domains

=head1 SYNOPSIS

    use YeahYeahYeahmail;

    my $yyym = YeahYeahYeahmail->new(filename => 'addresses.txt');

    if ($yyym->read_addresses_from_file) {
        for my $domain ($yyym->domains) {
            say "$domain->{name} $domain->{popularity}";
        }
    }

=head1 DESCRIPTION

YeahYeahYeahmail takes a filename and produces a list of email domains sorted by
popularity.

=head1 ATTRIBUTES

YeahYeahYeahmail implements two attributes.

=head2 filename

    my $filename_old = $yyym->filename;
    my $filename_new = $yyym->filename('addresses.txt');

The name of the file to read from.

=head2 addresses

    my $addresses_old = $yyym->addresses;
    my $addresses_new = $yyym->addresses([
        'a@a.com',
        'b@a.com',
        'c@a.com',
    ]);

Reference to the array of email addresses.

=head1 METHODS

YeahYeahYeahmail implements the following methods.

=head2 new

    my $yyym = YeahYeahYeahmail->new(filename => 'addresses.txt');

Construct a new YeahYeahYeahmail object and set initial filename attribute.

=head2 can_read_from_file

    my $bool = $yyym->can_read_from_file;

Check if filename is readable.

=head2 read_addresses_from_file

    my $int = $yyym->read_addresses_from_file;

Maybe set addresses attribute. Return the number of email addresses found in
a given file.

=head2 domains

    my @domains              = $yyym->domains;
    my $most_popular_domain  = $domains[0];
    my $least_popular_domain = $domains[-1];

Get email domains sorted by popularity.

=head1 DEPENDENCIES

=over 2

=item Modern::Perl

=item Email::Valid

=back

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2017, Ev Bogdanov
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

* Neither the name of the copyright holder nor the names of its
  contributors may be used to endorse or promote products derived from
  this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=cut
