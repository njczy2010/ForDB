#!/usr/bin/perl -w
use strict;

use ForEnumDB;
use DBI;
use Log;
use FileOperation;
use Initialize;
use Cwd;

use DBOperation qw(
    CompareDBs
    CompareFile
    CheckTableExist
    QueryDBRow_array
    QueryDBRow_hash
    QueryDB
    PrintTable
    PrintTableContent
    QueryDBCol_array);

use Variables qw(
                $rootPath
                
                $gszLogFilename
                $gszReportFolder
		
		$gszBasedbFolder
                $gszNewdbFolder
                
                $gszBasedbName
                $gszNewdbName
                
                $gszCompareLogFilename
                $gszCompareFolder
                
                $gszDifferent_Result
                $gszSum_Result
                
                $gszParentContentsFolder
                $gszCompareFolder
                
                $gszBasedbPath
                $gszNewdbPath
                
                $giDifferent_Table_Count
                $giSame_Table_Count
                );
                

    my @argv = @ARGV;
    my $ret = 1;
    
    ##
    #our $rootPath = "C:\\Users\\zhiyang_chen\\Desktop\\ForDB\\";
    #our $gszBasedbPath = "C:\\Users\\zhiyang_chen\\Desktop\\ForDB\\MBG.db";
    #our $gszNewdbPath = "C:\\Users\\zhiyang_chen\\Desktop\\ForDB\\MBG2.db";
    
    #examples:
    #perl CompareDB.pl C:\Users\Administrator\Desktop\ForDB\ C:\Users\Administrator\Desktop\ForDB\MBG.db C:\Users\Administrator\Desktop\ForDB\MBG2.db

    if ( @argv <= 1 ) {
        print "Usage: perl.exe ForEnumDB.pl dbBasePath dbNewPath\n";
        goto _END;
    }

    
    $rootPath = getcwd;
        
    $rootPath =~ s/\//\\/g;

    $rootPath .= "\\";
    
    $gszBasedbPath = $argv[0];
    $gszNewdbPath = $argv[1];
    
    if( index($gszBasedbPath,".db") == -1){
        print "not a db path!\n";
	goto _END_CompareDB;
    }
    
    if( index($gszNewdbPath,".db") == -1){
        print "not a db path!\n";
	goto _END_CompareDB;
    }
    
    my $pos = rindex($gszBasedbPath,"\\");
    $gszBasedbName = substr($gszBasedbPath,$pos + 1 );
    
   # $rootPath = substr($gszBasedbPath,0,$pos + 1);
    $gszBasedbFolder = substr($gszBasedbPath, 0 , $pos + 1);
    
    
    $pos = rindex($gszNewdbPath,"\\");
    $gszNewdbName = substr($gszNewdbPath,$pos + 1 );
    $gszNewdbFolder = substr($gszNewdbPath, 0 , $pos + 1);

    
    Initialize::InitializeVariables;
    
    #print "gszBasedbFolder = $gszBasedbFolder\n";
    
    Log::WriteLog("\n\t\tBegin the CompareDB.pl,BasedbName = $gszBasedbName, NewdbName = $gszNewdbName, rootPath = $rootPath\n");

    
    my $hResultFile;
    
    if( ! (-e $gszBasedbPath)){
	$ret = 0;
	Log::WriteLog("db $gszBasedbPath not exist!\n");
        goto _END_CompareDB;
    }
    
    if( ! (-e $gszNewdbPath)){
	$ret = 0;
	Log::WriteLog("db $gszNewdbPath not exist!\n");
        goto _END_CompareDB;
    }
    
    if(! (-e $gszReportFolder)){
        if ( !FileOperation::CreateFolder($gszReportFolder) ) {
            $ret = 0;
            goto _END_CompareDB;
        }
    }
    
    if(! (-e $gszParentContentsFolder)){
        if ( !FileOperation::CreateFolder($gszParentContentsFolder) ) {
            $ret = 0;
            goto _END_CompareDB;
        }
    }
    
    if(! (-e $gszCompareFolder)){
        if ( !FileOperation::CreateFolder($gszCompareFolder) ) {
            $ret = 0;
            goto _END_CompareDB;
        }
    }
    
    #unlink($gszCompareLogFilename);
    unlink($gszSum_Result);
    unlink($gszDifferent_Result);
    
    $giDifferent_Table_Count = 0;
    $giSame_Table_Count = 0;
    #if (exists $$hash_ini{LoopCount}) {
    #    $statement .= " Limit $$hash_ini{LoopCount}";
    #}

    my $statement = "select name from sqlite_master where type=\"table\" ORDER BY \"name\"";

    print "statement:$statement\n";
    Log::WriteLog("list base tablename statement:$statement\n");
    
    chdir $gszBasedbFolder;
    my $base_ary_files = QueryDBCol_array($gszBasedbPath, $statement);    
    chdir $gszNewdbFolder;
    my $new_ary_files = QueryDBCol_array($gszNewdbPath, $statement);
    
    #print "new_ary_files = $new_ary_files\n";
    
    #CompareFile($szFolderPath, $szBaseFileName, $szNewFileName);
    $ret = CompareDBs($base_ary_files,$new_ary_files);

_END_CompareDB:

    if ( $ret == 1 ) {
        Log::WriteLog("Succeed to run CompareDB.pl\n");
    }
    else {
        Log::WriteLog("Fail to run CompareDB.pl\n");
    }
   
    
    
    

 
  
   
    
