package DateTime::TimeAgo;

use strict;
use utf8;
use DateTime;
use DateTime::Duration;
use UNIVERSAL qw(isa);
use Carp;
use Exporter qw(import);
use integer;

our @EXPORT_OK = qw(time_ago);

our $VERSION = '0.01';

sub time_ago {
    my ($time, $now) = @_;
    
    if (not defined $time or not isa($time, 'DateTime')) {
        croak('DateTime::TimeAgo::time_ago needs a DateTime object as first parameter')
    }
    if (not defined $now) {
        $now = get_datetime_from_timestamp(time);
    }
    if (not isa($now, 'DateTime')) {
        croak('Invalid second parameter provided to DateTime::TimeAgo::time_ago; it must be a DateTime object if provided')
    }
    
    if (DateTime->compare($time, $now) > 0) {
        return 'in the future'
    }
    
    my $Δ = $now - $time;
    
    if ($Δ->in_units('minutes') < 1) {
        return 'just now'
    }
    
    if ($Δ->in_units('minutes') < 15) {
        return 'a few minutes ago'
    }
    
    if ($Δ->in_units('minutes') < 50) {
        return 'less than an hour ago'
    }
    
    if ($Δ->in_units('minutes') < 75) {
        return 'about an hour ago'
    }
    
    if ($Δ->in_units('hours') < 2) {
        return 'more than an hour ago'
    }
    
    if ($Δ->in_units('hours') < 6) {
        return 'several hours ago'
    }
    
    if ($Δ->in_units('days') < 2 and $time->day == $now->day) {
        if ($time->hour < 5) {
            return 'tonight'
        }
        if ($time->hour < 10) {
            return 'this morning'
        }
        if ($time->hour < 15) {
            return 'today'
        }
        if ($time->hour < 19) {
            return 'this afternoon'
        }
        # this should actually never happen
        return 'this evening'
    }
    
    my $yesterday = $now - DateTime::Duration->new(days => 1);
    if ($time->ymd eq $yesterday->ymd) {
        return 'yesterday'
    }
    
    if ($Δ->in_units('days') < 14 and $time->week_number == $now->week_number) {
        return 'this week'
    }
    
    my $last_week = $now - DateTime::Duration->new(days => 7);
    if ($Δ->in_units('days') < 21 and $time->week_number == $last_week->week_number) {
        return 'last week'
    }
    
    if ($time->year == $now->year and $time->month == $now->month) {
        return 'this month'
    }
    
    my $last_month = $now - DateTime::Duration->new(months => 1);
    if ($Δ->in_units('months') < 3 and $time->month == $last_month->month) {
        return 'last month'
    }
    
    if ($time->year == $now->year) {
        return 'this year'
    }
    
    if ($time->year == $now->year - 1) {
        return 'last year'
    }
    
    if ($Δ->in_units('years') < 2) {
        return 'more than a year ago'
    }
    
    if ($Δ->in_units('years') < 9) {
        return 'several years ago'
    }
    
    if ($Δ->in_units('years') < 12) {
        return 'about a decade ago'
    }
    
    if ($time->year / 10 == $now->year / 10 - 1) {
        return 'last decade'
    }
    
    if ($Δ->in_units('years') < 90) {
        return 'several decades ago'
    }
    
    if ($Δ->in_units('years') < 120) {
        return 'about a century ago'
    }
    
    if ($time->year / 100 == $now->year / 100 - 1) {
        return 'last century'
    }
    
    if ($Δ->in_units('years') < 200) {
        return 'more than a century ago'
    }
    
    if ($Δ->in_units('years') < 900) {
        return 'several centuries ago'
    }
    
    if ($Δ->in_units('years') < 1200) {
        return 'about a millenium ago'
    }
    
    if ($Δ->in_units('years') < 2000) {
        return 'more than a millenium ago'
    }
    
    return 'millenia ago'
}

sub get_datetime_from_timestamp {
    my ($time) = @_;
    my %d;
    @d{qw(second minute hour day month year)} = localtime($time);
    $d{year} += 1900;
    $d{month} += 1;
    return DateTime->new(%d)
}

1

__END__

=head1 NAME

DateTime::TimeAgo -- express dates as fuzzy human-friendly strings

=head1 SYNOPSIS

 use DateTime::TimeAgo qw(time_ago);
 use DateTime;
 
 my $now = DateTime->new(
    year => 2010, month => 12, day => 12,
    hour => 19, minute => 59,
 );
 my $then = DateTime->new(
    year => 2010, month => 12, day => 12
    hour => 15,
 );
 print time_ago($then, $now);
 # outputs 'several hours ago'
 
 print time_ago($then);
 # $now taken from C<time> function
 
 my $DateTime_object = DateTime::TimeAgo::get_datetime_from_timestamp(time);

=head1 DESCRIPTION

DateTime::TimeAgo is inspired from the timeAgo jQuery module
L<http://timeago.yarp.com/>.

It takes two DateTime objects -- first one representing a moment in the past
and second optional one representine the present, and returns a human-friendly
fuzzy expression of the time gone.

=head2 functions

=over 4

=item time_ago($then, $now)

The only exportable function.

First obligatory parameter is a DateTime object.

Second optional parameter is also a DateTime object.
If it's not provided, then I<now> as the C<time> function returns is
substituted.

Returns a string expression of the interval between the two DateTime
objects, like C<several hours ago>, C<yesterday> or <last century>.

=item get_datetime_from_timestamp($unix_timestamp);

Not exportable.

Returns a DateTime object based on the provided timestamp, as returned
by the C<time> function.

=back

=head1 AUTHOR

Jan Oldrich Kruza, C<< <sixtase at cpan.org> >>

=head1 LICENSE AND COPYRIGHT

Copyright 2010 Jan Oldrich Kruza.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut
