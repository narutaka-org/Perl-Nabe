
#----------------------------------------------------------------------------------------------------------
#	漢数字変換を万能に拡張
#		すべて万進法に統一
#----------------------------------------------------------------------------------------------------------

use utf8;
use strict;
use warnings;
use Encode;

use lib "./";
use myKanSuji;

#----------------------------------------------------------------------------------------------------------
#	Test Main
#----------------------------------------------------------------------------------------------------------

	#----------------------------------------------------------
	#サンプルコード
	#----------------------------------------------------------

	# --- 数字を漢数字に ---

	my $display1 = myKanSuji::num2ja("1000004000001");			# 一 京 四百 万 一
	my $display2 = myKanSuji::num2jaEx("1000004000001");		# 壱 京 四百 萬 壱
	
	print Encode::encode("utf-8",$display1) .qq(\n);
	print Encode::encode("utf-8",$display2) .qq(\n);
	print qq(\n);

	my $display3 = myKanSuji::num2ja("10000.000000400001");		# 一 億 寸 四 繊 一 漠
	my $display4 = myKanSuji::num2jaEx("10000.000000400001");	# 壱 億 寸 四 繊 壱 漠
	
	print Encode::encode("utf-8",$display3) .qq(\n);
	print Encode::encode("utf-8",$display4) .qq(\n);
	print qq(\n);

	# --- 日付を漢数字に ---

	my $display5 = myKanSuji::time2ja('A',"2017-10-10");
	my $display6 = myKanSuji::time2ja('AK',"2017-10-10");

	print Encode::encode("utf-8",$display5) .qq(\n);			# 西暦2017年10月10日
	print Encode::encode("utf-8",$display6) .qq(\n);			# 西暦 二千十七年 十月 十日
	print qq(\n);

	# --- 日付を和暦に ---

	my $display7 = myKanSuji::time2ja('T',"2017-10-10");

	print Encode::encode("utf-8",$display7) .qq(\n);			# 平成29年10月10日
	print qq(\n);

	my $displayA = myKanSuji::time2ja('TK',"2017-10-10");
	my $displayB = myKanSuji::time2ja('TE',"2017-10-10");

	print Encode::encode("utf-8",$displayA) .qq(\n);			# 平成 二十九年 十月 十日
	print Encode::encode("utf-8",$displayB) .qq(\n);			# 平成 弐拾九年 拾月 拾日
	print qq(\n);

	my $displayC = myKanSuji::time2ja('TJK',"2017-10-10");
	my $displayD = myKanSuji::time2ja('TJE',"2017-10-10");
	
	print Encode::encode("utf-8",$displayC) .qq(\n);			# 平成 二十九年 神無月 十日
	print Encode::encode("utf-8",$displayD) .qq(\n);			# 平成 弐拾九年 神無月 拾日
	print qq(\n);

	my $displayE = myKanSuji::time2ja('TJK',"2017-1-1");
	my $displayF = myKanSuji::time2ja('TJE',"2017-1-1");
	
	print Encode::encode("utf-8",$displayE) .qq(\n);			# 平成 二十九年 睦月 一日
	print Encode::encode("utf-8",$displayF) .qq(\n);			# 平成 弐拾九年 元旦
	print qq(\n);

#----------------------------------------------------------------------------------------------------------
0;
