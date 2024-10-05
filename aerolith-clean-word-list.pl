#!/usr/bin/perl -ln

# Print only the word column from lines containing full word info.
next unless /^\d/;
my ($word) = (split /\t/)[3];
next unless $word =~ s/^[^A-Z]*([A-Z]+)[^A-Z]*$/$1/;
print $word;
