package ForEnumDB;

use strict;
use warnings;

#use CheckResult::OutputResult qw (
   # WriteError);
    #CheckResultBegin);
    #CheckResultEnd);
use DBOperation qw(
    CheckTableExist
    QueryDBRow_array
    QueryDBRow_hash
    QueryDBCol_array);
#use CheckResult::CheckResult qw(ParseFileStorageHash);
#use CommonFunc::MyCommon qw(SearchMessage ParseLogInfoSequence);
#use Tie::IxHash;
#use Config::IniFiles;

use Variables qw(
                $rootPath
                
                $gszLogFilename
                $gszdbContents
                );

my $BackupFileTable = 'BackupFile';
my $EditionTable = 'Edition';
my $FileEditionView = 'View_FileEdition';



sub CompareEnumFiles
{
    my ($ary_expectList, $ary_resultList) = @_;
    
    for(my $i=0; $i<@$ary_expectList; $i++) {
		
        if (!defined $$ary_resultList[$i] || $$ary_expectList[$i] ne $$ary_resultList[$i]{'EnumFiles'}) {
            WriteError("Miss 'EnumFiles' $$ary_expectList[$i]");
        }
        else {
            $$ary_resultList[$i]{Checked} = 1;
        }
    }
    
    foreach my $item (@$ary_resultList) {
        if (!exists $$item{Checked}) {
            WriteError("Odd 'EnumFiles' $$item{'EnumFiles'}");
        }
    }
}

sub CheckEnumFiles
{
    my ($szDBname, $hash_ini, $ary_result) = @_;
    
    if (0 == CheckTableExist($szDBname, $FileEditionView)) {
        return;
    }
    
    my $statement = "SELECT FileName FROM $BackupFileTable";
    if (exists $$hash_ini{LoopCount}) {
        $statement .= " Limit $$hash_ini{LoopCount}";
    }
    print "statement:$statement\n";
	
    my $ary_files = QueryDBCol_array($szDBname, $statement);
    
    CompareEnumFiles($ary_files, $ary_result);
}

sub CheckEnumBackupFiles
{
    my ($szDBname, $hash_ini, $ary_result) = @_;
    
    if (0 == CheckTableExist($szDBname, $FileEditionView)) {
        return;
    }
    
    my $statement = "SELECT FileName FROM $FileEditionView WHERE TimeStamp BETWEEN $$hash_ini{StartTime} AND $$hash_ini{EndTime}";
    if (exists $$hash_ini{LoopCount}) {
        $statement .= " Limit $$hash_ini{LoopCount}";
    }
    my $ary_files = QueryDBCol_array($szDBname, $statement);

    CompareEnumFiles($ary_files, $ary_result);
}

sub CheckEnumEditions
{
    my ($szDBname, $hash_ini, $ary_result, $szResultFolder) = @_;
    if (0 == CheckTableExist($szDBname, $FileEditionView)) {
        return;
    }

    
    #my $statement = "SELECT EditionID, BackupName, PurgeAlgorithmID FROM $FileEditionView WHERE FileName like \"$$hash_ini{File}\" AND PurgeAlgorithmID IN (0,1000) Order By TimeStamp Desc ";
	my $statement = "SELECT EditionID, BackupName, PurgeAlgorithmID FROM $FileEditionView WHERE FileName like \"$$hash_ini{File}\" AND PurgeAlgorithmID IN (0,1000) Order By \"TimeStamps\" Desc";
    if (exists $$hash_ini{LoopCount}) {
        $statement .= " Limit $$hash_ini{LoopCount}";
    }
	print "statement:$statement\n";
	#getc;
    my $ary_editions = QueryDBRow_array($szDBname, $statement);
    
    my $hash_editionSha1 = ParseExpectResult("$szResultFolder\\expectedResult.log");
  	##jason keep the sequence

  	my $szLCFile = lc($$hash_ini{File});
  	my @ary_fileEditionSha1;
  	$#ary_fileEditionSha1 = $#$ary_editions;
	
  	if(defined @{$$hash_editionSha1{$szLCFile}}){
  	   @ary_fileEditionSha1 = reverse @{$$hash_editionSha1{$szLCFile}};   
	   
  	}  	  	
    print "@ary_fileEditionSha1";
    my $href_fileHashs = ParseFileStorageHash("$szResultFolder\\hash.txt");
    
    for(my $i=0; $i<@$ary_editions; $i++) {
    	
        if (!exists $$href_fileHashs{lc($$ary_editions[$i]{BackupName})}
            && 1000 != $$ary_editions[$i]{PurgeAlgorithmID} ) {
            next;
        }
#        if (!defined $$ary_result[$i] || $$ary_editions[$i]{EditionID} ne $$ary_result[$i]{EnumEditions}) {
	    if (!defined $$ary_result[$i]) {
	    	if(exists $$hash_editionSha1{$$hash_ini{File}}){
            	WriteError("Miss Edition $$ary_editions[$i]{EditionID}");
	    	}
        }
        else {
        	
            $$ary_result[$i]{Checked} = 1;
        
            if (! exists $$ary_result[$i]{Sha1}
              || $$ary_result[$i]{Sha1} ne $ary_fileEditionSha1[$i]  ) { 
				#print "1:$$ary_result[$i]{Sha1}\n";
			  ##keep sequence             	
			    #print "$i: $ary_fileEditionSha1[$i]\n";
                WriteError("Wrong Edition $$ary_editions[$i]{EditionID}");
            }
            elsif (exists $$hash_ini{SHA1} && $$ary_result[$i]{Sha1} eq $$hash_ini{SHA1}) {
                ## Check delete edition
                if ($$ary_editions[$i]{PurgeAlgorithmID} != 1000) {
                    WriteError("Not delete Edition $$ary_editions[$i]{EditionID}");
                }
                elsif (exists $$href_fileHashs{$$ary_editions[$i]{BackupName}}) {
                    WriteError("Fail to delete Edition $$ary_editions[$i]{EditionID}, $$ary_editions[$i]{BackupName}");
                }
            }
        }
    }
    
    foreach my $item (@$ary_result) {
        if (!exists $$item{Checked}) {
            WriteError("Odd Edition SHA1 $$item{Sha1}");
        }
    }
}

