#!/usr/bin/perl

# Rules for "simplified CSV" parsing (from github:aspiers/book-indices README):
# Each line looks like either
#   song_name,start_page
# or
#   song_name,start_page,end_page
#
# song_name may be either a bare string or a double-quoted string (in case
#   contains commas)
# If double quoted, it may contain escaped dquotes, eg "Take the ""A"" Train"
#

sub try_match {
    my $line = shift;
    if (($line =~ /^(.*),(\d+),(\d+),?\s*$/ ) || 
        ($line =~ /^(.*),(\d+),?\s*$/ )) {
        return ($1,$2);
    } else {
        warn "Couldn't parse line $. in $file:\n$line\n";
    }
}

$offset = 1;
@lines = ();

$dir = shift @ARGV;
die "Usage: $0 <dirname>\nCreates MobileSheets-compatible CSVs in directory 'dirname', which must exist\n" unless $dir && -d $dir;

foreach $file (glob '*.csv') {
    open(FH,'<',$file) or die "Can't open $file";
    open(OUT,'>',"$dir/$file") or die "Can't write $dir/$file";
    while (<FH>) {
        chomp;
        next  if /^#/;       # ignore lines beginning with '#'
        next if /^\s*$/;    # ignore blank lines
        
        ($title,$startpage) = try_match($_);
        push(@lines,"$startpage,$title");
    }
    
    print OUT "title,pages\n";
    foreach $_ (sort @lines) {
        if (/^(\d+),(.*)$/) {
            printf OUT ("%s,%d-%d\n", $2, $1, $1+$offset);
        } 
    }
    printf STDERR "$file -->  $dir/$file\n";
}


