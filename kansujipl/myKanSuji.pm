
#----------------------------------------------------------------------------------------------------------
#	myKanSuji
#----------------------------------------------------------------------------------------------------------

package myKanSuji;

use utf8;
use strict;
use warnings;

	# --- クラス生成 ---

	#-----------------------------------------------------------
	# クラス
	#-----------------------------------------------------------
	sub num2jaEx
	{
		return &_ChCCOC(&_GetCC($_[0]));
	}
	sub num2ja
	{
		return &_GetCC($_[0]);
	}

	sub time2ja
	{
		my $flg = $_[0];
		my @tmp = split(/([^0-9])/,$_[1]);
		my @tm  = ($tmp[0],$tmp[2],$tmp[4]);
		my @flg = (0,0,0,0,0,0,0,0);
		if( $_[0] =~ /A/ ){ $flg[0] = 1; }		# 西暦
		if( $_[0] =~ /T/ ){ $flg[1] = 1; }		# 和暦
		if( $_[0] =~ /K/ ){ $flg[2] = 1; }		# 漢数字
		if( $_[0] =~ /E/ ){ $flg[3] = 1; }		# 旧漢数字
		if( $_[0] =~ /J/ ){ $flg[4] = 1; }		# 旧月名
		
		my $ret = "";
		if( $flg[0] )
		{
			if( $flg[2] )
			{
				return qq(西暦).qq( ).&_GetCC($tm[0]).qq(年).qq( ).&_GetCC($tm[1]).qq(月).qq( ).&_GetCC($tm[2]).qq(日);
			}else{
				return qq(西暦).$tm[0].qq(年).$tm[1].qq(月).$tm[2].qq(日);
			}
		}else{
			if( $flg[2] )
			{
				my $ret = &_GetTP(\@tm,'K').qq( );
				if( $flg[4] ){ $ret .= &_GetMJ($tm[1]); }else{ $ret .= &_GetCC($tm[1]).qq(月); }
				$ret .= qq( ).&_GetCC($tm[2]).qq(日);
				return $ret;
			}
			if( $flg[3] )
			{
				my $ret = &_GetTP(\@tm,'E').qq( );
				if( $tm[1] eq "1" && $tm[2] eq "1" ){ return $ret.qq(元旦); }	#朔日と晦日は旧暦でないと意味がないと思う
				if( $flg[4] ){ $ret .= &_GetMJ($tm[1]); }else{ $ret .= &_ChCCOC(&_GetCC($tm[1])).qq(月); }
				$ret .= qq( ).&_ChCCOC(&_GetCC($tm[2])).qq(日);
				return $ret;
			}
			return &_GetTP(\@tm).$tm[1].qq(月).$tm[2].qq(日);
		}
	}

	#------------------------------------------------------------------------------------

	#------------------------------------------------------------
	#	日本語の年号を返す
	#------------------------------------------------------------
	sub _GetTP
	{
		my @t = @{$_[0]};
		my $flg = $_[1] // 'R';
		my $dtime = sprintf("%04d%02d%02d",$t[0],$t[1],$t[2]);
		my $emp = "";
		my $len = "";
		#明治 1868年01月25日から
		#大正 1912年07月30日から
		if( $dtime >= 19261225 ){ $emp = "昭和"; $len = 1926; }		# 1926年12月25日から
		if( $dtime >= 19890108 ){ $emp = "平成"; $len = 1989; }		# 1989年01月08日から
		#if( $dtime >= 20190101 ){ $emp = "新暦"; $len = 2019; }	# 2019年01月01日から
		$len = $t[0] - $len +1;
		if( $len eq "1" )
		{
			$len = qq( ). qq(元);
		}else{
			if( $flg eq "K" ){ $len = qq( ). &_GetCC($len); }
			if( $flg eq "E" ){ $len = qq( ). &_ChCCOC(&_GetCC($len)); }
		}
		return $emp.$len.qq(年);
	}

	#------------------------------------------------------------
	#	日本語の月名を返す
	#------------------------------------------------------------
	sub _GetMJ
	{
		my @wmons = ("","睦月","如月","弥生","卯月","皐月","水無月","文月","葉月","長月","神無月","霜月","師走");
		return $wmons[$_[0]];
	}

	#------------------------------------------------------------------------------------

	# 『塵劫記』から
	#
	#		●すべて万進法にて計算
	#
	#		○恒河沙から万万進法という説は見送り
	#		○「無量」と「大数」に分ける説は見送り
	#		●「禾予」は本来1文字
	#
	#		○沙から万万進法という説は見送り
	#		○「虚」と「空」、「清」と「浄」に分ける説は見送り
	#
	#		○「基準単位」を「寸」に、、割も寸も別の意味があるからいやだな～
	#

	#------------------------------------------
	# 未だに使う旧字に置換
	#------------------------------------------
	sub _ChCCOC
	{
		my $kanji= $_[0];
		$kanji =~ s/一/壱/g;
		$kanji =~ s/二/弐/g;
		$kanji =~ s/三/参/g;
		$kanji =~ s/五/伍/g;
		$kanji =~ s/十/拾/g;
		$kanji =~ s/万/萬/g;
		return $kanji;
	}

	#------------------------------------------
	# 漢数字に変換、、、年号だけのつもりがいつの間にか大がかりに
	#------------------------------------------
	sub _GetCC
	{
		#正の数から自然数&0と小数に分ける
		my $Positive = $_[0];
		my ($Realnumber,$Decimal) = split(/\./,$Positive);
		#漢字変換
		my $displayNum = "";
		my $displayDec = "";
		if( defined($Realnumber)){ $displayNum = &_GetCCBig($Realnumber); }
		if( $displayNum eq "NumOver!" ){ return $displayNum; }
		if( defined($Decimal))
		{
			$displayDec = &_GetCCSmall($Decimal);
			if( $displayDec eq "DecOver!" ){ return $displayDec; }
			if( $displayDec ne "" )
			{
				if( $displayNum eq "" ){ $displayNum .= "零"; }
			}
		}
		return $displayNum . $displayDec;
		exit;
	}

	#------------------------------------------
	# 小数点は以下は全桁数詞あり、、、(キロ)キロと(ヘクト)(デカ)けた(メートル)が(デシ)に追われて(センチ)(ミリ)ミリ
	#------------------------------------------
	sub _GetCCSmall
	{
		my $num= $_[0];
		$num =~ s/[^0-9]//g;
		my $len = length($num);			#print qq(len[$len] \n);
		if( $len > 24 ){ return qq(DecOver!); }
		
		my @ccs = ("分","厘","毛","糸","忽","微","繊","沙","塵","埃","渺","漠","模糊","逡巡","須臾","瞬息","弾指","刹那","六徳","虚空","清浄","阿頼耶","阿摩羅","涅槃寂静");
		my $ret = "";
		my $index = 0;
		my $retsub = "";
		foreach (split(//,$num))
		{
			$retsub = _ShNumCC1($_);
			if( $retsub ne "" ){ $ret .= qq( ). $retsub .qq( ). $ccs[$index]; }
			++$index;
		}
		if( $ret ne "" ){ $ret = qq( ). "寸" . $ret; }	#基準単位挿入
		return $ret;
	}

	#------------------------------------------
	# 0より大きな数、4桁繰り上がり
	#------------------------------------------
	sub _GetCCBig
	{
		my $num= $_[0];
		$num =~ s/[^0-9]//g;
		if( $num eq "0" ){ return qq(零); }
		my $len = length($num);			#print qq(len[$len] \n);
		if( $len > 72 ){ return qq(NumOver!); }
		my @spl = split(//,$num);
		my $syou = int($len / 4);		#print qq(syou[$syou] \n);
		my $mode = $len % 4;			#print qq(mode[$mode] \n);
		
		my @ccs = ("万","億","兆","京","垓","禾予","穣","溝","澗","正","載","極","恒河沙","阿僧祇","那由他","不可思議","無量大数");
		my $ret = "";
		if($syou > 0)
		{
			my $index = 0;
			my @low = ();
			if( $mode != 0 )
			{
				if( $mode == 3 ){ @low = ($spl[0],$spl[1],$spl[2]); }
				if( $mode == 2 ){ @low = ($spl[0],$spl[1]); }
				if( $mode == 1 ){ @low = ($spl[0]); }
				$ret .= _ShNumCC3(\@low);					#余りがある => 万進数の桁の途中
				$ret .= qq( ). $ccs[$syou];
				$index = $mode;
			}
			my $count = $syou -1;
			my $retsub = "";
			for (; $count+1 > 0; $count--)
			{
				@low = ($spl[0+$index],$spl[1+$index],$spl[2+$index],$spl[3+$index]);
				$retsub = _ShNumCC3(\@low);					#4桁区切りでループ
				if( $retsub ne "" )
				{
					if( $ret ne "" ){ $ret .= qq( ); }
					$ret .= $retsub;
					if( $count > 0 ){ $ret .= qq( ). $ccs[$count -1]; }
				}
				$index += 4;
			}
		}else{
			$ret = _ShNumCC3(\@spl);						#4桁まで
		}
		return $ret;
	}
	sub _ShNumCC3
	{
		my @spl = @{$_[0]};
		my $len = @spl;
		my $ret = "";
		if( $len == 4 ){ $ret .= _ShNumCC2($spl[0],qq(千)) . _ShNumCC2($spl[1],qq(百)) . _ShNumCC2($spl[2],qq(十)) . _ShNumCC1($spl[3]); }
		if( $len == 3 ){ $ret .= _ShNumCC2($spl[0],qq(百)) . _ShNumCC2($spl[1],qq(十)) . _ShNumCC1($spl[2]); }
		if( $len == 2 ){ $ret .= _ShNumCC2($spl[0],qq(十)) . _ShNumCC1($spl[1]); }
		if( $len == 1 ){ $ret .= _ShNumCC1($spl[0]); }
		return $ret;
	}
	sub _ShNumCC2
	{
		my $num = $_[0];
		my $tani = $_[1];
		if( $num == 0 ){ return ""; }
		if( $num == 1 ){ return $tani; }
		return _ShNumCC1($num).$tani;
	}
	sub _ShNumCC1
	{
		my $num = $_[0];
		my @ccs = ("","一","二","三","四","五","六","七","八","九");
		return $ccs[$num];
	}

	#------------------------------------------------------------------------------------

1;