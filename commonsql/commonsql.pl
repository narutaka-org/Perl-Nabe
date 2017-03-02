
#----------------------------------------------------------------------------------------------------------
#	大昔DBI系をまとめたものを改造
#	プレイスフォルダってものを試してみたくて拡張してみたら、MySQL用になってしまった、、、、
#----------------------------------------------------------------------------------------------------------

use utf8;
use strict;
use warnings;

#----------------------------------------------------------------------------------------------------------
#	Test Main
#----------------------------------------------------------------------------------------------------------

	#接続設定
	my %Conf = (DB=>"MySQL",NAME=>"schema",USER=>"user",PASS=>"password",HOST=>"127.0.0.1",PORT=>"3306");
	my %Attr = (CHAR=>"utf8mb4",RaiseError=>1,PrintError=>0);

	#エラー設定
	my $ARG = qq(refArgument);
	sub refError
	{
		my $ARG = $_[0];
		print qq(SQL ERROR [ $ARG ]);
		exit;
	}

	#SELECT
	if(1)
	{
		my @hSQL = &myConSql::hSQL(\%Conf,\%Attr);
		my $sSQL = qq(SELECT COUNT(*) FROM `table` WHERE `No` = ? AND `ID` = ?;);
		my @lPRF = ("No","ID");
		#my @rRet = &myConSql::sqlSelect( \@hSQL, $sSQL, \@lPRF, \&refError, $ARG, 1 );
		my @rRet = &myConSql::sqlSelect( \@hSQL, $sSQL, \@lPRF, \&refError, $ARG );
		my $cnt = $rRet[0]->{'COUNT(*)'};
	}

	#UPDATE
	if(1)
	{
		my @hSQL = &myConSql::hSQL(\%Conf,\%Attr);
		my $sSQL = qq(UPDATE FROM `table` SET `ID` = ? WHERE `No` = ?;);
		my @lPRF = ("ID","No");
		#&myConSql::sqlUpdate( \@hSQL, $sSQL, \@lPRF, \&refError, $ARG, 1 );
		&myConSql::sqlUpdate( \@hSQL, $sSQL, \@lPRF );
	}

	#INSERT
	if(1)
	{
		my @hSQL = &myConSql::hSQL(\%Conf,\%Attr);
		my $sSQL = qq(INSERT INTO `table` (`ID`,`PW`,`DATETIME`) VALUES (?,?,NOW()););
		my @lPRF = ("ID","PW");
		&myConSql::sqlInsert( \@hSQL, $sSQL, \@lPRF );
	}

	#DELETE
	if(1)
	{
		my @hSQL = &myConSql::hSQL(\%Conf,\%Attr);
		my $sSQL = qq(DELETE FROM `table` WHERE `DATETIME` < ?;);
		my @lPRF = ("TIME");
		&myConSql::sqlDelete( \@hSQL, $sSQL, \@lPRF );
	}

0;

#----------------------------------------------------------------------------------------------------------
#	myConSql
#----------------------------------------------------------------------------------------------------------

package myConSql;

