#!/usr/bin/perl -n

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


sub tests() {
    my @tests = ('"Take the ""A"" Train"', 'Stormy Weather', '"I, Don Quixote"');
    my $title,$page;
    # test with just starting page number
    foreach $test (@tests) {
        ($title,$page) = try_match("$test,5,");
        die "Failed name match on <$test,5,>, got <$title>" unless ($title==$test);
        die "Failed page match on <$test,5,>, got <$page>" unless ($page=='5');
        ($title,$page) = try_match("$test,5,7");
        die "Failed name match on <$test,5,7>, got <$title>" unless ($title==$test);
        die "Failed page match on <$test,5,7>, got <$page>" unless ($page=='5');
    }
}

sub try_match {
    my $line = shift;

    if (($line =~ /^(.*),(\d+),(\d+),?\s*$/ ) || 
        ($line =~ /^(.*),(\d+),?\s*$/ )) {
        return ($1,$2);
    } else {
        die $line;
    }
}

BEGIN {
    tests();                                    # make sure all works ok
    $prev_title,$prev_startpage = undef,undef;
    print "title,pages\n";
}

@lines = ();
while (<>) {
    chomp;
    next if /^#/;       # ignore lines beginning with '#'
    next if /^\s*$/;    # ignore blank lines

    ($title,$startpage) = try_match($_);
    # if we have a pending entry, spit it out
    if ($prev_title) {
        printf("%s,%d-%d\n", $prev_title, $prev_startpage,$startpage);
    }
    ($prev_title,$prev_startpage) = ($title,$startpage);
    
END {
    # output final entry
    printf("%s,%d-%d\n", $title,$startpage,$startpage+1);
}    