sub CheckEnumEditionsInMemory
{
    my ($szDBname, $hash_ini, $ary_result, $szResultFolder) = @_;
    if (0 == CheckTableExist($szDBname, $FileEditionView)) {
        return;
    }
    
    my $statement = "SELECT EditionID, BackupName, PurgeAlgorithmID FROM $FileEditionView WHERE FileName like \"$$hash_ini{File}\" AND PurgeAlgorithmID IN (0,1000) Order By TimeStamp Desc ";
    if (exists $$hash_ini{LoopCount}) {
        $statement .= " Limit $$hash_ini{LoopCount}";
    }
    my $ary_editions = QueryDBRow_array($szDBname, $statement);
    
    my $hash_editionSha1 = ParseExpectResult("$szResultFolder\\expectedResult.log");
  	##jason keep the sequence

  	my $szLCFile = lc($$hash_ini{File});
  	my @ary_fileEditionSha1;
  	$#ary_fileEditionSha1 = $#$ary_editions;
  	if(defined @{$$hash_editionSha1{$szLCFile}}){
  	   @ary_fileEditionSha1 = reverse @{$$hash_editionSha1{$szLCFile}};
  	}  	
  	#print "@{$$hash_editionSha1{$szLCFile}}";getc();
    #print "@ary_fileEditionSha1";getc();
    my $href_fileHashs = ParseFileStorageHash("$szResultFolder\\hash.txt");
    
    for(my $i=0; $i<@$ary_editions; $i++) {
    	
        if (!exists $$href_fileHashs{lc($$ary_editions[$i]{BackupName})}
            && 1000 != $$ary_editions[$i]{PurgeAlgorithmID} ) {
            next;
        }
#        if (!defined $$ary_result[$i] || $$ary_editions[$i]{EditionID} ne $$ary_result[$i]{EnumEditions}) {
	    if (!defined $$ary_result[$i]) {
	    	if(exists $$hash_editionSha1{$$hash_ini{File}}){
            	WriteError("Miss Edition $$ary_editions[$i]{EditionID}");
	    	}
        }
        else {
        	
            $$ary_result[$i]{Checked} = 1;
        
            if (! exists $$ary_result[$i]{Sha1}
              || $$ary_result[$i]{Sha1} ne $ary_fileEditionSha1[$i]  ) {  ##keep sequence             	
                WriteError("Wrong Edition $$ary_editions[$i]{EditionID}");
            }
            elsif (exists $$hash_ini{SHA1} && $$ary_result[$i]{Sha1} eq $$hash_ini{SHA1}) {
                ## Check delete edition
                if ($$ary_editions[$i]{PurgeAlgorithmID} == 1000) {
                    WriteError("Delete Edition $$ary_editions[$i]{EditionID}");
                }
                elsif (! exists $$href_fileHashs{$$ary_editions[$i]{BackupName}}) {
                    WriteError("success to delete Edition $$ary_editions[$i]{EditionID}, $$ary_editions[$i]{BackupName}");
                }
            }
        }
    }
    
    foreach my $item (@$ary_result) {
        if (!exists $$item{Checked}) {
            WriteError("Odd Edition SHA1 $$item{Sha1}");
        }
    }
}
sub CheckDeleteEditions
{
    my ($szDBname, $hash_ini, $ary_result, $szResultFolder) = @_;
    
    if (0 == CheckTableExist($szDBname, $FileEditionView)) {
        return;
    }
    
    my $statement = "SELECT EditionID, BackupName, PurgeAlgorithmID FROM $FileEditionView WHERE PurgeAlgorithmID = 1000";
    my $hash_editions = QueryDBRow_hash($szDBname, $statement, 'EditionID');
    
    my $href_fileHashs = ParseFileStorageHash("$szResultFolder\\hash.txt");
    
    foreach (@$ary_result) {
        my $id = $$_{DeleteId};
        if (!exists $$hash_editions{$id}) {
            WriteError("Not delete Edition $id");
        }
        else {
            $$hash_editions{$id}{Checked} = 1;
            if (exists $$href_fileHashs{$$hash_editions{$id}{BackupName}}) {
                WriteError("Fail to delete Edition $id, $$hash_editions{$id}{BackupName}");
            }
        }
    }
        
    foreach my $item (values %$hash_editions) {
        if (!exists $$item{Checked}) {
            WriteError("Odd delete edition $$item{EditionID}");
        }
    }
}

