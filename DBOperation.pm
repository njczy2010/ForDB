package DBOperation;
use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(
    CompareDBs
    CompareFile
    QueryDBRow_array
    QueryDBRow_hash
    QueryDBCol_array
    QueryDB
    PrintTable
    PrintTableContent
    CheckTableExist);

use DBI;
use Log;
use Result;
use Win32::Process;
use Win32::Process qw ( STILL_ACTIVE );

use Variables qw(
                $rootPath
                
                $gszLogFilename
                $gszdbContents
                
                $gszContentsFolder
                $gszParentContentsFolder
                
                $gszBasedbContentsFolder
                $gszNewdbContentsFolder
                
                $gszCompareFolder
                
                $gszBasedbName
                $gszNewdbName
                
                $gszDifferent_Result
                $gszSum_Result
                
                $giDifferent_Table_Count
                $giSame_Table_Count
                
                $gszBasedbPath
                $gszNewdbPath
                );

sub CompareTableContents
{
    my ($szTableFolder, $szTableName) = @_;
   
    Log::WriteLog("Begin to compare table contents, table is $szTableName\n");
    my $ret = 1;
    
    my $szContents_Only_In_Base = $szTableFolder . $szTableName . "_only_in_" . substr($gszBasedbName,0,-3) . ".txt";
    my $szContents_Only_In_New = $szTableFolder . $szTableName ."_only_in_" . substr($gszNewdbName,0,-3) . ".txt";
    
    if(-e $szContents_Only_In_Base){
        unlink($szContents_Only_In_Base);
    }
    if(-e $szContents_Only_In_New){
        unlink($szContents_Only_In_New);
    }

    my ($hBaseFile, $hNewFile);
    my $szBaseFilePath = $gszParentContentsFolder . substr($gszBasedbName,0,-3) . "\\" . $szTableName . ".txt";
    my $szNewFilePath = $gszParentContentsFolder . substr($gszNewdbName,0,-3) . "\\" . $szTableName . ".txt";
    
    if( ! (-e $szBaseFilePath) ){
        #$ret = 0;
        #print "Please run ForEnumDB.pl first, db name is $gszBasedbName\n";
        #Log::WriteLog("Please run ForEnumDB.pl first, db name is $gszBasedbName\n");
        #goto _END_CompareTableContents;
	
	my $hProcess;
	my $szCmd = "perl\.exe ForEnumDB.pl $gszBasedbPath";
	if ( Win32::Process::Create($hProcess, "c:\\perl\\bin\\perl.exe", $szCmd, 0, NORMAL_PRIORITY_CLASS|CREATE_NEW_CONSOLE, $rootPath) ) {
	    Log::WriteLog("Succeed to launch process \"$szCmd\".\n");
	    sleep(1);
	}
	else {
	    Log::WriteLog("Fail to launch process \"$szCmd\"\n.");        
	    $ret = 0;
	    goto _END_CompareTableContents;
	}	
    }
       
    if( ! (-e $szNewFilePath) ){
        #$ret = 0;
        #print "Please run ForEnumDB.pl first, db name is $gszNewdbName\n";
        #Log::WriteLog("Please run ForEnumDB.pl first, db name is $gszNewdbName\n");
        #goto _END_CompareTableContents;
	
	my $hProcess;
	my $szCmd = "perl\.exe ForEnumDB.pl $gszNewdbPath";
	if ( Win32::Process::Create($hProcess, "c:\\perl\\bin\\perl.exe", $szCmd, 0, NORMAL_PRIORITY_CLASS|CREATE_NEW_CONSOLE, $rootPath) ) {
	    Log::WriteLog("Succeed to launch process \"$szCmd\".\n");
	    sleep(1);
	}
	else {
	    Log::WriteLog("Fail to launch process \"$szCmd\"\n.");        
	    $ret = 0;
	    goto _END_CompareTableContents;
	}
    }
    
    
    if ( ! open($hBaseFile, "$szBaseFilePath") ) {
        print "Fail to open db contents file \"$szBaseFilePath\"\n";
        Log::WriteLog("Fail to open db contents file \"$szBaseFilePath\"\n");
        $ret = 0;
        goto _END_CompareTableContents;
    }
    
    my @szContents_Base = <$hBaseFile>;
    close $hBaseFile;
    
    if ( ! open($hNewFile, "$szNewFilePath") ) {
        print "Fail to open db contents file \"$szNewFilePath\"\n";
        Log::WriteLog("Fail to open db contents file \"$szNewFilePath\"\n");
        $ret = 0;
        goto _END_CompareFile;
    }
    
    my @szContents_New = <$hNewFile>;
    close $hBaseFile;
       
    my %hash_base=();
    my %hash_new=();
    
    for(my $i=0; $i<@szContents_Base; $i++) {
	$hash_base{$szContents_Base[$i]} = 1;
       # print "i=$i  $hash_base{$szContents_Base[$i]}\n";
    }
    
    for(my $i=0; $i<@szContents_New; $i++) {
	$hash_new{$szContents_New[$i]} = 1;
    }
    
    #my $j = 0;
    #my $flag = exists $hash_new{'$szContents_Base[$j]};
    #print "j=$j  $hash_base{'$szContents_Base[$j]'}  \n";
    #print "j=$j  $hash_base{'$szContents_Base[0]'}  \n";

    
    for(my $i=0; $i<@szContents_Base; $i++) {
        if( !exists $hash_new{$szContents_Base[$i]} ){
            if($ret == 1){
                if(! (-e $szTableFolder)){
                    if ( !FileOperation::CreateFolder($szTableFolder) ) {
                        $ret = 0;
                        goto _END_CompareTableContents;
                    }
                }
            }
            $ret = -1;
            Result::WriteResult($szContents_Only_In_Base, "line = $i : $szContents_Base[$i]");

           # print $hContents_Only_In_Base "line = $i : $szContents_Base[$i]\n";
        }
    }
    
    for(my $i=0; $i<@szContents_New; $i++) {
        if( !exists $hash_base{$szContents_New[$i]} ){
            if($ret == 1){
                if(! (-e $szTableFolder)){
                    if ( !FileOperation::CreateFolder($szTableFolder) ) {
                        $ret = 0;
                        goto _END_CompareTableContents;
                    }
                }
            }
            
            $ret = -1;
            Result::WriteResult($szContents_Only_In_New, "line = $i : $szContents_New[$i]");
            #print $hContents_Only_In_New "line = $i : $szContents_New[$i]\n";
        }
    }
    
    if($ret == -1){
        my $szDestFilename = $szTableFolder . $szTableName . "_in_" . $gszBasedbName . ".txt";

        if ( !FileOperation::CopyFile($szBaseFilePath,$szDestFilename) ) {
            $ret = 0;
            goto _END_CompareTableContents;
        }
    
        $szDestFilename = $szTableFolder . $szTableName . "_in_" . $gszNewdbName . ".txt";

        if ( !FileOperation::CopyFile($szNewFilePath,$szDestFilename) ) {
            $ret = 0;
            goto _END_CompareTableContents;
        }
    }

    
_END_CompareTableContents:

    if ( $ret != 0 ) {
        Log::WriteLog("Succeed to compare table contents, table is $szTableName\n");
    }
    else {
        Log::WriteLog("Fail to compare table contents, table is $szTableName\n");
    }
    return $ret;
}


