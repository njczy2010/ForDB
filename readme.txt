功能：

1. 把sqlite数据库里面所有表的内容导出到一个文本中方便我查看
2. 有两个数据库，把diff的部分导出到文本中

准备：

安装ActivePerl-5.10.1.1007-MSWin32-x86-291969.msi

对于1：

主程序是：ForEnumDB.pl

进入当前路径，需要传参数 $gszdbPath

示例：perl ForEnumDB.pl C:\Users\Administrator\Desktop\ForDB\MBG.db


文件夹contents/数据库名 里放的是每个表的内容
文件夹report 里放的是程序的log以及 所有表的内容

sum_数据库名_contents.txt 是 所有表的内容
Main.log 放的是程序的log，采用追加的方式，不会清空上次跑的结果

对于2：

主程序是：CompareDB.pl

需要传参数  $gszBasedbName, $gszNewdbName

示例：perl CompareDB.pl C:\Users\Administrator\Desktop\ForDB\MBG.db C:\Users\Administrator\Desktop\ForDB\MBG2.db


文件夹contents 里放的是比较的详细结果（内容一致的表暂时没放进去，只放了内容不一致的）
文件夹report 里放的是程序的log以及 汇总情况

sum_result_MBG_with_MBG2.txt 是所有表的对比情况
different_result_MBG_with_MBG2.txt 是不同表的对比情况

Main.log 放的是程序的log，采用追加的方式，不会清空上次跑的结果