sub CheckRestoreEditions
{
    my ($szDBname, $hash_ini, $ary_result, $szResultFolder) = @_;

 	my $href_expectResult = ParseExpectResult("$szResultFolder\\expectedResult.log");
    
    my $expectResultFile = undef;
    my $expectResultFilename = undef;
    my $expectFileSHA1 = undef;
    
	 if (exists $$href_expectResult{Restore}) {
	        foreach $expectResultFile (@{$$href_expectResult{Restore}}) {
	            $expectFileSHA1 = $$expectResultFile{SHA1};
	            $expectResultFilename = $$expectResultFile{Filename};
	            
	            if (!-e $expectResultFilename) {
	                WriteError('Fail to restore file ', $expectResultFilename);
	                next;
	            }
	            open(FILE, $expectResultFilename) or die "Can't open '$expectResultFilename': $!";
	            binmode(FILE);
	            my $szFileSHA1 = Digest::SHA1->new->addfile(*FILE)->hexdigest;
	            close(FILE);
	            
	            if ($expectFileSHA1 ne $szFileSHA1) {
	                WriteError('Wrong restore file ', $expectResultFilename,
	                           ', Sha1 is ', $szFileSHA1,
	                           ', expect Sha1 is ', $expectFileSHA1);
	                next;
	            }
	        }
	    }
}


sub ParseExpectResult
{
    my ($szFilename) = @_;
    
    open FILE, $szFilename;
    binmode(FILE, ':encoding(utf8)');
    my @szContent = <FILE>;
    close FILE;
    
    chomp @szContent;
    
    my %expectResult;
    tie %expectResult, 'Tie::IxHash';
    foreach my $szLine (@szContent) {
        next if (1 != $szLine =~ /^\[EnumDB\] (.*) ([0-9a-f]{40}) $/);
        
        push @{$expectResult{$1}}, $2;

    }
    
    return \%expectResult;
}

sub ParseResultLog
{
    my ($szLogFile) = @_;
    
    open FILE, $szLogFile;
    binmode(FILE, ':encoding(utf8)');
    my @szContent = <FILE>;
    close FILE;
    
    chomp @szContent;
    
    my @keys=();
    my @values=();
    my ($num) = $szContent[0]=~/Thread count = (\d+)/;
    for (my $i=1; $i<@szContent; $i++) {
        if(1 == $szContent[$i]=~/^Thread(\d+) = (.*)$/) {
            $keys[$1] = $2;
            next;
        }
        
        my ($tIndex) = $szContent[$i]=~/^\[Thread(\d+)\].*$/;
        if (defined $tIndex && defined  $keys[$tIndex]) {
            if ($keys[$tIndex] eq 'EnumFiles' || $keys[$tIndex] eq 'EnumBackupFiles') {
                if (1 == $szContent[$i]=~/\[Thread\d+\]\[\d+\] EnumFiles \"(.*)\"/) {
					push @{$values[$tIndex]}, {EnumFiles => $1};
					
                }
            }
            elsif ( ($keys[$tIndex] eq 'EnumEditions') || ($keys[$tIndex] eq 'EnumEditionsWait') ) {
                if (1 == $szContent[$i]=~/\[Thread\d+\]\[\d+\] EnumEditions ([0-9a-f]{0,40}) ([0-9a-f]{0,40}) \".*$/) {
					if ($szContent[$i]=~ /for/i)
					{						
					}
					else
					{ 					    
						push @{$values[$tIndex]}, {Sha1 =>$2};
					}
                    
                }               
            }
            elsif ($keys[$tIndex] eq 'RestoreById' || $keys[$tIndex] eq 'RestoreById_Only') {
                if (1 == $szContent[$i]=~/\[\d+\] Succeed to restore file .* edition, id (\d+)$/) {
                    push @{$values[$tIndex]}, {RestoreId => $1};					
                }               
            }
            elsif ($keys[$tIndex] eq 'DeleteById' || $keys[$tIndex] eq 'DeleteById_Only') {
                if (1 == $szContent[$i]=~/\[Thread\d+\]\[\d+\] DeleteById (\d+).*$/) {
                    push @{$values[$tIndex]}, {DeleteId => $1};					
                }               
            }			
        }
    }

    return \@values;
}

sub CheckResult
{
    my ($CaseId, $szResultFolder, $ref_CheckInfo) = @_;
	print "$CaseId, $szResultFolder\n";
    my $szCheckDeleteEdition;
    #print "$szCheckDeleteEdition";getc();
    CheckResultBegin(@_);
    if(defined $ref_CheckInfo){
    	CheckLog($szResultFolder, $$ref_CheckInfo{"logInfo"});
    	$szCheckDeleteEdition = $$ref_CheckInfo{"checkDeleteEdition"};
    }
    my $DBname = "$szResultFolder\\BackupDB.s3db";
    
    my $ary_result = ParseResultLog("$szResultFolder\\TestRestore.log");
    
    my %hash_ini;
    tie %hash_ini, 'Config::IniFiles', ( -file => "$szResultFolder\\TestRestore.ini" );

    my $num = $hash_ini{Basic}{ThreadCount};
    for(my $i=1; $i<=$num; $i++) {
        if (!defined $hash_ini{"Thread$i"}{Type}
            || 'Restore' eq $hash_ini{"Thread$i"}{Type}) {
            print "restore\n";
        }
        elsif ('EnumFiles' eq $hash_ini{"Thread$i"}{Type}) {
            CheckEnumFiles($DBname, $hash_ini{"Thread$i"}, $$ary_result[$i]);
        }
        elsif ('EnumBackupFiles' eq $hash_ini{"Thread$i"}{Type}) {
            CheckEnumBackupFiles($DBname, $hash_ini{"Thread$i"}, $$ary_result[$i]);
        }
        elsif ( ('EnumEditions' eq $hash_ini{"Thread$i"}{Type}) || ('EnumEditionsWait' eq $hash_ini{"Thread$i"}{Type}) ) {
            if(!defined $szCheckDeleteEdition){
            	CheckEnumEditions($DBname, $hash_ini{"Thread$i"}, $$ary_result[$i], $szResultFolder);
        	}else{
        		##jason: because delete edition in memory result in oppposite way
              	CheckEnumEditionsInMemory($DBname, $hash_ini{"Thread$i"}, $$ary_result[$i], $szResultFolder);
        	}
        }##Jason  add a new type
        elsif ('RestoreById' eq $hash_ini{"Thread$i"}{Type}
               || 'RestoreById_Only'eq $hash_ini{"Thread$i"}{Type}) {
            CheckRestoreEditions($DBname, $hash_ini{"Thread$i"}, $$ary_result[$i], $szResultFolder);
        }
        elsif ('DeleteById' eq $hash_ini{"Thread$i"}{Type}
               || 'DeleteById_Only'eq $hash_ini{"Thread$i"}{Type}) {
            CheckDeleteEditions($DBname, $hash_ini{"Thread$i"}, $$ary_result[$i], $szResultFolder);
        }
    }

    CheckResultEnd();
}

##check dre log
sub CheckLog{
	my ($szResultFolder, $ref_checkLogInfo)= @_;
	#print $ref_checkLogInfo;getc();
	if(exists $$ref_checkLogInfo{ary_expectSequence}){
		my $ref_words = $$ref_checkLogInfo{ary_need};
		my $ref_expectSequence = $$ref_checkLogInfo{ary_expectSequence};
		my ($result, $ref_logSequence) = ParseLogInfoSequence($ref_words, $ref_expectSequence, "$szResultFolder\\dre.log");
		if($result){
			WriteError("Log sequence is wrong! expect sequence:",
				"@$ref_expectSequence", "; log sequence:", "@$ref_logSequence");
		}
	}else{
		my @nLinesMessage;
		#print "@{$$ref_checkLogInfo{ary_need}}";getc();
		foreach (@{$$ref_checkLogInfo{ary_need}}){
			 my @nLinesMessage = SearchMessage("$szResultFolder\\dre.log","utf-16be",$_);
		#print "@nLinesMessage";getc();
			 WriteError("Log Wrong! no log information: \"",$_,"\"") unless (@nLinesMessage);
		}
		foreach (@{$$ref_checkLogInfo{ary_noNeed}}){
			 my @nLinesMessage = SearchMessage("$szResultFolder\\dre.log","utf-16be",$_);
			 WriteError("Log Wrong! have log information: \"",$_,"\"") if (@nLinesMessage);
		}
	}
}

my $test = '015_12_02_01_001';
#CheckResult($test, "c:\\DRE\\TestResult\\$test");
1;
