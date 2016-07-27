package Log;
use strict;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw();

use Variables qw(                
                $gszLogFilename
                $gszCompareLogFilename
                );
                
sub WriteLog
{
    my ($szMsg) = @_;
    
    my $time = localtime();
    
   # print "gszLogFilename = $gszLogFilename \n";
    my $hLogFile;
    if ( ! open($hLogFile, ">>$gszLogFilename") ) {
        print "Fail to open log file \"$gszLogFilename\"\n";
        return 0;
    }
    
    if ( !print $hLogFile "[$time]:$szMsg" ) {
        print "Fail to write message \"$szMsg\" to log file.\n";
    }
    else {
        print "[$time]:$szMsg";
    }
    
    close($hLogFile);
}

sub WriteLogc
{
    my ($szMsg) = @_;
    
    my $time = localtime();
    
   # print "gszLogFilename = $gszLogFilename \n";
    my $hLogFile;
    if ( ! open($hLogFile, ">>$gszCompareLogFilename") ) {
        print "Fail to open log file \"$gszCompareLogFilename\"\n";
        return 0;
    }
    
    if ( !print $hLogFile "[$time]:$szMsg" ) {
        print "Fail to write message \"$szMsg\" to log file.\n";
    }
    else {
        print "[$time]:$szMsg";
    }
    
    close($hLogFile);
}

1;

