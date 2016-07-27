package FileOperation;
use strict;
use warnings;

use File::Copy;
use File::Path;
use Log;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw();

sub CreateFile
{
    my ($szFilename) = @_;
    
    print "szFilename = $szFilename \n";
    
    my $ret = 0;
    
    my $i = 0;
    for ( $i = 0; $i < 5; $i ++ ) {
        my $hFile;
        if ( open($hFile, ">$szFilename") ) {
            close($hFile);
        }
        if ( -e $szFilename ) {
            $ret = 1;
            last;
        }
        sleep(1);
    }
    
    if ( $ret == 1 ) {
        Log::WriteLog("Succeed to create file \"$szFilename\".\n");
    }
    else {
        Log::WriteLog("Fail to create file \"$szFilename\".\n");
    }
    
    return $ret;
}

sub DeleteFile
{
    my ($szFilename) = @_;
    
    my $ret = 0;
    
    my $i = 0;
    for ( $i = 0; $i < 5; $i ++ ) {
        unlink($szFilename);
        if ( !-e $szFilename ) {
            $ret = 1;
            last;
        }
        sleep(1);
    }
    
    if ( $ret == 1 ) {
        Log::WriteLog("Succeed to delete file \"$szFilename\".\n");
    }
    else {
        Log::WriteLog("Fail to delete file \"$szFilename\".\n");
    }
        
    return $ret;
}

sub CreateFolder
{
    my ($szFoldername) = @_;
    
    my $ret = 0;
    
    my $i = 0;
    for ( $i = 0; $i < 5; $i ++ ) {
        mkdir($szFoldername);
        if ( -e $szFoldername ) {
            $ret = 1;
            last;
        }
        sleep(1);
    }
    
    if ( $ret == 1 ) {
        Log::WriteLog("Succeed to create folder \"$szFoldername\".\n");
    }
    else {
        Log::WriteLog("Fail to create folder \"$szFoldername\".\n");
    }
        
    return $ret;    
}

sub CreateFileWithPathname
{
    my ($szPathname) = @_;
    
    my $ret = 1;
    
    my @szTemps = split(/\\/, $szPathname);
    my $szTemp = "";
    
    my $i = 0;
    for ( $i = 0; $i < @szTemps - 1; $i ++ ) {
        $szTemp = $szTemp . $szTemps[$i] . "\\";
        if ( !CreateFolder($szTemp) ) {
            $ret = 0;
            goto _END_CreateFileWithPathname;
        }
    }
    
    $szTemp = $szTemp . $szTemps[$i];
    if ( !CreateFile($szTemp) ) {
        $ret = 0;
    }
    
_END_CreateFileWithPathname:

    if ( $ret == 1 ) {
        Log::WriteLog("Succeed to create file \"$szPathname\" with path name.\n");
    }
    else {
        Log::WriteLog("Fail to create file \"$szPathname\" with path name.\n");
    }
    
    return $ret;
}

sub RenameFile
{
    my ($szOldFilename, $szNewFilename) = @_;
    
    my $ret = 0;
    
    my $i = 0;
    for ( $i = 0; $i < 5; $i ++ ) {
        $ret = rename($szOldFilename, $szNewFilename);
        if ( (!-e $szOldFilename) && (-e $szNewFilename) ) {
            $ret = 1;
            last;
        }
        sleep(1);
    }
    
    if ( $ret == 1 ) {
        Log::WriteLog("Succeed to rename file from \"$szOldFilename\" to \"$szNewFilename\".\n");
    }
    else {
        Log::WriteLog("Fail to rename file from \"$szOldFilename\" to \"$szNewFilename\".\n");
    }
        
    return $ret;
}

sub CopyFile
{
    my ($szSourceFilename, $szDestFilename) = @_;
    
    my $ret = 0;
    
    my $i = 0;
    for ( $i = 0; $i < 5; $i ++ ) {
        $ret = File::Copy::copy($szSourceFilename, $szDestFilename);
        if ( $ret == 1 ) {
            if ( -e $szDestFilename ) {
                last;
            }
        }
        sleep(1);
    }
    
    if ( $ret == 1 ) {
        Log::WriteLog("Succeed to copy file from \"$szSourceFilename\" to \"$szDestFilename\".\n");
    }
    else {
        Log::WriteLog("Fail to copy file from \"$szSourceFilename\" to \"$szDestFilename\".\n");
    }
        
    return $ret;
}

sub DeleteFolder
{
    my ($szFoldername) = @_;
    
    my $ret = 0;
    
    my $i = 0;
    for ( $i = 0; $i < 3; $i ++ ) {
        File::Path::remove_tree($szFoldername);
        if ( !-e $szFoldername ) {
            $ret = 1;
            last;
        }
        sleep(1);
    }
    
    if ( $ret == 1 ) {
        Log::WriteLog("Succeed to delete folder \"$szFoldername\".\n");
    }
    else {
        Log::WriteLog("Fail to delete folder \"$szFoldername\".\n");
    }
    
    return $ret;
}



1;
