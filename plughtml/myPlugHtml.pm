
#----------------------------------------------------------------------------------------------------------
#	myPlugHtml
#----------------------------------------------------------------------------------------------------------

package myPlugHtml;

use utf8;
use strict;
use warnings;
use Encode;

	# --- クラス生成 ---

	#-----------------------------------------------------------
	# クラス生成
	#-----------------------------------------------------------
	sub new
    {
		my ( $class, @args ) = @_;
		my %args = ref $args[0] eq 'HASH' ? %{$args[0]} : @args;
		my $self = {%args};
		$self->{path}  //= './html/';
		$self->{extn}  //= '.html';
		$self->{html}  //= '';
		$self->{temp}  //= '';
		$self->{table} //= '';
		return bless($self);
	}

	# --- HTML生成 ---

	#-----------------------------------------------------------
	# Template読み込み
	#-----------------------------------------------------------
	sub Html_Read
	{
		my $self = shift;
		my $file = shift;
		if( $file eq "" ){ return $self->Html_Error("No File"); }
		my $html = "";
		if( open(HTML, "<:utf8", $self->{path}.$file.$self->{extn} ) )
		{
			my @DATA = <HTML>;
			close(HTML);
			foreach my $line (@DATA) { $html .= $line; }
			$self->{html} = $html;
		}else{
			return $self->Html_Error('File Open Error');
		}
		return $self->_Proc_Include();
	}

	#-----------------------------------------------------------
	# ベースのHTML
	#-----------------------------------------------------------
	sub _Html_Base
	{
		my $self = shift;
		$self->{html} = '
		<html>
		<head>
		{% dataValue(meta) %}
		<meta http-equiv="Content-Type" content="text/html;charset=UTF-8">
		<title>{% dataValue(title) %}</title>
		</head>
		<body bgcolor="#FFFFFF">{% dataValue(BODY) %}</body>
		</html>';
		return;
	}

	#-----------------------------------------------------------
	# エラーHTML 
	#-----------------------------------------------------------
	sub Html_Error
	{
		my $self = shift;
		   $self->_Html_Base();
		   $self->Proc_Data("title","error");
		   $self->Proc_Data("BODY",$_[0]);
		return;
	}

	#-----------------------------------------------------------
	# リフレッシュHTML
	#-----------------------------------------------------------
	sub Html_Refresh
	{
		my $self = shift;
		if( $_[0] eq "" ){ return $self->Html_Error("No URL"); }
		my $content = 0;
		my $title   = "";
		my $BODY    = "";
		if (defined($_[1])){ if( $_[1] ne "" ){ $content = $_[1]; } }
		if (defined($_[2])){ if( $_[2] ne "" ){ $title   = $_[2]; } }
		if (defined($_[3])){ if( $_[3] ne "" ){ $BODY    = $_[3]; } }
		my $meta  = qq(<meta http-equiv="refresh" content="$content;url=$_[0]">);
		$self->_Html_Base();
		$self->Proc_Html("meta",$meta);
		$self->Proc_Data("title",$title);
		$self->Proc_Data("BODY",$BODY);
		return;
	}

	#-----------------------------------------------------------
	# Template書き出し
	#-----------------------------------------------------------
	sub Html_Shown
	{
		my $self = shift;
		if (defined($_[0]))
		{
			if( $_[0] ne "0" ){ print qq(Cache-Control: no-cache\n); }
		}
		if (defined($_[1]))
		{
			if( $_[1] ne "" ) { print qq($_[2]); }
		}
		$self->_Proc_Clear();
		print qq(Content-type: text/html\n\n);
		print Encode::encode('utf-8',$self->{html});
	}

	# --- HTML置換 ---

	#-----------------------------------------------------------
	# extends差し込み　block置換
	#-----------------------------------------------------------
	sub _Proc_Include
	{
		my $self = shift;
		my @html_body = ($self->{html});
		my $i = 0;
		while ( $html_body[$i] =~ m/{% extends\((.*?)\) %}/s )
		{
			my $file = $1;
			$html_body[$i] =~ s/{% extends\($file\) %}//s;
			++$i;
			$self->{temp} = $self->{html};
			$self->Html_Read($file);
			$html_body[$i] = $self->{html};
			$self->{html} = $self->{temp};
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
		$self->{html} = $html_base;
		return;
	}

	#-----------------------------------------------------------
	# 不要置換タグ除去
	#-----------------------------------------------------------
	sub _Proc_Clear
	{
		my $self = shift;
		my $html = $self->{html};
		while ( $html =~ /{% if\((.*?)\) %}/ )
		{
			my $tag = $1;
			$html =~ s/{% if\($tag\) %}(.*){% endif\($tag\) %}//s;
		}
		while ( $html =~ s/{% (.*?) %}//s ){}
		$self->{html} = $html;
		return;
	}

	#-----------------------------------------------------------
	# 差し込み本体
	#-----------------------------------------------------------
	sub _Proc_Data
	{
		my $self = shift;
		my $tag  = $_[0];
		my $data = $_[1];
		my $sec  = 1;
		if (defined($_[2])){ $sec  = 0; }
		if($sec)
		{
			$data =~ s/&/&amp;/go;
			$data =~ s/>/&gt;/go;
			$data =~ s/</&lt;/go;
		}
		$self->{html} =~ s/{% dataValue\($tag\) %}/$data/g;
		return;
	}

	#-----------------------------------------------------------
	# if 差し込み
	#-----------------------------------------------------------
	sub Proc_SetIf
	{
		my $self = shift;
		my $tag  = $_[0];
		my $flg  = $_[1];
		if ( $self->{html} =~ /{% else\($tag\) %}/ )
		{
			if($flg)
			{
				$self->{html} =~ s/{% if\($tag\) %}//g;
				$self->{html} =~ s/{% else\($tag\) %}(.*){% endif\($tag\) %}//s;
			}else{
				$self->{html} =~ s/{% if\($tag\) %}(.*){% else\($tag\) %}//s;
				$self->{html} =~ s/{% endif\($tag\) %}//g;
			}
		}else{
			if($flg)
			{
				$self->{html} =~ s/{% if\($tag\) %}//g;
				$self->{html} =~ s/{% endif\($tag\) %}//g;
			}else{
				$self->{html} =~ s/{% if\($tag\) %}(.*){% endif\($tag\) %}//s;
			}
		}
		return;
	}

	#-----------------------------------------------------------
	# table 差し込み（入れ子の場合内側をGetSetしてから外側へ）
	#-----------------------------------------------------------
	sub Proc_GetTable
	{
		my $self = shift;
		my $tag  = $_[0];
		my $html = "";
		if( $self->{html} =~ m/{% tableblock\($tag\) %}(.*){% endtableblock\($tag\) %}/s ){ $html = $1; }
		$self->{html} =~ s/{% tableblock\($tag\) %}(.*){% endtableblock\($tag\) %}/{% settableblock\($tag\) %}/s;
		my %Conf = ( "path" => $self->{path}, "extn" => $self->{extn}, "html" => $html, "temp" => $html);
		my $TABLE = myPlugHtml->new(%Conf);
		return $TABLE;
	}
	
	sub Proc_MakeTable
	{
		my $self = shift;
		$self->{table} .= $self->{html};
		$self->{html} = $self->{temp};
		return;
	}
	
	sub Proc_SetTable
	{
		my $self = shift;
		my $tag  = $_[0];
		my $table = $_[1]->_Proc_TableCode;
		$self->{html} =~ s/{% settableblock\($tag\) %}/$table/g;
		return;
	}
	
	sub _Html_TableCode
	{
		my $self = shift;
		return $self->{table};
	}

	# --- HTML操作 ---

	#-----------------------------------------------------------
	# HTML差し込み
	#-----------------------------------------------------------
	sub Proc_Html
	{
		my $self = shift;
		return $self->_Proc_Data($_[0],$_[1],"NoSec");
	}

	#-----------------------------------------------------------
	# 本文差し込み
	#-----------------------------------------------------------
	sub Proc_Data
	{
		my $self = shift;
		return $self->_Proc_Data($_[0],$_[1]);
	}

	# --- FORM操作 ---

	#-----------------------------------------------------------
	# Textを入力状態へ
	#-----------------------------------------------------------
	sub Proc_FormValue
	{
		my $self = shift;
		my $tag  = $_[0];
		my $val  = $_[1];
		$val =~ s/\"/&quot;/go;
		$self->{html} =~ s/{% formValue\($tag\) %}/$val/g;
		return;
	}

	#-----------------------------------------------------------
	# Radioを選択状態へ
	#-----------------------------------------------------------
	sub Proc_FormRadio
	{
		my $self = shift;
		my $tag  = $_[0];
		my $val  = $_[1];
		while( $self->{html} =~ m/{% formRadio\($tag\[(.*?)]\) %}/s )
		{
			my $checkd = qq();
			if( $1 eq $val ){ $checkd = qq(checked="checked");}
			$self->{html} =~ s/{% formRadio\($tag\[$1]\) %}/$checkd/g;
		}
		return;
	}

	#-----------------------------------------------------------
	# Selectを選択状態へ
	#-----------------------------------------------------------
	sub Proc_FormSelect
	{
		my $self = shift;
		my $tag  = $_[0];
		my $val  = $_[1];
		while( $self->{html} =~ m/{% formSelect\($tag\[(.*?)]\) %}/s )
		{
			my $selected = "";
			if( $1 eq $val ){ $selected = qq(selected);}
			$self->{html} =~ s/{% formSelect\($tag\[$1]\) %}/$selected/g;
		}
		return;
	}

	#-----------------------------------------------------------
	# Errorメッセージ
	#-----------------------------------------------------------
	sub Proc_FormError
	{
		my $self = shift;
		my %val  = %{$_[0]};
		while( $self->{html} =~ m/{% formError\((.*?)\) %}/s )
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
			$self->{html} =~ s/{% formError\($tag\) %}/$value/g;
		}
		return;
	}

#----------------------------------------------------------------------------------------------------------
1;
