#!/usr/bin/perl -w
use strict;

use ForEnumDB;
use DBI;
use Log;
use FileOperation;
use Initialize;
use Cwd;

use DBOperation qw(
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
                $gszdbContents
                $gszReportFolder
		
		$gszdbFolder
                
                $gszParentContentsFolder
                $gszContentsFolder
                
                $gszdbName
                $gszdbPath
                
                );
                
    
    my @argv = @ARGV;
    my $ret = 1;
    
    ##
    #our $rootPath = "C:\\Users\\zhiyang_chen\\Desktop\\ForDB\\";
    #our $gszdbPath = "C:\\Users\\zhiyang_chen\\Desktop\\ForDB\\MBG2.db";
    
    #examples:
    #perl ForEnumDB.pl C:\Users\Administrator\Desktop\ForDB\MBG.db

    if ( @argv <= 0 ) {
        print "Usage: perl.exe ForEnumDB.pl dbPath\n";
        goto _END;
    }
    
    $gszdbPath = $argv[0];
    
    if( index($gszdbPath,".db") == -1){
        print "not a db path!\n";
	goto _END_ForEnumDB;
    }
    
    my $pos = rindex($gszdbPath,"\\");
    $gszdbName = substr($gszdbPath,$pos + 1 );
    #$rootPath = substr($gszdbPath,0,$pos + 1);
    
    $gszdbFolder = substr($gszdbPath, 0 , $pos + 1);
        
    $rootPath = getcwd;
    $rootPath =~ s/\//\\/g;
    
    $rootPath .= "\\";
    
    Initialize::InitializeVariables;

    print "rootPath = $rootPath\n";
    print "gszdbPath = $gszdbPath\n";
    
    chdir $gszdbFolder;
    
    Log::WriteLog("\n\t\tBegin the ForEnumDB.pl,DBname = $gszdbName, rootPath = $rootPath\n");
    
    # Êý¾Ý¿âÃû
    #my $szDBname = "D:\\czy\\work\\DB\\MBG.db";            
    my $hdbContests;
    my $itable_count = 0;
    
    if( ! (-e $gszdbPath)){
	$ret = 0;
	Log::WriteLog("db $gszdbPath not exist!\n");
        goto _END_ForEnumDB;
    }
        
    if(! (-e $gszReportFolder)){
        if ( !FileOperation::CreateFolder($gszReportFolder) ) {
            $ret = 0;
            goto _END_ForEnumDB;
        }
    }
    
    if(! (-e $gszParentContentsFolder)){
        if ( !FileOperation::CreateFolder($gszParentContentsFolder) ) {
            $ret = 0;
            goto _END_ForEnumDB;
        }
    }
    
    if(! (-e $gszContentsFolder)){
        if ( !FileOperation::CreateFolder($gszContentsFolder) ) {
            $ret = 0;
            goto _END_ForEnumDB;
        }
    }
    
    #unlink($gszLogFilename);
    unlink($gszdbContents);

    #if (exists $$hash_ini{LoopCount}) {
    #    $statement .= " Limit $$hash_ini{LoopCount}";
    #}
    
    my $statement = "select name from sqlite_master where type=\"table\" ORDER BY \"name\"";

    print "statement:$statement\n";
    Log::WriteLog("list tablename statement:$statement\n");
	
    my $ary_files = QueryDBCol_array($gszdbPath, $statement);
    
    if ( ! open($hdbContests, ">>$gszdbContents") ) {
        print "Fail to open db contents file \"$gszdbContents\"\n";
        Log::WriteLog("Fail to open db contents file \"$gszdbContents\"\n");
        $ret = 0;
        goto _END_ForEnumDB;
    }
    
    for(my $i=0; $i<@$ary_files; $i++) {
	if( index($$ary_files[$i],"_") == -1){
            $itable_count++;
        }
    }
    print  $hdbContests "The file record all the tables in $gszdbName\n";
    
    print  "\ntable_count : $itable_count\n";
    print  $hdbContests "\ntable_count : $itable_count\n";
    
    close($hdbContests);
          
    for(my $i=0; $i<@$ary_files; $i++) {
	
       # print $hdbContests "$$ary_files[$i]\n";
        #print  "$$ary_files[$i]\n";

        $ret = PrintTable($gszdbName,$$ary_files[$i]);
        if($ret == 0){
            goto _END_ForEnumDB;
        }
    }
    
    

_END_ForEnumDB:

    if ( $ret == 1 ) {
        Log::WriteLog("Succeed to run ForEnumDB.pl\n");
    }
    else {
        Log::WriteLog("Fail to run ForEnumDB.pl\n");
    }
    

   
    
    
    

 
  
   
    
