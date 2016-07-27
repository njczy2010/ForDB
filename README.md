# ForDB
Enum DB and Compare two DBs

## 功能：  
1. 把sqlite数据库里面所有表的内容导出到一个文本中方便查看  
2. 有两个数据库，把diff的部分导出到文本中  

## 准备：  
安装ActivePerl-5.10.1.1007-MSWin32-x86-291969.msi  

## 对于1：  
主程序是：ForEnumDB.pl  
进入当前路径，需要传参数 $gszdbPath  

示例：perl ForEnumDB.pl   C:\Users\Administrator\Desktop\ForDB\MBG.db  

文件夹contents/数据库名 里放的是每个表的内容  
文件夹report 里放的是程序的log以及 所有表的内容  

sum_数据库名_contents.txt 是 所有表的内容  
Main.log 放的是程序的log，采用追加的方式，不会清空上次跑的结果  

## 对于2：  
主程序是：CompareDB.pl  

需要传参数  $gszBasedbName,  $gszNewdbName  
  
示例：perl CompareDB.pl   C:\Users\Administrator\Desktop\ForDB\MBG.db   C:\Users\Administrator\Desktop\ForDB\MBG2.db  

文件夹contents 里放的是比较的详细结果（内容一致的表暂时没放进去，只放了内容不一致的）  
文件夹report 里放的是程序的log以及 汇总情况  

sum_result_MBG_with_MBG2.txt 是所有表的对比情况  
different_result_MBG_with_MBG2.txt 是不同表的对比情况  

Main.log 放的是程序的log，采用追加的方式，不会清空上次跑的结果  

## Step  
### step1 : 把表查出来  

    my $statement = "select name from sqlite_master where type=\"table\" ORDER BY \"name\"";

[http://blog.sina.com.cn/s/blog_6afeac500100yn9k.html][1]

SQLite数据库中一个特殊的名叫 SQLITE_MASTER   上执行一个SELECT查询以获得所有表的索引。每一个 SQLite 数据库都有一个叫 SQLITE_MASTER 的表， 它定义数据库的模式。  

对于表来说，type 字段永远是 ‘table’，name字段永远是表的名字。所以，要获得数据库中所有表的列表， 使用下列SELECT语句：  

    SELECT name FROM sqlite_master
    WHERE type=’table’
    ORDER BY name;

SQLITE_MASTER 表是只读的。不能对它使用 UPDATE、INSERT 或 DELETE。 它会被 CREATE TABLE、CREATE INDEX、DROP TABLE 和 DROP INDEX 命令自动更新。  

临时表不会出现在 SQLITE_MASTER 表中。临时表及其索引和触发器存放在另外一个叫 SQLITE_TEMP_MASTER 的表中。SQLITE_TEMP_MASTER 跟 SQLITE_MASTER 差不多， 但它只是对于创建那些临时表的应用可见。如果要获得所有表的列表， 不管是永久的还是临时的，可以使用类似下面的命令：  

    SELECT name FROM
    (SELECT * FROM sqlite_master UNION ALL
    SELECT * FROM sqlite_temp_master)
    WHERE type=’table’
    ORDER BY name

### step2:输出表的基本信息（表头）  

    use DBI;
    
    my $dbh = DBI->connect("dbi:SQLite:dbname=$szDBname", "", "");
    my $statement = "PRAGMA table_info ($szTableName)";
     
    my $sth = $dbh->prepare($statement);
    my $rv = $sth->execute();
    my @row_ary;
     
    while (@row_ary = $sth->fetchrow_array ){
        #print "$row_ary[1]\t";
        #print $hdbContests "$row_ary[1]\t";
        #printf("%-17s  ",$row_ary[1]);
        printf $hdbContests("%-17s  ",$row_ary[1]);
        printf $hTable("%-17s  ",$row_ary[1]);
    }

PRAGMA语句是SQLITE数据的SQL扩展，是它独有的特性，主要用于修改SQLITE库或者内数据查询的操作。  

PRAGMA table_info(table-name);   
返回表的基本信息   

## 问题  
1. 输出到excel？  
reply： 
.csv   逗号分隔  

2. 如何比较diff?  
reply：  
比较diff部分采用了字符串哈希的思路  
虚表问题采用了select from语句“实现”  

3. CompareTables 比较表内容时，如果表不存在怎么办？
reply：  
调用ForEnumDB里函数，打印数据库的相应内容    


    if( ! (-e $szBaseFilePath) ){
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

4. 虚表如何解决  
reply: 
用sql语句模拟虚表构建过程，查询出来  

    if($szTableName eq "TFileNameFTS4")
    {
        $statement = "select FileID, FileName from TFileMeta, TFileName where TFileMeta.FileNameID==TFileName.FileNameID";
    }
    
    if($szTableName eq "TFilePathFTS4"){
        $statement = "select FileID, FileFolder, FileName from TFileMeta, TFileName, TFileFolder where TFileMeta.FileNameID==TFileName.FileNameID and TFileMeta.FileFolderID ==TFileFolder.FileFolderID";
    }

  [1]: http://blog.sina.com.cn/s/blog_6afeac500100yn9k.html
