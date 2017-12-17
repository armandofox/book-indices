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
        warn "Ignoring line $. in $file:\n$line\n";
    }
}

$offset = 1;

$dir = shift @ARGV;
die "Usage:
  $0 <dirname>
         Creates MobileSheets-compatible CSVs in directory 'dirname', which must exist
  $0 <dirname> col1=val1 col2=val2  ...etc...
        Also adds col1,col2, etc. as columns in the output CSV, with  val1,val2, etc as the
        fixed value in that column for each entry. Useful for setting columns
        like genre,collections,etc. in MobileSheets.
" unless $dir && -d $dir;

%extracols = ();
while($_ = shift @ARGV) {
    my($colname,$colval) = split(/=/);
    $extracols{$colname} = $colval;
}
foreach $file (glob '*.csv') {
    open($fh,'<',$file) or die "Can't open $file";
    open(OUT,'>',"$dir/$file") or die "Can't write $dir/$file";
    @lines = ();
    while (<$fh>) {
        chomp;
        next  if /^#/;       # ignore lines beginning with '#'
        next if /^\s*$/;    # ignore blank lines
        
        ($title,$startpage) = try_match($_);
        push(@lines,sprintf("%04d,%s",0+$startpage,$title));
    }
    close $fh;
    print OUT join(',',("title","pages",keys(%extracols)))."\n";
    foreach $_ (sort @lines) {
        if (/^(\d+),(.*)$/) {
            printf OUT ("%s,%d-%d,%s\n", $2, $1, $1+$offset, join(',',values(%extracols)));
        } 
    }
    close OUT;
}


