package DDG::Goodie::UnixTime;
# ABSTRACT: epoch -> human readable time

use DDG::Goodie;

use DateTime;
use List::MoreUtils qw( uniq );
use Try::Tiny;

triggers query => qr/^(?:(?:unixtime|datetime|unix time|unix timestamp|unix time stamp|unix epoch)( \d+)?|(?:timestamp|epoch) (\d+))$/;

zci answer_type => "time_conversion";
zci is_cached   => 0;

attribution github => ['https://github.com/codejoust', 'codejoust'];

primary_example_queries 'unix time 0000000000000';
secondary_example_queries 'epoch 0', 'epoch 2147483647';
description 'convert a unix epoch to human-readable time';
code_url 'https://github.com/duckduckgo/zeroclickinfo-goodies/blob/master/lib/DDG/Goodie/UnixTime.pm';
category 'calculations';
topics 'sysadmin';

my $default_tz  = 'UTC';
my $time_format = '%a %b %d %T %Y %Z';
my $header_format = "Time (%s)";

handle matches => sub {

    my @matches = grep { defined $_ } @_;
    my $time_input = $matches[0] // time;    # If there was nothing in there, we must want now.
    $time_input = 0 + $time_input;           # Force to number.
    my @headers = ('Unix Epoch');
    my @data = ($time_input);

    my $time_output;
    my $dt = try { DateTime->from_epoch(epoch => $time_input) };
    return unless $dt;
    foreach my $tz (uniq grep { $_ } ($loc->time_zone, $default_tz)) {
        $dt->set_time_zone($tz);
        push @headers, sprintf($header_format, $tz);
        push @data, $dt->strftime($time_format);
    }
    return unless @data;
    my $html_table = '<table class="unixtime">';
    $html_table .= '<tr><th>' . join('</th><th>', @headers) . '</th></tr>';
    $html_table .= '<tr><td>' . join('</td><td>', @data) . '</td></tr>';
    $html_table .= '</table>';
    return $time_input . ' (Unix epoch): ' . join(' / ', @data), html => $html_table;
};

1;
