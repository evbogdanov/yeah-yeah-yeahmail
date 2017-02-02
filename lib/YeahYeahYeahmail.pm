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

# Maybe set $self->addresses. Return the number of email addresses found
# in a given filename.
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
        # Hot regex ninjas do that:
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
