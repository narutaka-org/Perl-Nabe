
#----------------------------------------------------------------------------------------------------------
#	大昔、デザイナーが出してきたHTMLをそのまま置換するCGIを作ってこっぴどく怒られた。今ならありだよね（笑）
#	UTF8対応で、ついぐ風に改造してみました。むしろ、RailsかSymfony使わないと怒られるか、、、
#----------------------------------------------------------------------------------------------------------

use utf8;
use strict;
use warnings;

#----------------------------------------------------------------------------------------------------------
#	Test Main
#----------------------------------------------------------------------------------------------------------

	#----------------------------------------------------------
	#サンプルコード
	#----------------------------------------------------------

	#	HTML生成
	#		my %Conf;
	#		$HTML = &Html_Read("file",\%Conf);						#HTML読み込み
	#		$HTML = &Html_Refresh($URL, $TIME, $TITLE, $BODY);		#リフレッシュページ
	#		$HTML = &Html_Error($MSG);								#エラーページ

	#	HTML操作
	#		$HTML = &Proc_SetIf($HTML,"TAG",BOOL);					# IF 置換
	#		$HTML = &Proc_Data($HTML,"TAG","DATA");					# HTML 置換 (タグは特殊文字に置換されます)

	#	TABLE操作
	#		my ($TABLE);
	#		my ($HTML,$TEMP) = &Proc_GetTable($HTML,"TAG");
	#		for (::) {
	#			my $TLEN = $TEMP;
	#			$TLEN = &Proc_Data($TLEN,"TAG1","DATA1");
	#			$TLEN = &Proc_Data($TLEN,"TAG2","DATA2");
	#			$TABLE .= $TLEN;
	#		}
	#		$HTML = &Proc_SetTable($HTML,"TAG",$TABLE);				# TABLE 置換

	#	FORM操作
	#		my %Form;
	#		$HTML = &Proc_FormValue($HTML,"TAG",$Form{"TAG"});		#Valueに差し込む（ダブルコーテーションは特殊文字に置換されます）
	#		$HTML = &Proc_FormRadio($HTML,"TAG",$Form{"TAG"});		#Radioを選択状態に
	#		$HTML = &Proc_FormSelect($HTML,"TAG",$Form{"TAG"});		#Selectを選択状態に
	#		my %Error;
	#		$HTML = &Proc_FormError($HTML,\%Error);					#FormErrorを差し込む

	#	標準出力
	#		&Html_Shown($HTML);
	#		&Html_Shown($HTML,1);									# no-cacheヘッダー付き
	#		&Html_Shown($HTML,1,$COOKI);							# no-cacheヘッダー付き & ヘッダー追加

	#----------------------------------------------------------
	#テストコード
	#----------------------------------------------------------

	#初期値
	my %Conf = ( "path" => "./html/", "extn" => ".html" );
	
	#Page1表示
	if(1)
	{
		my $HTML = &myPlugHtml::Html_Read("Page1",\%Conf);
		$HTML = &myPlugHtml::Proc_SetIf($HTML,"Student",0);
		$HTML = &myPlugHtml::Proc_SetIf($HTML,"discount",1);
		&myPlugHtml::Html_Shown($HTML);
	}
	
	#Page2表示
	if(1)
	{
		my $HTML = &myPlugHtml::Html_Read("Page2",\%Conf);
		my %Color = ( "black" => "#000000", "red" => "#ff0000", "yellow" => "#ffff00", "white" => "#ffffff" );
		my ($TABLE,$TEMP);
		($HTML,$TEMP) = &myPlugHtml::Proc_GetTable($HTML,"COLOR");
		foreach my $key(keys(%Color))
		{
			my $TLEN = $TEMP;
			$TLEN = &myPlugHtml::Proc_Data($TLEN,"COLOR_ID",$Color{$key});
			$TLEN = &myPlugHtml::Proc_Data($TLEN,"COLOR_NAME",$key);
			$TABLE .= $TLEN;
		}
		$HTML = &myPlugHtml::Proc_SetTable($HTML,"COLOR",$TABLE);	
		&myPlugHtml::Html_Shown($HTML);
	}
	
	#Page3表示
	if(1)
	{
		my $HTML = &myPlugHtml::Html_Read("Page3",\%Conf);
		my %Form = ( "NAME" => "Name Dasu", "AGE" => "B", "SEX" => "F", "MEMO" => "Test" );
		$HTML = &myPlugHtml::Proc_FormValue($HTML,"NAME",$Form{"NAME"});
		$HTML = &myPlugHtml::Proc_FormSelect($HTML,"AGE",$Form{"AGE"});
		$HTML = &myPlugHtml::Proc_FormRadio($HTML,"SEX",$Form{"SEX"});
		$HTML = &myPlugHtml::Proc_Data($HTML,"MEMO",$Form{"MEMO"});
		my %Error;
		$Error{"NAME"} = "NAME ERROR";
		$Error{"AGE"} = "AGE ERROR";
		$HTML = &myPlugHtml::Proc_FormError($HTML,\%Error);
		&myPlugHtml::Html_Shown($HTML);
	}
	
	#Refresh表示
	if(1)
	{
		my $HTML = &myPlugHtml::Html_Refresh("http://google.co.jp");
		&myPlugHtml::Html_Shown($HTML);
	}
	
	exit;