use strict;
use utf8;
use Encode;
use DBI;
use DBD::mysql;
use DBD::Pg;

	#-----------------------------------------------------------
	# 簡易実行版を作成
	#-----------------------------------------------------------

	sub sqlSelect
	{
		return &sqlMonoCore("SELECT",@_);
	}

	sub sqlInsert
	{
		return &sqlMonoCore("INSERT",@_);
	}

	sub sqlUpdate
	{
		return &sqlMonoCore("UPDATE",@_);
	}

	sub sqlDelete
	{
		return &sqlMonoCore("DELETE",@_);
	}

	sub sqlMonoCore
	{
		my $mode = $_[0];
		my @hSQL = @{$_[1]};
		my $SQL = $_[2];
		my @PRF = @{$_[3]};
		
		my $coderef = "";
		my $argument = undef;
		my $debug = 0;
		if( defined($_[4]) ){ $coderef = $_[4]; }
		if( defined($_[5]) ){ $argument = $_[5]; }
		if( defined($_[6]) ){ $debug = 1; }
		
		@hSQL = &ConnectSTART(\@hSQL);
		@hSQL = &TrnSTART(\@hSQL);
		if( $mode eq "SELECT" )
		{
			@hSQL = &ExecuteSELECT(\@hSQL,$SQL,\@PRF);
		}else{
			my @PRFL = &SetPrfList("",\@PRF);
			if( $mode eq "INSERT" || $mode eq "UPDATE" || $mode eq "DELETE" )
			{
				@hSQL = &SQLExecute($mode,\@hSQL,$SQL,\@PRFL);
			}
		}
		@hSQL = &TrnEND(\@hSQL);
		@hSQL = &ConnectEND(\@hSQL);
		if( $debug ){ print &GetMsg(\@hSQL); }
		if( &CheckSQL(\@hSQL) eq "1" )
		{
			if(defined($argument)){ $coderef->($argument); }
		}
		if( $mode eq "SELECT" )
		{
			my @Ret = &GetSELECT(\@hSQL);
			return (@Ret);
		}
	}

	#-----------------------------------------------------------
	# SQL 実行
	#-----------------------------------------------------------

	sub ExecuteSELECT
	{
		my ($dbh,$sth,$trn,$err,$msg,$dat,$con,$att) =  @{$_[0]};
		my $SQL = $_[1];
		my @DATA = @{$_[2]};
		
		my @Ret = ();
		my $Count = 0;
		if( defined($dbh) )
		{
			eval
			{
				$msg .= &DebugMsg("D:SQL [$SQL]");
				$sth = $dbh->prepare($SQL);
				$msg .= &DebugMsg("D:PRF [@DATA]");
				$sth->execute(@DATA);
				while (my $ref = $sth->fetchrow_hashref())
				{
					my %tRef = %{$ref};
					while (my($key, $val) = each(%tRef))
					{
						$tRef{$key} = Encode::decode("utf-8", $val);
					}
					$Ret[$Count] = \%tRef;
					++$Count;
				}
				$sth->finish;
			};
			if ($@) {
				$err = 1;
				$msg .= &DebugMsg("E:execute SELECT Error");
				if( defined($trn) ){ $trn = 1; }
			}
		}
		return ($dbh,$sth,$trn,$err,$msg,\@Ret,$con,$att);
	}

	sub ExecuteINSERT
	{
		return SQLExecute('INSERT',$_[0],$_[1],$_[2]);
	}

	sub ExecuteUPDATE
	{
		return SQLExecute('UPDATE',$_[0],$_[1],$_[2]);
	}

	sub ExecuteDELETE
	{
		return SQLExecute('DELETE',$_[0],$_[1],$_[2]);
	}

	sub ExecuteCREATE
	{
		return SQLExecute('CREATE',$_[0],$_[1],$_[2]);
	}

	sub ExecuteDROP
	{
		return SQLExecute('DROP',$_[0],$_[1],$_[2]);
	}

	sub SQLExecute
	{
		my $mode = $_[0];
		my ($dbh,$sth,$trn,$err,$msg,$dat,$con,$att) = @{$_[1]};
		my $SQL = $_[2];
		my @DATA = @{$_[3]};
		
		if( defined($dbh) )
		{
			eval
			{
				if( defined($trn) )
				{
					if( $trn ne "1" )
					{
						$msg .= &DebugMsg("D:SQL [$SQL]");
						$sth = $dbh->prepare($SQL);
						foreach (@DATA)
						{
							$msg .= &DebugMsg("D:PRF [@{$_}]");
							$dat .= $sth->execute(@{$_});
						}
						$sth->finish;
						$msg .= &DebugMsg("M:execute $mode (Transaction)");
					}
				}else{
					$msg .= &DebugMsg("D:SQL [$SQL]");
					$sth = $dbh->prepare($SQL);
					foreach (@DATA)
					{
						$msg .= &DebugMsg("D:PRF [@{$_}]");
						$dat .= $sth->execute(@{$_});
					}
					$sth->finish;
					$msg .= &DebugMsg("M:execute $mode");
				}
			};
			if ($@) {
				$err = 1;
				$msg .= &DebugMsg("E:execute $mode Error");
				if( defined($trn) ){ $trn = 1; }
			}
		}
		return ($dbh,$sth,$trn,$err,$msg,$dat,$con,$att);
	}

	#-----------------------------------------------------------
	# トランザクション開始
	#-----------------------------------------------------------
	sub TrnSTART
	{
		my ($dbh,$sth,$trn,$err,$msg,$dat,$con,$att) = @{$_[0]};
		if( defined($dbh) )
		{
			eval
			{
				$dbh->begin_work;	# begin tran
				$trn = 0;
				$msg .= &DebugMsg("M:Transaction begin");
			};
			if ($@) {
				$err = 1;
				$msg .= &DebugMsg("E:Transaction rollback[1]");
				$dbh->rollback;		# rollback tran
				&ConnectEND($dbh,$sth,$trn,$err,$msg);
			}
		}
		return ($dbh,$sth,$trn,$err,$msg,$dat,$con,$att);
	}

	#-----------------------------------------------------------
	# トランザクション終了
	#-----------------------------------------------------------
	sub TrnEND
	{
		my ($dbh,$sth,$trn,$err,$msg,$dat,$con,$att) = @{$_[0]};
		if( defined($dbh) && defined($trn) )
		{
			if( $trn ne "0" )
			{
				$msg .= &DebugMsg("E:Transaction rollback[2]");
				$dbh->rollback;		# rollback tran
			}else{
				eval
				{
					$dbh->commit;		# commit tran
					$msg .= &DebugMsg("M:Transaction commit");
				};
				if ($@) {
					$err = 1;
					$msg .= &DebugMsg("E:Transaction rollback[3]");
					$dbh->rollback;		# rollback tran
					&ConnectEND($dbh,$sth,$trn,$err,$msg);
				}
			}
			undef($trn);
		}
		return ($dbh,$sth,$trn,$err,$msg,$dat,$con,$att);
	}

	#-----------------------------------------------------------
	# DB接続と切断
	#-----------------------------------------------------------
	sub ConnectSTART
	{
		my ($dbh,$sth,$trn,$err,$msg,$dat,$con,$att) = @{$_[0]};
		my %CONF = %{$con};
		my %ATTR = %{$att};
		
		#DoSet
		# CHAR  -> SET NAMES                       [ utf8 | utf8mb4 | cp932 | etc,,, ]
		# TRLEV -> SET TRANSACTION ISOLATION LEVEL [ READ UNCOMMITTED | READ COMMITTED | REPEATABLE READ | SERIALIZABLE ]
		
		# AutoCommit=>1 (default)
		
		my @AttMe = ("AutoCommit","PrintError","RaiseError","ShowErrorStatement","AutoInactiveDestroy");	# DBI >= 1.6.14
		my (%setdb);
		foreach (@AttMe)
		{
			if( defined($ATTR{$_}) ){ $setdb{$_} = $ATTR{$_}; }
		}
		if( uc($CONF{'DB'}) eq "MYSQL" )
		{
			eval
			{
				$dbh = DBI->connect("DBI:mysql:dbname=$CONF{'NAME'};host=$CONF{'HOST'};port=$CONF{'PORT'}","$CONF{'USER'}","$CONF{'PASS'}",\%setdb) || undef($dbh);
			};
			if( defined($dbh) )
			{
				$msg .= &DebugMsg("M:DB connect[MySQL]");
				if( defined($ATTR{'CHAR'}) )
				{
					my $doSQL = qq(SET NAMES ).$ATTR{"CHAR"}.qq(;);
					$dbh->do($doSQL);
					$msg .= &DebugMsg("M:DO [$doSQL]");
				}
				if( defined($ATTR{'TRLEV'}) )
				{
					my $doSQL = qq(SET TRANSACTION ISOLATION LEVEL ).$ATTR{"TRLEV"}.qq(;);
					$dbh->do($doSQL);
					$msg .= &DebugMsg("M:DO [$doSQL]");
				}
			}
		}
		if( uc($CONF{'DB'}) eq "PG" )
		{
			eval
			{
				$dbh = DBI->connect("DBI:Pg:dbname=$CONF{'NAME'};host=$CONF{'HOST'};port=$CONF{'PORT'}","$CONF{'USER'}","$CONF{'PASS'}",\%setdb) || undef($dbh);
			};
			if( defined($dbh) )
			{
				$msg .= &DebugMsg("M:DB connect[Pg]");
			}
		}
		if( !defined($dbh) )
		{
			$err = 1;
			$msg .= &DebugMsg("E:DB connect Error");
		}
		return ($dbh,$sth,$trn,$err,$msg,$dat,$con,$att);
	}

	#-----------------------------------------------------------
	# DB切断
	#-----------------------------------------------------------
	sub ConnectEND
	{
		my ($dbh,$sth,$trn,$err,$msg,$dat,$con,$att) = @{$_[0]};
		if( defined($dbh) )
		{
			$dbh->disconnect;
			$msg .= &DebugMsg("M:DB disconnect");
			undef($dbh);
		}
		return ($dbh,$sth,$trn,$err,$msg,$dat,$con,$att);
	}

	#-----------------------------------------------------------
	# 接続情報 初期化
	#-----------------------------------------------------------
	sub hSQL
	{
		#	my $dbh;	#データベースハンドル
		#	my $sth;	#ステートメントハンドル
		#	my $trn;	#トランザクションハンドル
		#	my $err;	#エラーステートメントハンドル
		#	my $msg;	#デバッグメッセージ
		#	my $dat;	#SELECT結果(ハッシュ値)
		#	my $conf	#*接続設定情報(ハッシュ値)
		#	my $attr	#*接続設定個別情報(ハッシュ値)
		return (undef,undef,undef,undef,undef,undef,$_[0],$_[1]);
	}

	#-----------------------------------------------------------
	# Tooles SELECT結果を取得
	#-----------------------------------------------------------
	sub GetSELECT
	{
		if( &CheckSQL($_[0]) )
		{
			return undef;
		}
		my ($dbh,$sth,$trn,$err,$msg,$dat,$con,$att) = @{$_[0]};
		my @tRet = $dat;
		my @Ret = @{$tRet[0]};
		return @Ret;
	}

	#-----------------------------------------------------------
	# Tooles SQLメッセージ表示
	#-----------------------------------------------------------
	sub GetMsg
	{
		my ($dbh,$sth,$trn,$err,$msg,$dat,$con,$att) = @{$_[0]};
		if( defined($msg) )
		{
			return qq(--- START ---\n).$msg.qq(--- END ---\n);
		}
		return "";
	}

	#-----------------------------------------------------------
	# Tooles SQLエラー判定
	#-----------------------------------------------------------
	sub CheckSQL
	{
		my ($dbh,$sth,$trn,$err,$msg,$dat,$con,$att) = @{$_[0]};
		if( defined($err) )
		{
			if($err eq "1")
			{
				undef($err);
				return 1;
			}
		}
		return 0;
	}

	#-----------------------------------------------------------
	# Tooles 配列の配列を作成
	#-----------------------------------------------------------
	sub SetPrfList
	{
		my @list = ();
		if( $_[0] ne "" )
		{
			@list = @{$_[0]};
		}
		my @data = @{$_[1]};
		my $count = @list;
		$list[$count] = \@data;
		return @list;
	}

	#-----------------------------------------------------------
	# Tooles デバッグメッセージを作成
	#-----------------------------------------------------------
	sub DebugMsg
	{
		my ($sec,$min,$hour) = localtime(time);
		my $time = sprintf("%02d:%02d:%02d",$hour,$min,$sec);
		return qq( [ $time ] ).$_[0].qq(\n);
	}

#-----------------------------------------------------------------------------
exit;
