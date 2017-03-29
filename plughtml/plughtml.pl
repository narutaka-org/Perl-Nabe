
#----------------------------------------------------------------------------------------------------------
#	大昔、デザイナーが出してきたHTMLをそのまま置換するCGIを作ってこっぴどく怒られた。今ならありだよね（笑）
#	UTF8対応で、ついぐ風に改造してみました。むしろ、RailsかSymfony使わないと怒られるか、、、
#----------------------------------------------------------------------------------------------------------

use utf8;
use strict;
use warnings;

use lib "./";
use myPlugHtml;

#----------------------------------------------------------------------------------------------------------
#	Test Main
#----------------------------------------------------------------------------------------------------------

	#----------------------------------------------------------
	#サンプルコード
	#----------------------------------------------------------

	#	クラス生成
	#		my %Conf;
	#		my $HTML = myPlugHtml->new(%Conf);
	
	#	HTML生成
	#		$HTML->Html_Read("file");								#HTML読み込み
	#		$HTML->Html_Refresh($URL, $TIME, $TITLE, $BODY);		#リフレッシュページ
	#		$HTML->Html_Error($MSG);								#エラーページ

	#	HTML操作
	#		$HTML->Proc_SetIf("TAG",BOOL);							# IF 置換
	#		$HTML->Proc_Data("TAG","DATA");							# 本文 差し込み (タグは特殊文字に置換されます)

	#	FOR操作
	#		my $TEMP = $HTML->Proc_GetFor("TAG");
	#		for (::) {
	#			$TEMP->Proc_Data("TAG1","DATA1");
	#			$TEMP->Proc_Data("TAG2","DATA2");
	#			$TEMP->Proc_MakeFor;
	#		}
	#		$HTML->Proc_SetFor("TAG",$TEMP);						# FOR 置換

	#	TABLE操作
	#		my $TABLE = $HTML->Proc_GetTable("TAG");
	#		for (::) {
	#			$TABLE->Proc_Data("TAG1","DATA1");
	#			$TABLE->Proc_Data("TAG2","DATA2");
	#			$TABLE->Proc_MakeTable;
	#		}
	#		$HTML->Proc_SetTable("TAG",$TABLE);						# TABLE 置換

	#	FORM操作
	#		my %Form;
	#		$HTML->Proc_FormValue("TAG",$Form{"TAG"});				#Valueに差し込む（ダブルコーテーションは特殊文字に置換されます）
	#		$HTML->Proc_FormRadio("TAG",$Form{"TAG"});				#Radioを選択状態に
	#		$HTML->Proc_FormSelect("TAG",$Form{"TAG"});				#Selectを選択状態に
	#		my %Error;
	#		$HTML->Proc_FormError(\%Error);							#FormErrorを差し込む

	#	標準出力
	#		$HTML->Html_Shown();
	#		$HTML->Html_Shown(1);									# no-cacheヘッダー付き
	#		$HTML->Html_Shown(1,$COOKI);							# no-cacheヘッダー付き & ヘッダー追加

	#----------------------------------------------------------
	#テストコード
	#----------------------------------------------------------

	#初期値
	my %Conf = ( "path" => "./html/", "extn" => ".html" );
	
	#Page1表示
	if(0)
	{
		my $HTML = myPlugHtml->new(%Conf);
		$HTML->Html_Read("Page1");
		$HTML->Proc_SetIf("Student",0);
		$HTML->Proc_SetIf("discount",1);
		$HTML->Html_Shown();
		exit;
	}
	
	#Page2表示
	if(0)
	{
		my %Color = ( "black" => "#000000", "red" => "#ff0000", "yellow" => "#ffff00", "white" => "#ffffff" );
		my $HTML2 = myPlugHtml->new(%Conf);
		$HTML2->Html_Read("Page2");
		my $TABLE = $HTML2->Proc_GetTable("COLOR");
		foreach my $key(keys(%Color))
		{
			$TABLE->Proc_Data("COLOR_ID",$Color{$key});
			$TABLE->Proc_Data("COLOR_NAME",$key);
			$TABLE->Proc_MakeTable;
		}
		$HTML2->Proc_SetTable("COLOR",$TABLE);
		$HTML2->Html_Shown();
		exit;
	}
	
	#Page3表示
	if(0)
	{
		my $HTML3 = myPlugHtml->new(%Conf);
		$HTML3->Html_Read("Page3");
		my %Form = ( "NAME" => "Name Dasu", "AGE" => "B", "SEX" => "F", "MEMO" => "Test" );
		$HTML3->Proc_FormValue("NAME",$Form{"NAME"});
		$HTML3->Proc_FormSelect("AGE",$Form{"AGE"});
		$HTML3->Proc_FormRadio("SEX",$Form{"SEX"});
		$HTML3->Proc_Data("MEMO",$Form{"MEMO"});
		my %Error = ( "NAME" => "NAME ERROR", "AGE" => "AGE ERROR" );
		$HTML3->Proc_FormError(\%Error);
		$HTML3->Html_Shown();
		exit;
	}
	
	#Refresh表示
	if(0)
	{
		my $HTML4 = myPlugHtml->new();
		$HTML4->Html_Refresh("http://google.co.jp");
		$HTML4->Html_Shown();
		exit;
	}
	
	#PageA表示
	if(1)
	{
		my $HTML5 = myPlugHtml->new(%Conf);
		$HTML5->Html_Read("PageA");
		$HTML5->Proc_Data("PageTitle","時間割");
		#For開始
		my $TEMP1 = $HTML5->Proc_GetFor("Menu");
		for ( my $count = 1; $count < 3; $count++)
		{
			my $MenuTitle = $count.qq(年生);
			$TEMP1->Proc_Data("MenuTitle",$MenuTitle);
			#Table開始
			my $TABLE = $TEMP1->Proc_GetTable("Menu");
			my @Menu = ('月曜日','火曜日','・・・');
			foreach(@Menu)
			{
				$TABLE->Proc_Data("Menu",$_);
				$TABLE->Proc_MakeTable;
			}
			$TEMP1->Proc_SetTable("Menu",$TABLE);
			#Table終了
			$TEMP1->Proc_MakeFor;
		}
		$HTML5->Proc_SetFor("Menu",$TEMP1);
		#For終了
		$HTML5->Proc_Data("MainTitle","1年生の月曜日");
		$HTML5->Proc_Data("MainBody","今日はお昼までに帰りましょう");
		#For開始
		my $TEMP2 = $HTML5->Proc_GetFor("Body");
		my %JIKAN = ( "国語" => "教科書を読んでみましょう", "算数" => "リンゴとパイナップルを足してみましょう", "音楽" => "ロックを聴いてみましょう" );
		foreach my $key(keys(%JIKAN))
		{
			$TEMP2->Proc_Data("BodyTitle",$key);
			$TEMP2->Proc_Data("Body",$JIKAN{$key});
			$TEMP2->Proc_MakeFor;
		}
		$HTML5->Proc_SetFor("Body",$TEMP2);
		#For終了
		$HTML5->Html_Shown();
		exit;
	}
	exit;

#----------------------------------------------------------------------------------------------------------
0;
