#!/bin/perl

use warnings;
use strict;

my @lexicons = ('OWL3');
my @word_lengths = (7, 8);
my @num_blanks = (0);
my $db_dir = "$ENV{HOME}/Dropbox/Apps/Zyzzyva/lexicons";
my $zyzdir = "$ENV{HOME}/Dropbox/Scrabble/zyzzyva-data";
my $sqlite = 'sqlite3';
my $list_size = 100;
my $folder_lists = 10;
my $folder_size = $list_size * $folder_lists;

my $top_dir = "grouped-by-$list_size";
system 'rm', '-rf', $top_dir;
system 'mkdir', '-p', $top_dir;

for my $lexicon (@lexicons) {
    my $words_dir = "$top_dir/words";
    my $quiz_dir = "$top_dir/quiz";
    my $lexicon_dir = "$words_dir/$lexicon";
    system 'mkdir', '-p', $lexicon_dir;

    for my $num_blanks (@num_blanks) {
        my $num_blanks_dir = "$lexicon_dir/$num_blanks-blanks";
        system 'mkdir', '-p', $num_blanks_dir;

        for my $word_length (@word_lengths) {
            my $word_length_str = "${word_length}s";
            my $word_length_dir = "$num_blanks_dir/$word_length_str";
            system 'mkdir', '-p', $word_length_dir;

            my $db_file = "$db_dir/$lexicon.db";
            my $word_count = `$sqlite $db_file 'select count(*) from words where length = $word_length'`;
            chomp $word_count;
            my $max_index_length = length $word_count;
            print "Generating lists and quizzes for $lexicon $word_length_str ($num_blanks blanks)...\n";
            print "$lexicon ($word_length): $word_count\n";

            my $index = 0;
            my $folder_name;
            my $list_dir;
            my $sprintf_format = "$word_length_str-%0${max_index_length}d";

            while ($index < $word_count) {

                if (!($index % $folder_size)) {
                    $folder_name = sprintf($sprintf_format, $index + $folder_size);
                    $list_dir = "$word_length_dir/$folder_name";
                    print "Creating folder $folder_name...\n";
                    system 'mkdir', '-p', $list_dir;
                }

                my $start = $index + 1;
                my $end = $start + $list_size - 1;
                my $column = "probability_order${num_blanks}";
                my $words = `$sqlite $db_file 'select word from words where length = $word_length and $column >= $start and $column <= $end'`;

                my $list_name = sprintf($sprintf_format, $end);
                my $list_file = "$list_dir/$list_name.txt";

                open OUT, ">$list_file" or die "Can't open output file $list_file: $!\n";
                print OUT $words;
                close OUT;

                my $list_quiz_dir = "$quiz_dir/$lexicon/$num_blanks-blanks/${word_length}s/$folder_name";
                system 'perl', './make-ios-quiz.pl', '--zyzdir', $zyzdir, '--lexicon', $lexicon, '--outdir', $list_quiz_dir, $list_file;

                $index += $list_size;
            }
        }
    }
}



