#!/usr/bin/perl

use warnings;
use strict;

for my $file (@ARGV) {
  open IN, "<$file";
  while (<IN>) {
    next unless /<progress/;
    my ($current) = /question="([^"]+)/;
    ++$current;
    my ($total) = /total-questions="([^"]+)/;
    my ($correct) = /correct-questions="([^"]+)/;
    print "$file: $current / $total\n";
    last;
  }
  close IN;
}