#----------------------------------------------------------------------------------------------------------
#	myPlugHtml
#----------------------------------------------------------------------------------------------------------

package myPlugHtml;

use utf8;
use strict;
use warnings;
use Encode;

	# --- HTML生成 ---

	#-----------------------------------------------------------
	# Template読み込み
	#-----------------------------------------------------------
	sub Html_Read
	{
		if( $_[0] eq "" ){ return &Html_Error("No File"); }
		my %val  = %{$_[1]};
		if( $val{"path"} eq "" ){ $val{"path"} = "./template/"; }
		if( $val{"extn"} eq "" ){ $val{"extn"} = ".tpl"; }
		my $html = "";
		if( open(HTML, "<:utf8", $val{"path"}.$_[0].$val{"extn"} ) )
		{
			my @DATA = <HTML>;
			close(HTML);
			foreach my $line (@DATA) { $html .= $line; }
		}else{
			return &Html_Error('File Open Error');
		}
		return &Proc_Include($html,$_[1]);
	}

	#-----------------------------------------------------------
	# ベースのHTML
	#-----------------------------------------------------------
	sub Html_Base
	{
		my $html = '
		<html>
		<head>
		{% dataValue(meta) %}
		<meta http-equiv="Content-Type" content="text/html;charset=UTF-8">
		<title>{% dataValue(title) %}</title>
		</head>
		<body bgcolor="#FFFFFF">{% dataValue(BODY) %}</body>
		</html>';
		return $html;
	}

	#-----------------------------------------------------------
	# エラーHTML 
	#-----------------------------------------------------------
	sub Html_Error
	{
		my $html = &Html_Base();
		   $html = &Proc_Data($html,"title","error");
		   $html = &Proc_Data($html,"BODY",$_[0]);
		return $html;
	}

	#-----------------------------------------------------------
	# リフレッシュHTML
	#-----------------------------------------------------------
	sub Html_Refresh
	{
		if( $_[0] eq "" ){ return &Html_Error("No URL"); }
		my $content = 0;
		my $title   = "";
		my $BODY    = "";
		if (defined($_[1])){ if( $_[1] ne "" ){ $content = $_[1]; } }
		if (defined($_[2])){ if( $_[2] ne "" ){ $title   = $_[2]; } }
		if (defined($_[3])){ if( $_[3] ne "" ){ $BODY    = $_[3]; } }
		my $meta  = qq(<meta http-equiv="refresh" content="$content;url=$_[0]">);
		my $html = &Html_Base();
		   $html = &Proc_Data($html,"meta",$meta,"NoSec");
		   $html = &Proc_Data($html,"title",$title);
		   $html = &Proc_Data($html,"BODY",$BODY);
		return $html;
	}

	# --- HTML表示 ---

	#-----------------------------------------------------------
	# Template書き出し
	#-----------------------------------------------------------
	sub Html_Shown
	{
		if (defined($_[1]))
		{
			if( $_[1] ne "0" ){ print qq(Cache-Control: no-cache\n); }
		}
		if (defined($_[2]))
		{
			if( $_[2] ne "" ) { print qq($_[2]); }
		}
		print qq(Content-type: text/html\n\n);
		print Encode::encode('utf-8',&Proc_Clear($_[0]));
	}

	# --- HTML置換 ---

	#-----------------------------------------------------------
	# extends差し込み　block置換
	#-----------------------------------------------------------
	sub Proc_Include
	{
		my @html_body = ("$_[0]");
		my $i = 0;
		while ( $html_body[$i] =~ m/{% extends\((.*?)\) %}/s )
		{
			my $file = $1;
			$html_body[$i] =~ s/{% extends\($file\) %}//s;
			++$i;
			$html_body[$i] = &Html_Read($file,$_[1]);
		}
		my $html_base = $html_body[$i];
		for( my $s=$i-1; $s>-1; $s-- )
		{
			my (%TAGL);
			while ( $html_body[$s] =~ m/{% block\((.*?)\) %}/s )
			{
				my $ltag = $1;
				if( $html_body[$s] =~ m/{% block\($ltag\) %}(.*){% endblock\($ltag\) %}/s )
				{
					$TAGL{"$ltag"} = $1;
					$html_body[$s] =~ s/{% block\($ltag\) %}(.*){% endblock\($ltag\) %}//s;
				}
			}
			foreach my $key (keys %TAGL)
			{
				$html_base =~ s/{% block\($key\) %}(.*){% endblock\($key\) %}/$TAGL{"$key"}/s;
			}
		}
		return $html_base;
	}

	#-----------------------------------------------------------
	# 不要置換タグ除去
	#-----------------------------------------------------------
	sub Proc_Clear
	{
		my $html = $_[0];
		while ( $html =~ /{% if\((.*?)\) %}/ )
		{
			my $tag = $1;
			$html =~ s/{% if\($tag\) %}(.*){% endif\($tag\) %}//s;
		}
		while ( $html =~ s/{% (.*?) %}//s ){}
		return $html;
	}

	#-----------------------------------------------------------
	# HTML置換
	#-----------------------------------------------------------
	sub Proc_Data
	{
		my $html = $_[0];
		my $tag  = $_[1];
		my $data = $_[2];
		my $sec  = 1;
		if (defined($_[3])){ $sec  = 0; }
		if($sec)
		{
			$data =~ s/&/&amp;/go;
			$data =~ s/>/&gt;/go;
			$data =~ s/</&lt;/go;
		}
		$html =~ s/{% dataValue\($tag\) %}/$data/g;
		return $html;
	}

	# --- HTML操作 ---

	#-----------------------------------------------------------
	# if 差し込み
	#-----------------------------------------------------------
	sub Proc_SetIf
	{
		my $html = $_[0];
		my $tag  = $_[1];
		my $flg  = $_[2];
		if ( $html =~ /{% else\($tag\) %}/ )
		{
			if($flg)
			{
				$html =~ s/{% if\($tag\) %}//g;
				$html =~ s/{% else\($tag\) %}(.*){% endif\($tag\) %}//s;
			}else{
				$html =~ s/{% if\($tag\) %}(.*){% else\($tag\) %}//s;
				$html =~ s/{% endif\($tag\) %}//g;
			}
		}else{
			if($flg)
			{
				$html =~ s/{% if\($tag\) %}//g;
				$html =~ s/{% endif\($tag\) %}//g;
			}else{
				$html =~ s/{% if\($tag\) %}(.*){% endif\($tag\) %}//s;
			}
		}
		return $html;
	}

	#-----------------------------------------------------------
	# table 差し込み（入れ子の場合内側をGetSetしてから外側へ）
	#-----------------------------------------------------------
	sub Proc_GetTable
	{
		my $html = $_[0];
		my $tag  = $_[1];
		my $table = "";
		if( $html =~ m/{% tableblock\($tag\) %}(.*){% endtableblock\($tag\) %}/s ){ $table = $1; }
		$html =~ s/{% tableblock\($tag\) %}(.*){% endtableblock\($tag\) %}/{% settableblock\($tag\) %}/s;
		return ($html,$table);
	}
	sub Proc_SetTable
	{
		my $html = $_[0];
		my $tag  = $_[1];
		my $data = $_[2];
		$html =~ s/{% settableblock\($tag\) %}/$data/g;
		return $html;
	}

	# --- FORM操作 ---

	#-----------------------------------------------------------
	# Textを入力状態へ
	#-----------------------------------------------------------
	sub Proc_FormValue
	{
		my $html = $_[0];
		my $tag  = $_[1];
		my $val  = $_[2];
		$val =~ s/\"/&quot;/go;
		$html =~ s/{% formValue\($tag\) %}/$val/g;
		return $html;
	}

	#-----------------------------------------------------------
	# Radioを選択状態へ
	#-----------------------------------------------------------
	sub Proc_FormRadio
	{
		my $html = $_[0];
		my $tag  = $_[1];
		my $val  = $_[2];
		while( $html =~ m/{% formRadio\($tag\[(.*?)]\) %}/s )
		{
			my $checkd = qq();
			if( $1 eq $val ){ $checkd = qq(checked="checked");}
			$html =~ s/{% formRadio\($tag\[$1]\) %}/$checkd/g;
		}
		return $html;
	}

	#-----------------------------------------------------------
	# Selectを選択状態へ
	#-----------------------------------------------------------
	sub Proc_FormSelect
	{
		my $html = $_[0];
		my $tag  = $_[1];
		my $val  = $_[2];
		while( $html =~ m/{% formSelect\($tag\[(.*?)]\) %}/s )
		{
			my $selected = "";
			if( $1 eq $val ){ $selected = qq(selected);}
			$html =~ s/{% formSelect\($tag\[$1]\) %}/$selected/g;
		}
		return $html;
	}

	#-----------------------------------------------------------
	# Errorメッセージ
	#-----------------------------------------------------------
	sub Proc_FormError
	{
		my $html = $_[0];
		my %val  = %{$_[1]};
		while( $html =~ m/{% formError\((.*?)\) %}/s )
		{
			my $tag = $1;
			my $value = "";
			if (defined($val{$tag}))
			{
				$value = $val{$tag};
				$value =~ s/&/&amp;/go;
				$value =~ s/>/&gt;/go;
				$value =~ s/</&lt;/go;
			}
			$html =~ s/{% formError\($tag\) %}/$value/g;
		}
		return $html;
	}

#----------------------------------------------------------------------------------------------------------
0;
