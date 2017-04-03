
#----------------------------------------------------------------------------------------------------------
#	myCommonSql
#----------------------------------------------------------------------------------------------------------

package myCommonSql;

use utf8;
use strict;
use warnings;
use Encode;

use DBI;
use DBD::mysql;
use DBD::Pg;

	# --- クラス生成 ---

	#-----------------------------------------------------------
	# クラス生成
	#-----------------------------------------------------------
	sub new
    {
		my ( $class, @args ) = @_;
		my %args = ref $args[0] eq 'HASH' ? %{$args[0]} : @args;
		my $self = {%args};
		#$self->{hSQL} //= [undef,undef,undef,undef,undef,undef];
		$self->{_dbh} = undef;		# データベースハンドル
		$self->{_sth} = undef;		# ステートメントハンドル
		$self->{_trn} = undef;		# トランザクションハンドル
		$self->{_err} = undef;		# エラーステートメントハンドル
		$self->{_msg} = undef;		# デバッグメッセージ
		$self->{_dat} = undef;		# 結果(SELECT:ハッシュ値 ? 配列)
		#必須
		$self->{DB}   //= 'MySQL';	# MySQL or Pg
		$self->{NAME} //= '';		# データーベース名
		$self->{USER} //= '';
		$self->{PASS} //= '';
		$self->{HOST} //= '127.0.0.1';
		$self->{PORT} //= '3306';
		#$self->{CHAR} //= '';		# キャラセット
		#$self->{TRLEV} //= '';		# トランザクションレベル
		#プロパティ
		$self->{ATTR} //= '';
		#コールバックとデバッグ
		$self->{CBFC} //= undef;	# エラーのコールバック関数
		$self->{ARG}  //= undef;	# コールバック引数
		$self->{DBUG} //= undef;	# デバッグメッセージ
		#連続簡易実行の配列
		$self->{SQLC} //= 0;
		$self->{SQLL} //= undef;
		return bless($self);
	}

	#-----------------------------------------------------------
	# 簡易実行版
	#-----------------------------------------------------------
	sub sqlSelect
	{
		my ( $class, @args ) = @_;
		return &_sqlMonoCore("SELECT",@args);
	}
	sub sqlInsert
	{
		my ( $class, @args ) = @_;
		return &_sqlMonoCore("INSERT",@_);
	}
	sub sqlUpdate
	{
		my ( $class, @args ) = @_;
		return &_sqlMonoCore("UPDATE",@_);
	}
	sub sqlDelete
	{
		my ( $class, @args ) = @_;
		return &_sqlMonoCore("DELETE",@_);
	}
	sub _sqlMonoCore
	{
		my ( $class, $SQL, $PRF, @args ) = @_;
		my $new = myCommonSql->new(@args);
		$new->ConnectSTART;
		if( $SQL =~ /^SELECT/i )
		{
			$new->SQLExecute('SELECT',$SQL,$PRF);
		}else{
			my @PRFL = $new->SetPrfList("",$PRF);
			$new->SQLExecute('OHER',$SQL,\@PRFL);
		}
		$new->ConnectEND;
		if( defined($new->{DBUG}) )
		{
			if( $new->{DBUG} ){ print $new->GetMsg; }
		}
		if( defined($new->{CBFC}) )
		{
			if( $new->CheckSQL eq "1" )
			{
				if( defined($new->{ARG}) )
				{
					$new->{CBFC}->($new->{ARG});
				}else{
					$new->{CBFC}->();
				}
			}
		}
		return $new->GetSELECT;
	}

