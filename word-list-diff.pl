#!/usr/bin/perl

use warnings;
use strict;
use Getopt::Long;

# By default, print both added and removed entries.
# If --added is specified, only print added entries.
# If --removed is specified, only print removed entries.
my $print_added;
my $print_removed;
my $print_prefix;
GetOptions("added|a" => \$print_added,
           "removed|r" => \$print_removed)
    or die "Error in command line arguments.\n";
if (not $print_added and not $print_removed) {
  $print_added = 1;
  $print_removed = 1;
}
if ($print_added and $print_removed) {
  $print_prefix = 1;
}

if (@ARGV != 2) {
  die "Please provide two word list files.\n"
}

my ($left_file, $right_file) = @ARGV;
my %word_prefixes;

# Read words from the left file.
open LEFT, "<$left_file" or die "Can't open $left_file: $!\n";
while (my $word = <LEFT>) {
  chomp $word;
  $word_prefixes{$word} = "-";
}
close LEFT;

# Read words from the right file. Track additions and delete common words.
open RIGHT, "<$right_file" or die "Can't open $right_file: $!\n";
while (my $word = <RIGHT>) {
  chomp $word;
  if (exists $word_prefixes{$word}) {
    delete $word_prefixes{$word};
  } else {
    $word_prefixes{$word} = "+";
  }
}
close RIGHT;

# Print sorted words.
for my $word (sort keys %word_prefixes) {
  my $prefix = $word_prefixes{$word};
  next if $prefix eq "+" and not $print_added;
  next if $prefix eq "-" and not $print_removed;
  print $prefix if $print_prefix;
  print "$word\n";
}
