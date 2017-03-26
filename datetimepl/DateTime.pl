
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

	my $dt = myDateTime->new;
	my $time1 = $dt->dtNow();
	my $time2 = $dt->dtNowAddS(24*60*60);
	my $time3 = $dt->dtNowAddD(-3);
	my $time4 = $dt->dtMakeD('2015-9-9 10:10:10');
	my $time5 = $dt->dtMakeD('2015-9-8');

	print $dt->fMyDT($time1) .qq(\n);
	print $dt->fMyD($time1) .qq(\n);
	print $dt->fMyM($time1) .qq(\n);
	print Encode::encode("utf-8", $dt->fMyDTJ($time1) ).qq(\n);
	print Encode::encode("utf-8", $dt->fMyDJ($time1) ).qq(\n);
	print Encode::encode("utf-8", $dt->fMyMJ($time1) ).qq(\n);
	print Encode::encode("utf-8", $dt->fMyDTJW($time1) ).qq(\n);
	print Encode::encode("utf-8", $dt->fMyDJW($time1) ).qq(\n);

	#----------------------------------------------------------
	#テストコード
	#----------------------------------------------------------

	#my $t = time;



	#print &fMyDT($time3);


	#print Dumper $time1 ;
	#print Dumper $time2 ;
	#print Dumper $time3 ;
	#print Dumper $time4 ;
	#print Dumper $time5 ;




#----------------------------------------------------------------------------------------------------------
0;
