package Initialize;
use strict;

use ForEnumDB;
use DBI;
use Log;
use FileOperation;

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
                    
                    $gszCompareLogFilename
                    $gszCompareFolder
                    
                    $gszReportFolder
                    $gszParentContentsFolder
                    $gszContentsFolder
                    
                    $gszBasedbContentsFolder
                    $gszNewdbContentsFolder
                    
                    $gszdbName
                    $gszBasedbName
                    $gszNewdbName
                    
                    $gszdbPath
                    $gszBasedbPath
                    $gszNewdbPath
                                        
                    $gszDifferent_Result
                    $gszSum_Result
                    
                    $giDifferent_Table_Count
                    $giSame_Table_Count
                );
                
sub InitializeVariables
{
    #Use for print table
    
    #Use for compare two tables
    
    #Result file path
    our $gszReportFolder = $rootPath . "report\\";
    our $gszParentContentsFolder = $rootPath . "contents\\";
    our $gszContentsFolder = $gszParentContentsFolder . substr($gszdbName,0,-3) . "\\";
    
    our $gszBasedbContentsFolder = $gszParentContentsFolder . substr($gszBasedbName,0,-3) . "\\";
    our $gszNewdbContentsFolder = $gszParentContentsFolder . substr($gszNewdbName,0,-3) . "\\";
    
    
    our $gszdbContents = $gszReportFolder . "sum_" . substr($gszdbName,0,-3). "_contents.txt";
    
    our $gszLogFilename = $gszReportFolder . "Main.log";
    #our $gszLogFilename = $gszReportFolder . substr($gszdbName,0,-3) . "_ForEnumDB.log";
    
    our $gszCompareLogFilename = $gszReportFolder . "Compare_" . substr($gszBasedbName,0,-3). "_with_" .substr($gszNewdbName,0,-3) . ".log";
    our $gszCompareFolder = $gszParentContentsFolder . "Compare_" . substr($gszBasedbName,0,-3). "_with_" .substr($gszNewdbName,0,-3) . "\\";
    
    
    #our $gszContents_Only_In_Base = $gszReportFolder . "content_only_in_" . $gszBasedbName;
    #our $gszContents_Only_In_New = $gszReportFolder . "content_only_in_" . $gszNewdbName;
    
    our $gszDifferent_Result = $gszReportFolder . "different_result_" . substr($gszBasedbName,0,-3). "_with_" . substr($gszNewdbName,0,-3) . ".txt";
    our $gszSum_Result = $gszReportFolder . "sum_result_" . substr($gszBasedbName,0,-3). "_with_" . substr($gszNewdbName,0,-3) . ".txt";
    
    our $giDifferent_Table_Count = 0;
    our $giSame_Table_Count = 0;
}

                


1;


                