sub CompareTables
{
    my ($szTableName) = @_;
    
    Log::WriteLog("Begin to compare table in dbs, table name is $szTableName\n");
    my $ret = 1;
    my $flag = 1;
    
    my %hash_base_content=();
    my %hash_new_content=();
    
    my $statement = "select * from $szTableName";
    
    my $szTableFolder = $gszCompareFolder . $szTableName . "\\";
    
    #my $szSourceFilename = $gszBasedbContentsFolder . $szTableName . ".txt";
    #my $szDestFilename = $szTableFolder . "in_" . $gszBasedbName . ".txt";

    #if( ! (-e $szSourceFilename) ){
    #    $ret = 0;
    #    print "Please run ForEnumDB.pl first, db name is $gszBasedbName\n";
    #    Log::WriteLog("Please run ForEnumDB.pl first, db name is $gszBasedbName\n");
    #    goto _END_CompareTables;
    #}
    #if ( !FileOperation::CopyFile($szSourceFilename,$szDestFilename) ) {
    #    $ret = 0;
    #    goto _END_CompareTables;
    #}
    
    #$szSourceFilename = $gszNewdbContentsFolder . $szTableName . ".txt";
    #$szDestFilename = $szTableFolder . "in_" . $gszNewdbName . ".txt";

    #if( -e $szSourceFilename){
    #    $ret = 0;
    #    print "Please run ForEnumDB.pl first, db name is $gszNewdbName\n";
    #    Log::WriteLog("Please run ForEnumDB.pl first, db name is $gszNewdbName\n");
    #    goto _END_CompareTables;
    #}
    #if ( !FileOperation::CopyFile($szSourceFilename,$szDestFilename) ) {
    #    $ret = 0;
    #    goto _END_CompareTables;
    #}
    
    $flag = CompareTableContents($szTableFolder, $szTableName);
    if($flag == 0){
        $ret = 0;
        goto _END_CompareTables;
    }
    elsif($flag == -1){
        $ret = -1;
        $giDifferent_Table_Count++;
    }
    else{
        $giSame_Table_Count++;
        
        #if ( !FileOperation::DeleteFolder($szTableFolder) ) {
        #    $ret = 0;
        #    goto _END_CompareTables;
        #}
    }
    
    

_END_CompareTables:

    if ( $ret != 0 ) {
        Log::WriteLog("Succeed to compare table in dbs, table name is $szTableName\n");
    }
    else {
        Log::WriteLog("Fail to compare table in dbs, table name is $szTableName\n");
    }
    return $ret;

}