#-----------------------------------------------------------------------------

	#-----------------------------------------------------------
	# DB接続切断
	#-----------------------------------------------------------
	sub ConnectSTART
	{
		my $self = shift;
		my %setdb = $self->_ConnectAttr;
		if( uc($self->{DB}) eq "MYSQL" )
		{
			eval
			{
				$self->{_dbh} = DBI->connect("DBI:mysql:dbname=$self->{NAME};host=$self->{HOST};port=$self->{PORT}","$self->{USER}","$self->{PASS}",\%setdb) || undef($self->{_dbh});
			};
			if( defined($self->{_dbh}) )
			{
				$self->_DebugMsg("M:DB connect[MySQL]");
				if( defined($self->{CHAR}) )
				{
					$self->_ConnectDo("SET NAMES ".$self->{CHAR}.";");
				}
				if( defined($self->{TRLEV}) )
				{
					$self->_ConnectDo("SET TRANSACTION ISOLATION LEVEL ".$self->{TRLEV}.";");
				}
			}
		}
		if( uc($self->{DB}) eq "PG" )
		{
			eval
			{
				$self->{_dbh} = DBI->connect("DBI:Pg:dbname=$self->{NAME};host=$self->{HOST};port=$self->{PORT}","$self->{USER}","$self->{PASS}",\%setdb) || undef($self->{_dbh});
			};
			if( defined($self->{_dbh}) )
			{
				$self->_DebugMsg("M:DB connect[Pg]");
			}
		}
		if( !defined($self->{_dbh}) )
		{
			$self->{_err} = 1;
			$self->_DebugMsg("E:DB connect Error");
		}
	}
	sub ConnectEND
	{
		my $self = shift;
		if( defined($self->{_dbh}) )
		{
			$self->{_dbh}->disconnect;
			$self->_DebugMsg("M:DB disconnect");
			undef($self->{_dbh});
		}
	}

	#-----------------------------------------------------------
	# トランザクション
	#-----------------------------------------------------------
	sub TrnSTART
	{
		my $self = shift;
		if( defined($self->{_dbh}) )
		{
			eval
			{
				$self->{_dbh}->begin_work;	# begin tran
				$self->{_trn} = 0;
				$self->_DebugMsg("M:Transaction begin");
			};
			if ($@) {
				$self->{_err} = 1;
				$self->_DebugMsg("E:Transaction rollback[1]");
				$self->{_dbh}->rollback;		# rollback tran
				$self->ConnectEND;
			}
		}
	}
	sub TrnEND
	{
		my $self = shift;
		if( defined($self->{_dbh}) && defined($self->{_trn}) )
		{
			if( $self->{_trn} ne "0" )
			{
				$self->_DebugMsg("E:Transaction rollback[2]");
				$self->{_dbh}->rollback;		# rollback tran
			}else{
				eval
				{
					$self->{_dbh}->commit;		# commit tran
					$self->_DebugMsg("M:Transaction commit");
				};
				if ($@) {
					$self->{_err} = 1;
					$self->_DebugMsg("E:Transaction rollback[3]");
					$self->{_dbh}->rollback;		# rollback tran
					$self->ConnectEND;
				}
			}
			undef($self->{_trn});
		}
	}

	#-----------------------------------------------------------
	# SQL 実行
	#-----------------------------------------------------------

	sub ExecuteSELECT{ my $self = shift; return $self->SQLExecute('SELECT',@_); }
	sub ExecuteINSERT{ my $self = shift; return $self->SQLExecute('INSERT',@_); }
	sub ExecuteUPDATE{ my $self = shift; return $self->SQLExecute('UPDATE',@_); }
	sub ExecuteDELETE{ my $self = shift; return $self->SQLExecute('DELETE',@_); }
	sub ExecuteCREATE{ my $self = shift; return $self->SQLExecute('CREATE',@_); }
	sub ExecuteDROP{ my $self = shift; return $self->SQLExecute('DROP',@_); }

	sub SQLExecute
	{
		my $self = shift;
		my $mode = $_[0];
		my $SQL = $_[1];
		my @DATA = @{$_[2]};
		my $select = 0;
		my @Ret = ();
		my $Count = 0;
		if( $mode eq "SELECT" ){ $select = 1; }
		if( defined($self->{_dbh}) )
		{
			eval
			{
				if( defined($self->{_trn}) )
				{
					if( $self->{_trn} eq "1" ){ return; }else{ $mode .= " (Transaction)"; }
				}
				$self->_DebugMsg("D:SQL [$SQL]");
				$self->{_sth} = $self->{_dbh}->prepare($SQL);
				if( $select )
				{
					$self->_DebugMsg("D:PRF [@DATA]");
					$self->{_sth}->execute(@DATA);
					while (my $ref = $self->{_sth}->fetchrow_hashref())
					{
						my %tRef = %{$ref};
						while (my($key, $val) = each(%tRef))
						{
							$tRef{$key} = Encode::decode("utf-8", $val);
						}
						$Ret[$Count] = \%tRef;
						++$Count;
						$self->_DebugMsg("D:RET [$Count]");
					}
				}else{
					foreach (@DATA)
					{
						$self->_DebugMsg("D:PRF($Count) [@{$_}]");
						$Ret[$Count] = $self->{_sth}->execute(@{$_});
						++$Count;
					}
				}
				$self->{_dat} = \@Ret;
				$self->{_sth}->finish;
				$self->_DebugMsg("M:execute $mode");
			};
			if ($@) {
				$self->{_err} = 1;
				$self->_DebugMsg("E:execute $mode Error");
				if( defined($self->{_trn}) ){ $self->{_trn} = 1; }
			}
		}
		return;
	}

	#-----------------------------------------------------------
	# SQL 連続簡易実行
	#-----------------------------------------------------------
	sub sqlMonoAdd
	{
		my $self = shift;
		my @len = ($_[0],$_[1]);
		$self->{SQLL}[$self->{SQLC}] = \@len;
		++$self->{SQLC};
	}

	sub sqlMonoExe
	{
		my $self = shift;
		my @Ret = ();
		$self->ConnectSTART;
		$self->TrnSTART;
		my @mSQL = @{$self->{SQLL}};
		my $Count = 0;
		foreach (@mSQL)
		{
			my @len = @{$_};
			my $SQL  = $len[0];
			my $PRF  = $len[1];
			
			if( $SQL =~ /^SELECT/i )
			{
				$self->SQLExecute('SELECT',$SQL,$PRF);
			}else{
				my @PRFL = $self->SetPrfList("",$PRF);
				$self->SQLExecute('OHER',$SQL,\@PRFL);
			}
			$Ret[$Count] = $self->GetSELECT;
			++$Count;
		}
		$self->TrnEND;
		$self->ConnectEND;
		if( defined($self->{DBUG}) )
		{
			if( $self->{DBUG} ){ print $self->GetMsg; }
		}
		if( defined($self->{CBFC}) )
		{
			if( $self->CheckSQL eq "1" )
			{
				if( defined($self->{ARG}) )
				{
					$self->{CBFC}->($self->{ARG});
				}else{
					$self->{CBFC}->();
				}
			}
		}
		return (@Ret);
	}

