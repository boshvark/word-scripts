#!/usr/bin/perl -ln

# Print only the blank word column from lines containing blanks.
next unless /^[A-Z]*\?/;
my ($word) = (split /\t/)[0];
next unless $word =~ s/^[^A-Z\?]*([A-Z\?]+)[^A-Z\?]*$/$1/;
print $word;

