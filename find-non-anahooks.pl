#!/usr/bin/perl

use warnings;
use strict;
use File::Basename;
use Getopt::Long;

my %options;
my $ok = GetOptions(\%options, "zyzdir=s", "lexicon=s", "outdir=s");

# Zyzzyva installation directory
die "Please specify Zyzzyva installation directory with --zyzdir.\n" unless exists $options{'zyzdir'};
my $zyzdir = $options{'zyzdir'};

# Lexicon
die "Please specify lexicon with --lexicon.\n" unless exists $options{'lexicon'};
my $lexicon = $options{'lexicon'};
my $lexicon_location = 'North-American';
if ($lexicon eq 'CSW12') {
    $lexicon_location = 'British';
}

# Read words from lexicon.
my %words;
my %alphagram_words;
my $lexicon_file = "$zyzdir/data/words/$lexicon_location/$lexicon.txt";
open IN, "<$lexicon_file" or die "Can't open $lexicon_file: $!\n";
while (my $line = <IN>) {
    my ($word) = ($line =~ /(\w+)/);
    next unless length $word;
    $word = uc $word;
    $words{$word} = 1;
    my $alphagram = join('', sort(split '', $word));
    push @{$alphagram_words{$alphagram}}, $word;
}
close IN;

my @non_anahook_alphagrams = ();
my $count = 0;
for my $alphagram (keys %alphagram_words) {
  #next unless length $alphagram == 8;

  my $is_anahook = 0;
  my @alphagram = split '', $alphagram;
  for my $index (0 .. $#alphagram) {
    my @partial_alphagram = @alphagram;
    splice @partial_alphagram, $index, 1;
    my $partial_alphagram = join '', @partial_alphagram;
    if (exists $alphagram_words{$partial_alphagram}) {
      $is_anahook = 1;
      last;
    }
  }

  push @non_anahook_alphagrams, $alphagram unless $is_anahook;
}

for my $alphagram (sort {length $a <=> length $b or $a cmp $b} @non_anahook_alphagrams) {
  print join "\t", @{[$alphagram]}, @{$alphagram_words{$alphagram}};
  print "\n";
}