sub CompareDBs
{
    my ($base_ary_files, $new_ary_files ) = @_;
    
    Log::WriteLog("Begin to compare dbs, base db is $gszBasedbName, new db is $gszNewdbName\n");
    my $ret = 1;
    
    #print "$base_ary_files\n\n";
    
    #print "$new_ary_files\n\n";
    
    my %hash_base_table=();
    my %hash_new_table=();
    
    my $hDifferert_Result;
    my $hSum_Result;
    
    Result::WriteResult($gszSum_Result, "The file record all the results compare $gszBasedbName with $gszNewdbName\n\n");
    Result::WriteResult($gszDifferent_Result, "The file record the different table contents compare $gszBasedbName with $gszNewdbName\n\n");
 
    for(my $i=0; $i<@$base_ary_files; $i++) {
	
       # print $hdbContests "$$ary_files[$i]\n";
        $hash_base_table{$$base_ary_files[$i]} = 1;
        #print  "$i $$base_ary_files[$i] $hash_base_table{$$base_ary_files[$i]}\n";

        #$ret = PrintTable($gszdbName,$$ary_files[$i]);
        if($ret == 0){
            goto _END_CompareDBs;
        }
    }
    
    for(my $i=0; $i<@$new_ary_files; $i++) {
	
       # print $hdbContests "$$ary_files[$i]\n";
        $hash_new_table{$$new_ary_files[$i]} = 1;
        #print  "$i $$base_ary_files[$i] $hash_base_table{$$base_ary_files[$i]}\n";

        #$ret = PrintTable($gszdbName,$$ary_files[$i]);
        if($ret == 0){
            goto _END_CompareDBs;
        }
    }
    
    for(my $i=0; $i<@$base_ary_files; $i++) {
	
        if( !exists $hash_new_table{$$base_ary_files[$i]} ){
            Result::WriteResult($gszSum_Result, "Table $$base_ary_files[$i] in $gszBasedbName,but not in $gszNewdbName\n");
            Result::WriteResult($gszDifferent_Result, "Table $$base_ary_files[$i] in $gszBasedbName,but not in $gszNewdbName\n");
            $giDifferent_Table_Count ++;
        }
        else{
            if( index($$base_ary_files[$i],"_") != -1){
                next;
            }
            my $flag = CompareTables($$base_ary_files[$i]);
            if($flag == 1){
                Result::WriteResult($gszSum_Result, "Table $$base_ary_files[$i] in $gszBasedbName and $gszNewdbName are the  same \n");
            }
            elsif($flag == -1){
                Result::WriteResult($gszSum_Result, "Table $$base_ary_files[$i] in $gszBasedbName and $gszNewdbName are  different \n");
                Result::WriteResult($gszDifferent_Result, "Table $$base_ary_files[$i] in $gszBasedbName and $gszNewdbName are  different \n");
            }
            else{
                $ret = 0;
                goto _END_CompareDBs;
            }
        }
    }
    
    for(my $i=0; $i<@$new_ary_files; $i++) {
	
        if( !exists $hash_base_table{$$new_ary_files[$i]} ){
            Result::WriteResult($gszSum_Result, "Table $$new_ary_files[$i] in $gszNewdbName,but not in $gszBasedbName\n");
            Result::WriteResult($gszDifferent_Result, "Table $$new_ary_files[$i] in $gszNewdbName,but not in $gszBasedbName\n");
            $giDifferent_Table_Count ++;
        }
        else{
        
        }
    }
    
    Result::WriteResult($gszSum_Result, "\ndifferent table count = $giDifferent_Table_Count\n");
    Result::WriteResult($gszDifferent_Result, "\ndifferent table count = $giDifferent_Table_Count\n");
    
    my $szTotal_Table_Count = $giSame_Table_Count + $giDifferent_Table_Count;
    Result::WriteResult($gszSum_Result, "same table count = $giSame_Table_Count\n");
    Result::WriteResult($gszSum_Result, "total table count = $szTotal_Table_Count\n");

    
_END_CompareDBs:

    if ( $ret == 1 ) {
        Log::WriteLog("Succeed to compare dbs, base db is $gszBasedbName, new db is $gszNewdbName\n");
    }
    else {
        Log::WriteLog("Fail to compare dbs, base db is $gszBasedbName, new db is $gszNewdbName\n");
    }
    return $ret;

}


