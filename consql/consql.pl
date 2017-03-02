
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
	
	
	#	my $SQL = qq(SELECT COUNT(*) FROM `table` WHERE `No` = ? AND `ID` = ?;);
	#	my @PRF = ($No,$ID);
	#	my @Ret = &sqlSelectMonoCore( $SQL, \@PRF, \&refError, $ARG );
	#	my $cnt = $Ret[0]->{'COUNT(*)'};

	#	my $SQL = qq(UPDATE FROM `table` SET `ID` = ? WHERE `No` = ?;);
	#	my @PRF = ($ID,$No);
	#	&sqlUpdateMonoCore( $SQL, \@PRF, \&refError, $ARG );

	#	my $SQL = qq(INSERT INTO `table` (`ID`,`PW`,`DATETIME`) VALUES (?,?,NOW()););
	#	my @PRF = ($ID,$PW);
	#	&sqlInsertMonoCore( $SQL, \@PRF, \&refError, $ARG );

	#	my $SQL = qq(DELETE FROM `table` WHERE `DATETIME` < ?;);
	#	my @PRF = ($TIME);
	#	&sqlDeleteMonoCore( $SQL, \@PRF, \&refError, $ARG );
	
	
	
	
	
	
	
	
	
	
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




	sub SQLExecute
	{
		my $mode = $_[0];
		my ($dbh,$sth,$trn,$err,$msg,$dat) =  @{$_[1]};
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
							$sth->execute(@{$_});
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
						$sth->execute(@{$_});
					}
					$sth->finish;
					$msg .= &DebugMsg("M:execute $mode");
				}
			};
			if ($@) {
				$err = 1;
				$msg .= &DebugMsg("E:execute $mode Error");
				if( defined($trn) )
				{
					$trn = 1;
				}
			}
		}
		return ($dbh,$sth,$trn,$err,$msg,$dat);
	}
