package DDG::Goodie::Wavelength;
use utf8;
# ABSTRACT: Frequency to wavelength

use DDG::Goodie;

use constant SPEED_OF_LIGHT => 299792458; #meters/second
use constant MULTIPLIER => {
     hz => 1,
    khz => 10**3,
    mhz => 10**6,
    ghz => 10**9,
    thz => 10**12
};
use constant FORMAT_UNITS => {
     hz => 'Hz',
    khz => 'kHz',
    mhz => 'MHz',
    ghz => 'GHz',
    thz => 'THz'
};

zci answer_type => "wavelength";
zci is_cached   => 1;

# Metadata.  See https://duck.co/duckduckhack/metadata for help in filling out this section.
name "Wavelength";
description "Frequency to Wavelength translation";
primary_example_queries "λ 2.4GHz", "144.39 MHz wavelength","lambda 1500kHz";
category "physical_properties";
topics "math", "science", "special_interest";
code_url "https://github.com/nebulous/zeroclickinfo-goodies/blob/master/lib/DDG/Goodie/Wavelength.pm";
attribution  github => ["nebulous", "John Lifsey"],
               cpan => "nebulous",
            twitter => "aresweet";

# Triggers
triggers any => "λ", "wavelength", "lambda";

# Handle statement
handle remainder => sub {
    my ($freq,$units) = m/([\d\.]+)\s*((k|M|G|T)?hz)/i;
    return unless $freq and $units;

    my $mul     = MULTIPLIER->{lc($units)};
    my $hz_freq = $freq * $mul;

    my $output_value = (SPEED_OF_LIGHT / $hz_freq);
    my $output_units = 'Meters';

    # Express higher freqs in cm/mm.
    # eg UHF 70cm band, microwave 3mm, etc
    if ($output_value<1) {
        $output_units = 'Centimeters';
        $output_value *= 100;
        if ($output_value<1) {
            $output_units = 'Millimeters';
            $output_value *= 10;
        }
    }

    my $output_text = "λ = $output_value $output_units";

    return $output_text,
        structured_answer => {
            input     => [$freq, FORMAT_UNITS->{lc($units)}],
            operation => "Wavelength",
            result    => $output_text,
        };
};

1;