sub CompareFile
{
    my ($szFolderPath, $szBaseFileName, $szNewFileName ) = @_;
    
    Log::WriteLog("Begin to compare file, base file is $szBaseFileName, new file is $szNewFileName\n");
    my $ret = 1;
    
    my $hContents_Only_In_Base;
    my $hContents_Only_In_New;

    my $szContents_Only_In_Base = $szFolderPath . "content_only_in_" . $szBaseFileName;
    my $szContents_Only_In_New = $szFolderPath . "content_only_in_" . $szNewFileName;

    my $hBaseFile;
    my $hNewFile;
    my $szBaseFilePath = $szFolderPath . $szBaseFileName;
    my $szNewFilePath = $szFolderPath . $szNewFileName;
    
    if ( ! open($hBaseFile, "$szBaseFilePath") ) {
        print "Fail to open db contents file \"$szBaseFileName\"\n";
        Log::WriteLog("Fail to open db contents file \"$szBaseFileName\"\n");
        $ret = 0;
        goto _END_CompareFile;
    }
    
    my @szContents_Base = <$hBaseFile>;
    close $hBaseFile;
    
    if ( ! open($hContents_Only_In_Base, ">$szContents_Only_In_Base") ) {
        print "Fail to open db contents file \"$szContents_Only_In_Base\"\n";
        Log::WriteLog("Fail to open db contents file \"$szContents_Only_In_Base\"\n");
        $ret = 0;
        goto _END_CompareFile;
    }
    #print $hContents_Only_In_Base "@szContents_Base";
    
    if ( ! open($hNewFile, "$szNewFilePath") ) {
        print "Fail to open db contents file \"$szNewFilePath\"\n";
        Log::WriteLog("Fail to open db contents file \"$szNewFilePath\"\n");
        $ret = 0;
        goto _END_CompareFile;
    }
    
    my @szContents_New = <$hNewFile>;
    close $hBaseFile;
    
    if ( ! open($hContents_Only_In_New, ">$szContents_Only_In_New") ) {
        print "Fail to open db contents file \"$szContents_Only_In_New\"\n";
        Log::WriteLog("Fail to open db contents file \"$szContents_Only_In_New\"\n");
        $ret = 0;
        goto _END_CompareFile;
    }
    
    my %hash_base=();
    my %hash_new=();
    
    for(my $i=0; $i<@szContents_Base; $i++) {
	$hash_base{$szContents_Base[$i]} = 1;
       # print "i=$i  $hash_base{$szContents_Base[$i]}\n";
    }
    
    for(my $i=0; $i<@szContents_New; $i++) {
	$hash_new{$szContents_New[$i]} = 1;
    }
    
    #my $j = 0;
    #my $flag = exists $hash_new{'$szContents_Base[$j]};
    #print "j=$j  $hash_base{'$szContents_Base[$j]'}  \n";
    #print "j=$j  $hash_base{'$szContents_Base[0]'}  \n";

    
    for(my $i=0; $i<@szContents_Base; $i++) {
        if( !exists $hash_new{$szContents_Base[$i]} ){
            print $hContents_Only_In_Base "line = $i : $szContents_Base[$i]\n";
        }
    }
    
    for(my $i=0; $i<@szContents_New; $i++) {
        if( !exists $hash_base{$szContents_New[$i]} ){
            print $hContents_Only_In_New "line = $i : $szContents_New[$i]\n";
        }
    }

    
_END_CompareFile:

    if ( $ret == 1 ) {
        Log::WriteLog("Succeed to compare file, base file is $szBaseFileName, new file is $szNewFileName\n");
    }
    else {
        Log::WriteLog("Fail to compare file, base file is $szBaseFileName, new file is $szNewFileName\n");
    }
    close $hContents_Only_In_Base;
    close $hContents_Only_In_New;
    return $ret;

}

