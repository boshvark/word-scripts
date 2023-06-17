#!/usr/bin/perl

use warnings;
use strict;
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

# Output directory
my $outdir = '.';
if (exists $options{'outdir'}) {
    $outdir = $options{'outdir'};
    system 'mkdir', '-p', $outdir;
}

# Create output file name from input list file names
die "Please specify word list files.\n" unless @ARGV;
my $quiz_name = join("_", map { my $f = $_; $f =~ s/^.*\///; $f =~ s/\.txt\z//; $f } @ARGV);

# Read word count for each alphagram in lexicon
my %alphagram_words;
my $lexicon_file = "$zyzdir/data/words/$lexicon_location/$lexicon.txt";
open IN, "<$lexicon_file" or die "Can't open $lexicon_file: $!\n";
while (my $line = <IN>) {
    my ($word) = ($line =~ /(\w+)/);
    next unless length $word;
    $word = uc $word;
    my $alphagram = join('', sort(split '', $word));
    push @{$alphagram_words{$alphagram}}, $word;
}
close IN;

# Create hash of quiz alphagrams
my $total_count = 0;
my %quiz_alphagrams;
my @words;
while (my $line = <>) {
    my ($word) = ($line =~ /(\w+)/);
    next unless length $word;
    $word = uc $word;
    push @words, $word;
    my $alphagram = join('', sort(split '', $word));
    next if exists $quiz_alphagrams{$alphagram};
    $quiz_alphagrams{$alphagram} = 1;
    $total_count += @{$alphagram_words{$alphagram}};
}

my $word_str = join(' ', sort @words);
my $question_count = scalar keys %quiz_alphagrams;
my $tmp_file = "$outdir/$quiz_name.zzq.tmp";
my $zzq_file = "$outdir/$quiz_name.zzq";
open TMP_OUT, ">$tmp_file" or die "Can't write to $tmp_file: $!\n";
print TMP_OUT <<EOF;
<?xml version="1.0" encoding="ISO-8859-1"?>
<!DOCTYPE zyzzyva-quiz SYSTEM 'http://boshvark.com/dtd/zyzzyva-quiz.dtd'>
<zyzzyva-quiz question-order="Random" method="Standard" lexicon="$lexicon" type="Anagrams">
 <question-source type="search">
  <zyzzyva-search version="1">
   <conditions>
    <and>
     <condition type="In Word List" negated="0" string="$word_str"/>
    </and>
   </conditions>
  </zyzzyva-search>
 </question-source>
 <randomizer algorithm="1" seed="1687016647" seed2="78332"/>
 <progress question-complete="false" total-questions="$question_count" correct-questions="0" question="0" correct="0"/>
</zyzzyva-quiz>
EOF
close TMP_OUT;

# Write create table SQL
#my $sql_file = "$outdir/$quiz_name.sql";
#my $zq_file = "$outdir/$quiz_name.zzq";
#open SQL_OUT, ">$sql_file" or die "Can't write to $sql_file: $!\n";
#print SQL_OUT <<EOF;
#CREATE TABLE questions (question_index integer, status integer, name text);
#CREATE UNIQUE INDEX question_index_index ON questions (question_index);
#CREATE INDEX question_status_index ON questions (status);
#CREATE TABLE quiz (lexicon text, type integer, current_question integer, num_words integer, method integer, question_order integer);
#CREATE TABLE responses (question_index integer, status integer, name text);
#CREATE INDEX question_response_index ON responses (question_index);
#CREATE UNIQUE INDEX question_response_response_index ON responses (question_index, name);
#EOF
#
## Write question data
#my $question_index = 0;
#my $first_alphagram;
#for my $alphagram (keys %quiz_alphagrams) {
#    if ($question_index == 0) {
#        $first_alphagram = $alphagram;
#    }
#    my $question_status = ($question_index == 0 ? 1 : 0);
#    print SQL_OUT "INSERT INTO questions (question_index, status, name) VALUES ($question_index, $question_status, '$alphagram');\n";
#    ++$question_index;
#}
#
## Write quiz data
#print SQL_OUT "INSERT INTO quiz (lexicon, type, current_question, num_words, method, question_order) VALUES ('$lexicon', 2, 0, $total_count, 1, 1);\n";
#
## Write response data
#for my $word (@{$alphagram_words{$first_alphagram}}) {
#    print SQL_OUT "INSERT INTO responses (question_index, status, name) VALUES (0, 0, '$word');\n";
#}
#
#close SQL_OUT;

# Create Zyzzyva quiz file and remove temp SQL file
system "mv $tmp_file $zzq_file";