#-----------------------------------------------------------------------------

	#-----------------------------------------------------------
	# Tooles SELECT結果を取得
	#-----------------------------------------------------------
	sub GetSELECT
	{
		my $self = shift;
		if( $self->CheckSQL )
		{
			return undef;
		}
		return $self->{_dat};
	}

	#-----------------------------------------------------------
	# Tooles SELECT結果を取得
	#-----------------------------------------------------------
	sub GetSELECTcount
	{
		my $self = shift;
		if( $self->CheckSQL )
		{
			return 0;
		}
		my $count = @{$self->{_dat}};
		return $count;
	}

	#-----------------------------------------------------------
	# Tooles SQLメッセージ表示
	#-----------------------------------------------------------
	sub GetMsg
	{
		my $self = shift;
		if( defined($self->{_msg}) )
		{
			return $self->{_msg};
		}
		return "";
	}

	#-----------------------------------------------------------
	# Tooles SQLエラー判定
	#-----------------------------------------------------------
	sub CheckSQL
	{
		my $self = shift;
		if( defined($self->{_err}) )
		{
			if($self->{_err} eq "1")
			{
				undef($self->{_err});
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
		my $self = shift;
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
	
#-----------------------------------------------------------------------------
	
	sub _ConnectAttr
	{
		#DBI用配列を生成
		# AutoCommit=>1 (default)
		my $self = shift;
		my @AttMe = ("AutoCommit","PrintError","RaiseError","ShowErrorStatement","AutoInactiveDestroy");	# DBI >= 1.6.14
		my (%setdb);
		foreach (@AttMe)
		{
			if( defined($self->{ATTR}->{$_}) )
			{
				$setdb{$_} = $self->{ATTR}->{$_};
			}
		}
		return %setdb;
	}
	sub _ConnectDo
	{
		#Doを実行
		# DoSet CHAR  -> SET NAMES [ utf8 | utf8mb4 | cp932 | etc,,, ]
		# DoSet TRLEV -> SET TRANSACTION ISOLATION LEVEL [ READ UNCOMMITTED | READ COMMITTED | REPEATABLE READ | SERIALIZABLE ]
		my $self = shift;
		my $doSQL = shift;
		if( defined($self->{_dbh}) )
		{
			eval
			{
				$self->{_dbh}->do($doSQL);
				$self->_DebugMsg("M:DO [$doSQL]");
			};
			if ($@) {
				$self->_DebugMsg("E:DO Error");
			}
		}
	}
	sub _DebugMsg
	{
		#デバッグメッセージを作成
		my $self = shift;
		my ($sec,$min,$hour) = localtime(time);
		my $time = sprintf("%02d:%02d:%02d",$hour,$min,$sec);
		$self->{_msg} .= qq( [ $time ] ).$_[0].qq(\n);
	}

#-----------------------------------------------------------------------------
1;