sub QueryDBRow_array
{
    my ($szDBname, $statement) = @_;

    my $dbh = DBI->connect("dbi:SQLite:dbname=$szDBname", "", "");
    #my $sth = $dbh->prepare($statement);
    #my $rv = $sth->execute;
    #my $ary_ref = $sth->fetchall_arrayref({});
    my $ary_ref = $dbh->selectall_arrayref($statement, { Slice => {} });
    $dbh->disconnect;
    return $ary_ref;   
}

sub QueryDBRow_hash
{
    my ($szDBname, $statement, $key_field) = @_;

    my $dbh = DBI->connect("dbi:SQLite:dbname=$szDBname", "", "");
    my $hash_ref = $dbh->selectall_hashref($statement, $key_field);
    $dbh->disconnect;
    return $hash_ref;   
}

sub QueryDBCol_array
{
    my ($szDBname, $statement) = @_;

    my $dbh = DBI->connect("dbi:SQLite:dbname=$szDBname", "", "");
    my $ary_ref = $dbh->selectcol_arrayref($statement);
    $dbh->disconnect;
    
    return $ary_ref;
}

sub PrintTableContent
{
    my ($szDBname, $szTableName) = @_;
    
    Log::WriteLog("Begin to print table content\n");
    my $ret = 1;
    my $statement = "select * from $szTableName";
    
    my $hdbContests;
    if ( ! open($hdbContests, ">>$gszdbContents") ) {
        print "Fail to open db contents file \"$gszdbContents\"\n";
        Log::WriteLog("Fail to open db contents file \"$gszdbContents\"\n");
        $ret = 0;
        goto _END_PrintTableContent;
    }
    my $hTable;
    my $szTableContents = $gszContentsFolder . $szTableName . ".txt";
    
    if ( ! open($hTable, ">>$szTableContents") ) {
        print "Fail to open table contents file \"$szTableContents\"\n";
        Log::WriteLog("Fail to open table contents file \"$szTableContents\"\n");
        $ret = 0;
        goto _END_PrintTable;
    }
    
    if($szTableName eq "TFileNameFTS4")
    {
	$statement = "select FileID, FileName from TFileMeta, TFileName where TFileMeta.FileNameID==TFileName.FileNameID";
    }
    if($szTableName eq "TFilePathFTS4"){
        $statement = "select FileID, FileFolder, FileName from TFileMeta, TFileName, TFileFolder where TFileMeta.FileNameID==TFileName.FileNameID and TFileMeta.FileFolderID ==TFileFolder.FileFolderID";
    }
    
 #   print "print table content statement=$statement\n";
    Log::WriteLog("print table content statement=$statement\n");


    my $dbh = DBI->connect("dbi:SQLite:dbname=$szDBname", "", "");
    
    my $sth = $dbh->prepare($statement);
    my $rv = $sth->execute();
    my @row_ary;
    
    my $line = 1;
    while (@row_ary = $sth->fetchrow_array ){
      # print "@row_ary\n";
     #  print $hdbContests "@row_ary\n";
        
        
        if($szTableName eq "TFilePathFTS4"){
            #printf("%-17d  ",$line);
            printf $hdbContests("%-17d  ",$line);
            printf $hTable("%-17d  ",$line);
            $line++;
            
            printf $hdbContests("%-17s  ",$row_ary[0]);
            printf $hTable("%-17s  ",$row_ary[0]);
            if($row_ary[1] eq "."){
                printf $hdbContests("%-17s  ",$row_ary[2]);
                printf $hTable("%-17s  ",$row_ary[2]);
            }
            else{
                printf $hdbContests("%-17s  ",$row_ary[1]. "/" . $row_ary[2]);
                printf $hTable("%-17s  ",$row_ary[1]. "/" . $row_ary[2]);
            }
        }
        else{
           # printf("%-17d  ",$line);
            printf $hdbContests("%-17d  ",$line);
            printf $hTable("%-17d  ",$line);
            $line++;
            
            for(my $i=0; $i<@row_ary; $i++) {
                
                
                
                if (!defined $row_ary[$i]) {
                    #print "<null>\t";
                    #print $hdbContests "<null>\t";
                    
               #     printf("%-17s  ","<null>");
                    printf $hdbContests("%-17s  ","<null>");
                    printf $hTable("%-17s  ","<null>");
                }
                else {
                    #print "$row_ary[$i]\t";
                    #print $hdbContests "$row_ary[$i]\t";
                    
               #     printf("%-17s  ",$row_ary[$i]);
                    printf $hdbContests("%-17s  ",$row_ary[$i]);
                    printf $hTable("%-17s  ",$row_ary[$i]);
                }
            }
        }
       
       # print "\n";
        print $hdbContests "\n";
        print $hTable "\n";
    }
    $dbh->disconnect;
    close($hdbContests);
    close($hTable);
    
_END_PrintTableContent:

    if ( $ret == 1 ) {
        Log::WriteLog("Succeed to print table content\n");
    }
    else {
        Log::WriteLog("Fail to print table content\n");
    }
    return $ret;

}

