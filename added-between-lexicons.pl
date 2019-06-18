#!/usr/bin/perl

use warnings;
use strict;

die "Please specify old and new word list files.\n" unless @ARGV == 2;
my ($old_file, $new_file) = @ARGV;

# Read words in old lexicon.
my %old_words;
open IN, "<$old_file" or die "Can't open $old_file: $!\n";
while (my $line = <IN>) {
    my ($word) = ($line =~ /(\w+)/);
    next unless length $word;
    $word = uc $word;
    #print "Old word: $word\n";
    $old_words{$word} = 1;
}
close IN;

# Print words in new lexicon that are not in old lexicon.
open IN, "<$new_file" or die "Can't open $new_file: $!\n";
while (my $line = <IN>) {
    my ($word) = ($line =~ /(\w+)/);
    next unless length $word;
    $word = uc $word;
    #print "New word: $word\n";
    print "$word\n" unless exists $old_words{$word};
}
close IN;
