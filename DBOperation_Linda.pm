package DBOperation;
use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(
    QueryDBRow_array
    QueryDBRow_hash
    QueryDBCol_array
    QueryDB
    PrintTable
    PrintTableContent
    CheckTableExist);

use DBI;
use Log;

use Variables qw(
                $rootPath
                
                $gszLogFilename
                $gszResultFilename
                );

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
    my $hResultFile;
    if ( ! open($hResultFile, ">>$gszResultFilename") ) {
        print "Fail to open result file \"$gszResultFilename\"\n";
        Log::WriteLog("Fail to open result file \"$gszResultFilename\"\n");
        $ret = 0;
        goto _END_PrintTableContent;
    }
    
    print "print table content statement=$statement\n";
    Log::WriteLog("print table content statement=$statement\n");


    my $dbh = DBI->connect("dbi:SQLite:dbname=$szDBname", "", "");
	
	if($szTableName eq "TFilePathFTS4")
	{
	
		#s$statement = "select * from \"$szTableName\" ";
		$statement = "select FileID, FileName from TFileMeta, TFileName where TFileMeta.FileNameID==TFileName.FileNameID";
		print "statement:$statement\n";		
	}
	if($szTableName eq "TFilePathFTS4"){
        $statement = "select FileID, FileFolder, FileName from TFileMeta, TFileName, TFileFolder where TFileMeta.FileNameID==TFileName.FileNameID and TFileMeta.FileFolderID ==TFileFolder.FileFolderID";
		print "statement:$statement\n";	
    }    

    my $sth = $dbh->prepare($statement);
    my $rv = $sth->execute();
    my @row_ary;
    while (@row_ary = $sth->fetchrow_array ){
      # print "@row_ary\n";
     #  print $hResultFile "@row_ary\n";
       
       for(my $i=0; $i<@row_ary; $i++) {
		
            if (!defined $row_ary[$i]) {
                #print "<null>\t";
                #print $hResultFile "<null>\t";
                
                printf("%-17s  ","<null>");
                printf $hResultFile("%-17s  ","<null>");
            }
            else {
                #print "$row_ary[$i]\t";
                #print $hResultFile "$row_ary[$i]\t";
                
                printf("%-17s  ",$row_ary[$i]);
                printf $hResultFile("%-17s  ",$row_ary[$i]);
            }
        }
       
        print "\n";
        print $hResultFile "\n";
    }
    $dbh->disconnect;
    close($hResultFile);
    
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
        goto _END_PrintTable;
    }
    
    ####something wrong DBD:: SQLite:: db prepare failed: no such module: fts4
      
    my $hResultFile;
    if ( ! open($hResultFile, ">>$gszResultFilename") ) {
        print "Fail to open result file \"$gszResultFilename\"\n";
        Log::WriteLog("Fail to open result file \"$gszResultFilename\"\n");
        $ret = 0;
        goto _END_PrintTable;
    }
   
    my $dbh = DBI->connect("dbi:SQLite:dbname=$szDBname", "", "");
    my $statement = "PRAGMA table_info ($szTableName)";
    print "list tableinfo statement:$statement\n";
    Log::WriteLog("list tableinfo statement:$statement\n");
    print "statement:$statement\n";
	if($szTableName eq "TFilePathFTS4")
	{
	
		#s$statement = "select * from \"$szTableName\" ";
		$statement = "select FileID, FileName from TFileMeta, TFileName where TFileMeta.FileNameID==TFileName.FileNameID";
		print "statement:$statement\n";		
	}
	if($szTableName eq "TFilePathFTS4"){
        $statement = "select FileID, FileFolder, FileName from TFileMeta, TFileName, TFileFolder where TFileMeta.FileNameID==TFileName.FileNameID and TFileMeta.FileFolderID ==TFileFolder.FileFolderID";
		print "statement:$statement\n";	
    }    

    my $sth = $dbh->prepare($statement);
    my $rv = $sth->execute();
    my @row_ary;
    while (@row_ary = $sth->fetchrow_array ){
        #print "$row_ary[1]\t";
        #print $hResultFile "$row_ary[1]\t";
        printf("%-17s  ",$row_ary[1]);
        printf $hResultFile("%-17s  ",$row_ary[1]);

    }
    print $hResultFile "\n";

    print "\n";
    close($hResultFile);

    $dbh->disconnect;

    #$statement = "SELECT * FROM $szTableName";

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
