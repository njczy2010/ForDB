package Result;
use strict;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw();

use Variables qw(                
                $gszLogFilename
                $gszCompareLogFilename
                );
                
sub WriteResult
{
    my ($szFilename, $szMsg) = @_;
    
    my $hLogFile;
    if ( ! open($hLogFile, ">>$szFilename") ) {
        print "Fail to open result file \"$szFilename\"\n";
        return 0;
    }
    
    if ( !print $hLogFile "$szMsg" ) {
        print "Fail to write message \"$szMsg\" to result file.\n";
    }
    else {
        #print "$szMsg";
    }
    
    close($hLogFile);
}

1;

