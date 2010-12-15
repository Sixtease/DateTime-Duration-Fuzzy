package DateTime::Duration::Fuzzy;

use strict;
use utf8;
use DateTime;
use UNIVERSAL qw(isa);
use Carp;
use Exporter qw(import);
use integer;

our @EXPORT_OK = qw(time_ago);

our $VERSION = '0.03';

sub _cmp { DateTime->compare(@_) }

sub time_ago {
    my ($time, $now) = @_;
    
    if (not defined $time or not isa($time, 'DateTime')) {
        croak('DateTime::Duration::Fuzzy::time_ago needs a DateTime object as first parameter')
    }
    if (not defined $now) {
        $now = DateTime->now();
    }
    if (not isa($now, 'DateTime')) {
        croak('Invalid second parameter provided to DateTime::Duration::Fuzzy::time_ago; it must be a DateTime object if provided')
    }
    
    if (_cmp($time, $now) > 0) {
        return 'in the future'
    }
    
    my $treshold;
    
    $treshold = $now->clone->subtract(minutes => 1);
    if (_cmp($time, $treshold) > 0) {
        return 'just now'
    }
    
    $treshold = $now->clone->subtract(minutes => 15);
    if (_cmp($time, $treshold) > 0) {
        return 'a few minutes ago'
    }
    
    $treshold = $now->clone->subtract(minutes => 50);
    if (_cmp($time, $treshold) > 0) {
        return 'less than an hour ago'
    }
    
    $treshold = $now->clone->subtract(minutes => 75);
    if (_cmp($time, $treshold) > 0) {
        return 'about an hour ago'
    }
    
    $treshold = $now->clone->subtract(hours => 2);
    if (_cmp($time, $treshold) > 0) {
        return 'more than an hour ago'
    }
    
    $treshold = $now->clone->subtract(hours => 6);
    if (_cmp($time, $treshold) > 0) {
        return 'several hours ago'
    }
    
    $treshold = $now->clone->subtract(days => 2);
    if (_cmp($time, $treshold) > 0 and $time->day == $now->day) {
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
    
    my $yesterday = $now->clone->subtract(days => 1);
    if ($time->ymd eq $yesterday->ymd) {
        return 'yesterday'
    }
    
    $treshold = $now->clone->subtract(days => 14);
    if (_cmp($time, $treshold) > 0 and $time->week_number == $now->week_number) {
        return 'this week'
    }
    
    my $last_week = $now->clone->subtract(days => 7);
    $treshold = $now->clone->subtract(days => 21);
    if (_cmp($time, $treshold) > 0 and $time->week_number == $last_week->week_number) {
        return 'last week'
    }
    
    if ($time->year == $now->year and $time->month == $now->month) {
        return 'this month'
    }
    
    my $last_month = $now->clone->subtract(months => 1);
    $treshold = $now->clone->subtract(months => 3);
    if (_cmp($time, $treshold) > 0 and $time->month == $last_month->month) {
        return 'last month'
    }
    
    $treshold = $now->clone->subtract(months => 10);
    if (_cmp($time, $treshold) > 0) {
        return 'several months ago'
    }
    
    $treshold = $now->clone->subtract(months => 14);
    if (_cmp($time, $treshold) > 0) {
        return 'about a year ago'
    }
    
    if ($time->year == $now->year - 1) {
        return 'last year'
    }
    
    $treshold = $now->clone->subtract(years => 2);
    if (_cmp($time, $treshold) > 0) {
        return 'more than a year ago'
    }
    
    $treshold = $now->clone->subtract(years => 9);
    if (_cmp($time, $treshold) > 0) {
        return 'several years ago'
    }
    
    $treshold = $now->clone->subtract(years => 12);
    if (_cmp($time, $treshold) > 0) {
        return 'about a decade ago'
    }
    
    if ($time->year / 10 == $now->year / 10 - 1) {
        return 'last decade'
    }
    
    $treshold = $now->clone->subtract(years => 90);
    if (_cmp($time, $treshold) > 0) {
        return 'several decades ago'
    }
    
    $treshold = $now->clone->subtract(years => 120);
    if (_cmp($time, $treshold) > 0) {
        return 'about a century ago'
    }
    
    if ($time->year / 100 == $now->year / 100 - 1) {
        return 'last century'
    }
    
    $treshold = $now->clone->subtract(years => 200);
    if (_cmp($time, $treshold) > 0) {
        return 'more than a century ago'
    }
    
    $treshold = $now->clone->subtract(years => 900);
    if (_cmp($time, $treshold) > 0) {
        return 'several centuries ago'
    }
    
    $treshold = $now->clone->subtract(years => 1200);
    if (_cmp($time, $treshold) > 0) {
        return 'about a millenium ago'
    }
    
    $treshold = $now->clone->subtract(years => 2000);
    if (_cmp($time, $treshold) > 0) {
        return 'more than a millenium ago'
    }
    
    return 'millenia ago'
}

1

__END__

=head1 NAME

DateTime::Duration::Fuzzy -- express dates as fuzzy human-friendly strings

=head1 SYNOPSIS

 use DateTime::Duration::Fuzzy qw(time_ago);
 use DateTime;
 
 my $now = DateTime->new(
    year => 2010, month => 12, day => 12,
    hour => 19, minute => 59,
 );
 my $then = DateTime->new(
    year => 2010, month => 12, day => 12,
    hour => 15,
 );
 print time_ago($then, $now);
 # outputs 'several hours ago'
 
 print time_ago($then);
 # $now taken from C<time> function

=head1 DESCRIPTION

DateTime::Duration::Fuzzy is inspired from the timeAgo jQuery module
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

=back

=head1 AUTHOR

Jan Oldrich Kruza, C<< <sixtease at cpan.org> >>

=head1 LICENSE AND COPYRIGHT

Copyright 2010 Jan Oldrich Kruza.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut
