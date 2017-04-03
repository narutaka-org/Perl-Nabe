
#----------------------------------------------------------------------------------------------------------
#	大昔DBI系をまとめたものを改造
#	プレイスフォルダってものを試してみたくて拡張してみたら、MySQL用になってしまった、、、、
#----------------------------------------------------------------------------------------------------------

use utf8;
use strict;
use warnings;

use lib "./";
use myCommonSql;


#----------------------------------------------------------------------------------------------------------
#	Test Main
#----------------------------------------------------------------------------------------------------------

	#----------------------------------------------------------
	#サンプルコード
	#----------------------------------------------------------

		#-----------------------------------------------------------
		# 接続設定
		#-----------------------------------------------------------

		#	my %Attr = (RaiseError=>1,PrintError=>0);
		#	my %Conf = (NAME=>"schema",USER=>"user",PASS=>"password",HOST=>"127.0.0.1",CHAR=>"utf8mb4",ATTR=>\%Attr);

		#エラー設定
		#	my $ARG = qq(refArgument);
		#	sub refError
		#	{
		#		my $ARG = $_[0];
		#		print qq(SQL ERROR [ $ARG ]);
		#		exit;
		#	}
		#	$Conf{CBFC} = \&refError;
		#	$Conf{ARG}  = $ARG;

		#-----------------------------------------------------------
		# 簡易実行版
		#-----------------------------------------------------------

		#SELECT
		#	my $sSQL = qq(SELECT COUNT(*) FROM `table` WHERE `No` = ? AND `ID` = ?;);
		#	my @lPRF = ("No","ID");
		#	my @rRet = myCommonSql->sqlSelec( $sSQL, \@lPRF, %Conf );
		#	my $cnt = $rRet[0]->{'COUNT(*)'};

		#INSERT
		#	my $sSQL = qq(INSERT INTO `table` (`ID`,`PW`,`DATETIME`) VALUES (?,?,NOW()););
		#	my @lPRF = ("ID","PW");
		#	my @rRet = myCommonSql->sqlInsert( $sSQL, \@lPRF, %Conf );

		#UPDATE
		#	my $sSQL = qq(UPDATE `table` SET `ID` = ? WHERE `No` = ?;);
		#	my @lPRF = ("ID","No");
		#	my @rRet = myCommonSql->sqlUpdate( $sSQL, \@lPRF, %Conf );

		##DELETE
		#	my $sSQL = qq(DELETE FROM `table` WHERE `DATETIME` < ?;);
		#	my @lPRF = ("TIME");
		#	my @rRet = myCommonSql->sqlDelete( $sSQL, \@lPRF, %Conf );

		#-----------------------------------------------------------
		# 完全実行版
		#-----------------------------------------------------------
		
		#	my $mSQL = myCommonSql->new(%Conf);
		#	$mSQL->ConnectSTART;
		#	$mSQL->TrnSTART;
		#	$mSQL->ExecuteSELECT($SQL,\@PRF);				#SELECT
		#	if( $mSQL->CheckSQL eq "1" )
		#	{
		#		print qq(SQLエラー[SELECT]);
		#	}else{
		#		my $Con  = $mSQL->GetSELECTcount;
		#		my @%Ret = $mSQL->GetSELECT;
		#	}
		#	my @@PRFL = $mSQL->SetPrfList("",\@PRF1);
		#	@@PRFL = $mSQL->SetPrfList(\@@PRFL,\@PRF2);		#複数データー作成
		#	$mSQL->ExecuteINSERT($SQL,\@@PRFL);				#INSERT
		#	$mSQL->ExecuteUPDATE($SQL,\@@PRFL);				#UPDATE
		#	$mSQL->TrnEND;
		#	$mSQL->ConnectEND;
		#	if( $mSQL->CheckSQL eq "1" )
		#	{
		#		print qq(SQLエラー[INSERT,UPDATE,Transaction]);
		#	}

		#-----------------------------------------------------------
		# 通常版
		#-----------------------------------------------------------
		
		#SQLスタック
		#	my $mSQL = myCommonSql->new(%Conf);
		#
		#	my $sSQL1 = qq(INSERT INTO `table` (`ID`,`PW`,`DATETIME`) VALUES (?,?,NOW()););		#INSERT
		#	my @lPRF1 = ("ID","PW");
		#	$mSQL->sqlMonoAdd($sSQL1,\@lPRF1);
		#
		#	my $sSQL2 = qq(UPDATE `table` SET `ID` = ? WHERE `No` = ?;);						#UPDATE
		#	my @lPRF2 = ("ID","No");
		#	$mSQL->sqlMonoAdd($sSQL2,\@lPRF2);
		#
		#	my $sSQL3 = qq(SELECT COUNT(*) FROM `table` WHERE `No` = ? AND `ID` = ?;);			#SELECT
		#	my @lPRF3 = ("No","ID");
		#	$mSQL->sqlMonoAdd($sSQL3,\@lPRF3);
		#
		#SQL実行
		#	my @rRetL = $mSQL->sqlMonoCoreEx;
		#
		#
		#	my $cnt = $rRet[0]->{'COUNT(*)'};

	#----------------------------------------------------------
	#テストコード
	#----------------------------------------------------------

		#接続設定
		my %Attr = (RaiseError=>1,PrintError=>0);
		my %Conf = (NAME=>"schema",USER=>"root",PASS=>"",HOST=>"127.0.0.1",CHAR=>"utf8mb4",ATTR=>\%Attr);
		
		#INSERT
		my $sSQL0 = qq(INSERT INTO `table` (`ID`,`PW`,`DATETIME`) VALUES (?,?,NOW()););
		my @lPRF0 = ("ID","PW");
		
		#UPDATE
		my $sSQL1 = qq(UPDATE `table` SET `ID` = ? WHERE `PW` = ?;);
		my @lPRF1 = ("123","PW");

		#SELECT
		my $sSQL2 = qq(SELECT COUNT(*) FROM `table` WHERE `ID` = ? AND `PW` = ?;);
		my @lPRF2 = ("123","PW");

		#実行
		my $mSQL = myCommonSql->new(%Conf);
		   $mSQL->sqlMonoAdd($sSQL0,\@lPRF0);
		   $mSQL->sqlMonoAdd($sSQL1,\@lPRF1);
		   $mSQL->sqlMonoAdd($sSQL2,\@lPRF2);
		my @rRetL = $mSQL->sqlMonoExe;
		
		#SELECT取得
		foreach (@{$rRetL[2]})
		{
			print $_->{'COUNT(*)'};
		}

0;
