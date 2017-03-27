
#----------------------------------------------------------------------------------------------------------
#	今なら「Time::Piece」を使うのかもしれませんが
#	大昔からのものをMySQKLと相性がいいものに修正、クラス化も実施
#----------------------------------------------------------------------------------------------------------

use utf8;
use strict;
use warnings;
use Encode;

use lib "./";
use myDateTime;

use Data::Dumper;

#----------------------------------------------------------------------------------------------------------
#	Test Main
#----------------------------------------------------------------------------------------------------------

	#----------------------------------------------------------
	#サンプルコード
	#----------------------------------------------------------

	# --- 生成 ---

	my $dt1 = myDateTime->new;								# 今の時間
	my $dt2 = myDateTime->new('S',int(24*60*60));			# 秒数加減
	my $dt3 = myDateTime->new('D','-3');					# 日数加減
	my $dt4 = myDateTime->new('E','123456789');				# UNIX time
	my $dt5 = myDateTime->new('T','2015-8-8 10:10:10');		# DateTime
	my $dt6 = myDateTime->new('T','2015-9-9');				# Date

	# --- 表示 ---

	print $dt1->PF('G') .qq(\n);							# Mon, 27-Mar-2017 05:55:48 GMT

	print $dt1->PF('M') .qq(\n);							# 2017-03
	print $dt1->PF('D') .qq(\n);							# 2017-03-27
	print $dt1->PF('T') .qq(\n);							# 14:55:48
	print $dt1->PF('DT') .qq(\n);							# 2017-03-27 14:55:48
	print $dt1->PF('DW') .qq(\n);							# 2017-03-27 Monday
	print $dt1->PF('DN') .qq(\n);							# 2017-03-27(Mon)
	print $dt1->PF('DWT') .qq(\n);							# 2017-03-27 Monday 14:55:48
	print $dt1->PF('DNT') .qq(\n);							# 2017-03-27(Mon) 14:55:48

	print Encode::encode("utf-8",$dt1->PF('JM')) .qq(\n);	# 2017年03月
	print Encode::encode("utf-8",$dt1->PF('JD')) .qq(\n);	# 2017年03月27日
	print Encode::encode("utf-8",$dt1->PF('JT')) .qq(\n);	# 14時55分48秒
	print Encode::encode("utf-8",$dt1->PF('JDT')) .qq(\n);	# 2017年03月27日 14時55分48秒
	print Encode::encode("utf-8",$dt1->PF('JDW')) .qq(\n);	# 2017年03月27日 月曜日
	print Encode::encode("utf-8",$dt1->PF('JDN')) .qq(\n);	# 2017年03月27日(月)
	print Encode::encode("utf-8",$dt1->PF('JDWT')) .qq(\n);	# 2017年03月27日 月曜日 14時55分48秒
	print Encode::encode("utf-8",$dt1->PF('JDNT')) .qq(\n);	# 2017年03月27日(月) 14時55分48秒

	# --- 比較 ---

	if( $dt1->E > $dt2->E ){ print qq(dt1:large \n); }else{ print qq(dt1:small \n); }
	if( $dt1->E > $dt3->E ){ print qq(dt1:large \n); }else{ print qq(dt1:small \n); }

	# --- 追加 ---

	$dt1->ADD('S',int(24*60*60));		#追加（秒）
	$dt1->ADD('M',int(24*60));			#追加（分）
	$dt1->ADD('H',int(24));				#追加（時）
	$dt1->ADD('D',int(1));				#追加（日）

#----------------------------------------------------------------------------------------------------------
0;
