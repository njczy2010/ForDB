package Variables;
use strict;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(
                    $rootPath
                    $gszLogFilename
                    $gszdbContents
                    
                    $gszdbFolder
                    $gszBasedbFolder
                    $gszNewdbFolder
                    
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

#Information of program
#Need to change $rootPath, $gszdbName ,$gszBasedbName, $gszNewdbName

our $rootPath = "D:\\czy\\work\\ForDB\\";

#Use for print table
our $gszdbName = "MBG2.db";
our $gszdbPath = $rootPath . $gszdbName;

our $gszdbFolder = "";
our $gszBasedbFolder = "";
our $gszNewdbFolder = "";

#Use for compare two tables

our $gszBasedbName = "MBG.db";
our $gszNewdbName = "MBG2.db";

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

#Use for compare two tables

our $gszBasedbPath = $rootPath . $gszBasedbName;
our $gszNewdbPath = $rootPath . $gszNewdbName;

#our $gszContents_Only_In_Base = $gszReportFolder . "content_only_in_" . $gszBasedbName;
#our $gszContents_Only_In_New = $gszReportFolder . "content_only_in_" . $gszNewdbName;

our $gszDifferent_Result = $gszReportFolder . "different_result_" . substr($gszBasedbName,0,-3). "_with_" . substr($gszNewdbName,0,-3) . ".txt";
our $gszSum_Result = $gszReportFolder . "sum_result_" . substr($gszBasedbName,0,-3). "_with_" . substr($gszNewdbName,0,-3) . ".txt";

our $giDifferent_Table_Count = 0;
our $giSame_Table_Count = 0;

1;

