
#----------------------------------------------------------------------------------------------------------
#	myDateTime
#----------------------------------------------------------------------------------------------------------

package myDateTime;

use utf8;
use strict;
use warnings;
use Time::Local;

	# --- クラス生成 ---

	#-----------------------------------------------------------
	# クラス生成
	#-----------------------------------------------------------
	sub new
    {
		my ( $class, @args ) = @_;
		my %args = ref $args[0] eq 'HASH' ? %{$args[0]} : @args;
		my $self = {%args};
		bless($self);
		if( defined($args[0]) )
		{
			if( defined($args[1]) )
			{
				if( $args[0] eq 'S' ||  $args[0] eq 'D' || $args[0] eq 'T' || $args[0] eq 'E')
				{
					if( $args[0] eq 'S' ){ $self->_dtNowAddS($args[1]); }
					if( $args[0] eq 'D' ){ $self->_dtNowAddD($args[1]); }
					if( $args[0] eq 'T' ){ $self->_dtMakeD($args[1]); }
					if( $args[0] eq 'E' ){ $self->_dtMake($args[1]); }
				}else{
					$self->_dtBase();
				}
			}else{
				$self->_dtBase();
			}
		}else{
			$self->_dtNow();
		}
		
		return $self;
	}

	#-----------------------------------------------------------
	# 時間作成
	#-----------------------------------------------------------
	sub _dtBase
	{
		my $self = shift;							#基準時
		return $self->_ChEp2DT( 0 );
	}
	sub _dtMake
	{
		my $self = shift;							#エポック
		return $self->_ChEp2DT( int($_[0]) );
	}
	sub _dtNow
	{
		my $self = shift;							#現在
		return $self->_ChEp2DT( time );
	}
	sub _dtNowAddS
	{
		my $self = shift;							#秒追加削除
		return $self->_ChEp2DT( time + int($_[0]) );
	}
	sub _dtNowAddD
	{
		my $self = shift;							#日追加削除
		return $self->_ChEp2DT( time + 24*60*60*$_[0] );
	}
	sub _dtMakeD
	{
		my $self = shift;							#日にちから
		return $self->_GetDT2Ep($_[0]);
	}

	# --- 時間を比較 ---

	#-----------------------------------------------------------
	# UNIXタイムを返す
	#-----------------------------------------------------------
	sub E
	{
		my $self = shift;
		return $self->{epoc};
	}

	# --- 時間を増減 ---

	#-----------------------------------------------------------
	# 時間を追加
	#-----------------------------------------------------------
	sub ADD
	{
		my $self = shift;
		my $type = shift;
		my $num  = shift;
		if( $type eq "D" ){ $self->{epoc} = $self->{epoc} + 24*60*60* $num; }	#日
		if( $type eq "H" ){ $self->{epoc} = $self->{epoc} + 60*60* $num; }		#時
		if( $type eq "M" ){ $self->{epoc} = $self->{epoc} + 60* $num; }			#分
		if( $type eq "S" ){ $self->{epoc} = $self->{epoc} + $num; }				#秒
		$self->_ChEp2DT($self->{epoc});
		return;
	}

	# --- 表示 ---

	#-----------------------------------------------------------
	# フォーマット解析
	#-----------------------------------------------------------
	sub PF
	{
		#引数「JMDTWw」
		my $self = shift;
		my @flg = (0,0,0,0,0,0,0,0);
		if( $_[0] =~ /G/ ){ $flg[0] = 1; }		#GMT
		if( $_[0] =~ /J/ ){ $flg[1] = 1; }		#日本語
		if( $_[0] =~ /M/ ){ $flg[2] = 1; }		#月までの表示
		if( $_[0] =~ /D/ ){ $flg[3] = 1; }		#日付表示
		if( $_[0] =~ /T/ ){ $flg[4] = 1; }		#時刻表示
		if( $_[0] =~ /W/ ){ $flg[5] = 1; }		#曜日
		if( $_[0] =~ /N/ ){ $flg[6] = 1; }		#曜日（Full）
		
		#GMTは排反事象
		if( $flg[0] ){ return $self->_fMyGMT;  }
		my $ret = "";
		if( $flg[1] )
		{
			if( $flg[2] ){ return $self->_fMyMJ; }
			if( $flg[3] )
			{
				$ret .= $self->_fMyDJ;
				if( $flg[6] ){ $ret .= qq(\().$self->_GetWJs.qq(\)); }
				if( $flg[5] ){ $ret .= qq( ).$self->_GetWJ; }
			}
			if( $flg[4] )
			{
				if( $ret ne "" ){ $ret .= qq( ); }
				$ret .= $self->_fMyTJ;
			}
		}else{
			if( $flg[2] ){ return $self->_fMyM; }
			if( $flg[3] )
			{
				$ret .= $self->_fMyD;
				if( $flg[6] ){ $ret .= qq(\().$self->_GetWs.qq(\)); }
				if( $flg[5] ){ $ret .= qq( ).$self->_GetW; }
			}
			if( $flg[4] )
			{
				if( $ret ne "" ){ $ret .= qq( ); }
				$ret .= $self->_fMyT;
			}
		}
		return $ret;
	}

	#-----------------------------------------------------------
	# 時間表示
	#-----------------------------------------------------------
	#sub _fMyDT
	#{
	#	my $self = shift;							#MySQLのDateTimeと同じフォーマット
	#	#my @t = $self->_ChH2A;
	#	#return sprintf("%04d-%02d-%02d %02d:%02d:%02d",$t[0],$t[1],$t[2],$t[3],$t[4],$t[5]);
	#	return $self->_fMyD.qq( ).$self->_fMyT;
	#}
	sub _fMyT
	{
		my $self = shift;							#MySQLのTimeと同じフォーマット
		my @t = $self->_ChH2A;
		return sprintf("%02d:%02d:%02d",$t[3],$t[4],$t[5]);
	}
	sub _fMyD
	{
		my $self = shift;							#MySQLのDateと同じフォーマット
		my @t = $self->_ChH2A;
		return sprintf("%04d-%02d-%02d",$t[0],$t[1],$t[2]);
	}
	sub _fMyM
	{
		my $self = shift;							#年と月
		my @t = $self->_ChH2A;
		return sprintf("%04d-%02d",$t[0],$t[1]);
	}
	#sub _fMyDTJ
	#{
	#	my $self = shift;							#日本語で日時
	#	#my @t = $self->_ChH2A;
	#	#return sprintf("%04d年%02d月%02d日 %02d時%02d分%02d秒",$t[0],$t[1],$t[2],$t[3],$t[4],$t[5]);
	#	return $self->_fMyDJ.qq( ).$self->_fMyTJ;
	#}
	sub _fMyTJ
	{
		my $self = shift;							#日本語で時刻
		my @t = $self->_ChH2A;
		return sprintf("%02d時%02d分%02d秒",$t[3],$t[4],$t[5]);
	}
	sub _fMyDJ
	{
		my $self = shift;							#日本語で日付
		my @t = $self->_ChH2A;
		return sprintf("%04d年%02d月%02d日",$t[0],$t[1],$t[2]);
	}
	sub _fMyMJ
	{
		my $self = shift;							#日本語で年と月
		my @t = $self->_ChH2A;
		return sprintf("%04d年%02d月",$t[0],$t[1]);
	}
	#sub _fMyDTJW
	#{
	#	my $self = shift;							#日本語で日時曜日
	#	my $dna = $self->_fMyDTJ();
	#	my $mdy = qq( ).$self->_GetWJ().qq(曜日);
	#	$dna =~ s/ /$mdy /;
	#	return $dna;
	#}
	#sub _fMyDTJWs
	#{
	#	my $self = shift;							#日本語で日時曜日
	#	my $dna = $self->_fMyDTJ();
	#	my $mdy = qq(\().$self->_GetWJ().qq(\));
	#	$dna =~ s/ /$mdy /;
	#	return $dna;
	#}
	#sub _fMyDJW
	#{
	#	my $self = shift;							#日本語で日付曜日
	#	return $self->_fMyDJ().qq( ).$self->_GetWJ().qq( );
	#}
	#sub _fMyDJWs
	#{
	#	my $self = shift;							#日本語で日付曜日
	#	return $self->_fMyDJ().qq(\().$self->_GetWJs().qq(\));
	#}
	sub _fMyGMT
	{
		my $old = shift;							#GMTに変換してクッキーフォーマット
		my $self = myDateTime->new('E',$old->{epoc});
		$self->_ChEp2GMT($self->{epoc});
		my @t = $self->_ChH2A;
		return sprintf("%s, %02d-%s-%04d %02d:%02d:%02d GMT",$self->_GetWs,$t[2],$self->_GetMs,$t[0],,$t[3],$t[4],$t[5]);
	}

	# --- プライベート ---

	#------------------------------------------------------------
	#	Epock から 年～秒
	#------------------------------------------------------------
	sub _ChEp2DT
	{
		my $self = shift;
		my @DT = reverse((localtime( $_[0] ))[0..6]);
		$self->{wday} = $DT[0];
		$self->{year} = $DT[1] +1900;
		$self->{mon}  = $DT[2] +1;
		$self->{day}  = $DT[3];
		$self->{hour} = $DT[4];
		$self->{min}  = $DT[5];
		$self->{sec}  = $DT[6];
		$self->{epoc} = $_[0];
		return;
	}
	#------------------------------------------------------------
	#	年～秒 から Epock 
	#------------------------------------------------------------
	sub _GetDT2Ep
	{
		my $self = shift;
		my( $temp1, $temp2 ) = split(/ /,$_[0]);
		my( $year, $mon, $mday ) = split(/-/,$temp1);
		my( $hour, $min, $sec );
		if( defined($temp2) )
		{
			( $hour, $min, $sec ) = split(/:/,$temp2);
		}else{
			$hour = $min = $sec = 0;
		}
		if( $year eq "" ){ return $self->_dtBase(); }
		my $time = timelocal($sec, $min, $hour, $mday, $mon - 1, $year);
		return $self->_ChEp2DT($time);
	}
	#------------------------------------------------------------
	#	Epock から GMT 年～秒
	#------------------------------------------------------------
	sub _ChEp2GMT
	{
		my $self = shift;
		my @DT = reverse((gmtime( $_[0] ))[0..6]);
		$self->{wday} = $DT[0];
		$self->{year} = $DT[1] +1900;
		$self->{mon}  = $DT[2] +1;
		$self->{day}  = $DT[3];
		$self->{hour} = $DT[4];
		$self->{min}  = $DT[5];
		$self->{sec}  = $DT[6];
		$self->{epoc} = $_[0];
		return;
	}
	#------------------------------------------------------------
	#	日付配列に変換
	#------------------------------------------------------------
	sub _ChH2A
	{
		my $self = shift;
		return ($self->{year},$self->{mon},$self->{day},$self->{hour},$self->{min},$self->{sec});
	}
	#------------------------------------------------------------
	#	曜日を返す
	#------------------------------------------------------------
	sub _GetW
	{
		my $self = shift;
		my @wdays = ("Sun","Mon","Tues","Wednes","Thurs","Fri","Satur");
		return $wdays[$self->{wday}].qq(day);
	}
	#------------------------------------------------------------
	#	曜日を返す（短縮）
	#------------------------------------------------------------
	sub _GetWs
	{
		my $self = shift;
		my @wdays = ("Sun","Mon","Tue","Wed","Thu","Fri","Sat");
		return $wdays[$self->{wday}];
	}
	#------------------------------------------------------------
	#	日本語の曜日を返す
	#------------------------------------------------------------
	sub _GetWJ
	{
		my $self = shift;
		return $self->_GetWJs.qq(曜日);
	}
	#------------------------------------------------------------
	#	日本語の曜日を返す（短縮）
	#------------------------------------------------------------
	sub _GetWJs
	{
		my $self = shift;
		my @wdays = ("日","月","火","水","木","金","土");
		return $wdays[$self->{wday}];
	}
	#------------------------------------------------------------
	#	月名を返す
	#------------------------------------------------------------
	#sub _GetM
	#{
	#	my $self = shift;
	#	my @wmons = ("","January","February","March","April","May","June","July","August","September","October","November","December");
	#	return $wmons[$self->{mon}];
	#}
	#------------------------------------------------------------
	#	月名を返す（短縮）
	#------------------------------------------------------------
	sub _GetMs
	{
		my $self = shift;
		my @wmons = ("","Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec");
		return $wmons[$self->{mon}];
	}
	#------------------------------------------------------------
	#	日本語の年号を返す
	#------------------------------------------------------------
	#sub _GetYJ
	#{
	#	my $self = shift;
	#	my @t = $self->_ChH2A;
	#	my $dtime = sprintf("%04d%02d%02d",$t[0],$t[1],$t[2]);
	#	my $emp = "";
	#	my $len = "";
	#	#明治 1868年01月25日から
	#	#大正 1912年07月30日から
	#	if( $dtime >= 19261225 ){ $emp = "昭和"; $len = 1926; }		# 1926年12月25日から
	#	if( $dtime >= 19890108 ){ $emp = "平成"; $len = 1989; }		# 1989年01月08日から
	#	#if( $dtime >= 20190101 ){ $emp = "新暦"; $len = 2019; }	# 2019年01月01日から
	#	$len = $t[0] - $len +1;
	#	if( $len eq "1" ){ $len = qq(元); }
	#	return $emp.$len.qq(年);
	#}
	#------------------------------------------------------------
	#	日本語の月名を返す
	#------------------------------------------------------------
	#sub _GetMJ
	#{
	#	my $self = shift;
	#	my @wmons = ("","睦月","如月","弥生","卯月","皐月","水無月","文月","葉月","長月","神無月","霜月","師走");
	#	return $wmons[$self->{mon}];
	#}
	#------------------------------------------------------------
	#	漢数字を返す（千の単位まで）
	#------------------------------------------------------------

	

	#------------------------------------------------------------

1;