sub PrintTable
{
    my ($szDBname, $szTableName) = @_;
    my $ret = 1;
    
    Log::WriteLog("Begin to print table, $szTableName\n");
    
    $ret = CheckTableExist($szDBname, $szTableName);
    if($ret == 0){
	print "Table \"$szTableName\" not exist\n";
        Log::WriteLog("Table \"$szTableName\" not exist\n");
        goto _END_PrintTable;
    }
    
    ####something wrong DBD:: SQLite:: db prepare failed: no such module: fts4
    if( index($szTableName,"_") != -1){
        goto _END_PrintTable;
    }
    
    #my $sz
    
    my $hdbContests;
    if ( ! open($hdbContests, ">>$gszdbContents") ) {
        print "Fail to open db contents file \"$gszdbContents\"\n";
        Log::WriteLog("Fail to open db contents file \"$gszdbContents\"\n");
        $ret = 0;
        goto _END_PrintTable;
    }
    
    my $hTable;
    my $szTableContents = $gszContentsFolder . $szTableName . ".txt";
    
    if ( ! open($hTable, ">$szTableContents") ) {
        print "Fail to open table contents file \"$szTableContents\"\n";
        Log::WriteLog("Fail to open table contents file \"$szTableContents\"\n");
        $ret = 0;
        goto _END_PrintTable;
    }
   
    my $dbh = DBI->connect("dbi:SQLite:dbname=$szDBname", "", "");
    my $statement = "PRAGMA table_info ($szTableName)";
    if($szTableName eq "TFileNameFTS4")
    {
	$statement = "select FileID, FileName from TFileMeta, TFileName where TFileMeta.FileNameID==TFileName.FileNameID";
    }
    if($szTableName eq "TFilePathFTS4"){
        $statement = "select FileID, FileFolder, FileName from TFileMeta, TFileName, TFileFolder where TFileMeta.FileNameID==TFileName.FileNameID and TFileMeta.FileFolderID ==TFileFolder.FileFolderID";
    }
    
    print "list tableinfo statement:$statement\n";
    Log::WriteLog("list tableinfo statement:$statement\n");
    
  #  print "\n$szTableName\n";
    print $hdbContests "\n$szTableName\n";
    print $hTable "$szTableName\n";

    
    my $sth = $dbh->prepare($statement);
    my $rv = $sth->execute();
    my @row_ary;
    
   # printf("%-17s  ","RecNo");
    printf $hdbContests("%-17s  ","RecNo");
    printf $hTable("%-17s  ","RecNo");
        
    if($szTableName eq "TFileNameFTS4")
    {
      #  printf("%-17s  ","FileID");
        printf $hdbContests("%-17s  ","FileID");
        printf $hTable("%-17s  ","FileID");
            
       # printf("%-17s  ","FileName");
        printf $hdbContests("%-17s  ","FileName");
        printf $hTable("%-17s  ","FileName");
    }
    elsif($szTableName eq "TFilePathFTS4"){
      #  printf("%-17s  ","FileID");
        printf $hdbContests("%-17s  ","FileID");
        printf $hTable("%-17s  ","FileID");
            
       # printf("%-17s  ","FilePath");
        printf $hdbContests("%-17s  ","FilePath");
        printf $hTable("%-17s  ","FilePath");
    }
    else{
        while (@row_ary = $sth->fetchrow_array ){
            #print "$row_ary[1]\t";
            #print $hdbContests "$row_ary[1]\t";
            #printf("%-17s  ",$row_ary[1]);
            printf $hdbContests("%-17s  ",$row_ary[1]);
            printf $hTable("%-17s  ",$row_ary[1]);
        }
    }
    
    print $hdbContests "\n";
    print $hTable "\n";

   # print "\n";
    close($hdbContests);
    close($hTable);

    $dbh->disconnect;

    $ret = PrintTableContent($szDBname, $szTableName);
    if($ret == 0){
        goto _END_PrintTable;
    }
    
_END_PrintTable:

    if ( $ret == 1 ) {
        Log::WriteLog("Succeed to print table, $szTableName\n");
    }
    else {
        Log::WriteLog("Fail to print table, $szTableName\n");
    }
    return $ret;
}

sub QueryDB
{
    my ($szDBname, $statement) = @_;

    my $dbh = DBI->connect("dbi:SQLite:dbname=$szDBname", "", "");
    my $sth = $dbh->prepare($statement);
    my $rv = $sth->execute;
    my $ary_ref = $sth->fetchall_arrayref({});
    $dbh->disconnect;
    return $ary_ref;   
}

sub CheckTableExist
{
    my ($szDBname, $szTablename) = @_;
    
    my $dbh = DBI->connect("dbi:SQLite:dbname=$szDBname", "", "");
    my $ary_ref = $dbh->selectrow_arrayref
                ("SELECT name FROM sqlite_master WHERE (type=\'table\' or type=\'view\') and name=\'$szTablename\'");
    $dbh->disconnect;
    
    if (!defined $ary_ref || @$ary_ref == 0) {
        return 0;
    }
    return 1;
    
}

1;
