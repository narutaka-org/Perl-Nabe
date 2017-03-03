
#----------------------------------------------------------------------------------------------------------
#	郵便番号のように電話番号も正規化できるか実験
#----------------------------------------------------------------------------------------------------------

use utf8;
use strict;
use warnings;

#----------------------------------------------------------------------------------------------------------
#	Test Main
#----------------------------------------------------------------------------------------------------------

	#10桁から13桁の数字だけで渡して
	#ハイフン付きで帰ってきたら成功
	#どれだけ意味があるかは、、、謎(笑)

	my $telno = "09091234567";
	my $cltel = &myCleanTel::strcleaningTel($telno);
	print qq($cltel);

0;

#----------------------------------------------------------------------------------------------------------
#	myCleanTel
#----------------------------------------------------------------------------------------------------------

package myCleanTel;

use strict;
use utf8;

	#-----------------------------------------------------------
	# 電話番号成形
	#-----------------------------------------------------------

	sub strcleaningTel
	{
		#データーは総務省でちょくちょく確認
		#http://www.soumu.go.jp/main_sosiki/joho_tsusin/top/tel_number/number_shitei.html
		#http://www.soumu.go.jp/main_sosiki/joho_tsusin/top/tel_number/shigai_list.html
		#http://www.soumu.go.jp/menu_news/s-news/01kiban06_02000056.html

		#  1999年01月01日 携帯電話・PHS11桁化 →  携帯「0010,020,030,040,080,090」PHS「050,060」から「090-N***-****」
		#  2001年03月01日 固定電話の番号ポータビリティ →  0120と0800 vs 0077と0088
		#  2006年10月24日 携帯電話番号ポータビリティ →  携帯番号から携帯会社名判別不能になる
		#  2013年11月01日 PHP電話番号ポータビリティ →  HPSで同上
		#  2014年10月01日 携帯電話とPHS間の番号ポータビリティ→  HPSと携帯の区別つかなくなる

		my $data = $_[0];

		#13桁は M2M専用
		if( $data =~ /^020([1|2|3|5|6|7|8|9])(\d{4})(\d{5})$/ ){ $data = "020-".$1.$2."-".$3;	return $data; }

		# 020-4番号帯は、発信者課金無線呼出し番号（ポケベルなど）)
		if( $data =~ /^0204(\d{2})(\d{3})$/ ){ $data = "020-4".$1."-".$2;	return $data; }

		#11桁は
		if( $data =~ /^0800(\d{3})(\d{4})$/ ){ $data = "0800-".$1."-".$2;	return $data; }
		if( $data =~ /^(\d{3})(\d{4})(\d{4})$/ ){ $data = $1."-".$2."-".$3;	return $data; }

		#10桁は
		if( $data =~ /^0120(\d{3})(\d{3})$/ ){ $data = "0120-".$1."-".$2;	return $data; }
		if( $data =~ /^0570(\d{3})(\d{3})$/ ){ $data = "0570-".$1."-".$2;	return $data; }
		if( $data =~ /^0990(\d{3})(\d{3})$/ ){ $data = "0990-".$1."-".$2;	return $data; }

		#一般
		if( $data =~ /^0(\d{1})(\d{1})(\d{1})(\d{1})(\d{1})(\d{4})$/ )
		{
			#市外局番分割 A-BCDE
			if(&chTelOA($1, $2))
			{
				$data = "0".$1."-".$2.$3.$4.$5."-".$6;	return $data;
			}
			#市外局番分割 ABCD-E
			if(&chTelOD("$1.$2.$3.$4"))
			{
				$data = "0".$1.$2.$3.$4."-".$5."-".$6;	return $data;
			}
			#市外局番分割 AB-CDE
			if(&chTelOB($1, $2, $3))
			{
				$data = "0".$1.$2."-".$3.$4.$5."-".$6;	return $data;
			}
			#市外局番分割 ABC-DE (残り全部)
			$data = "0".$1.$2.$3."-".$4.$5."-".$6;	return $data;
		}
		return $data;
	}

	sub chTelOA
	{
		my $cd1 = $_[0];
		my $cd2 = $_[1];
		if( $cd1 eq "3" ){ return 1; }
		if( $cd1 eq "6" ){ return 1; }
		if( $cd1 eq "4" ){ return &subInNum($cd2,"01"); }		#04-2は一部の地域で042のまま
		return 0; 
	}

	sub chTelOD
	{
		my @nu = (1267,1372,1374,1377,1392,1397,1398,1456,1457,1466,1547,1558,1564,1586,1587,1632,1634,1635,1648,1654,1655,1656,1658,4992,4994,4996,4998,5769,5979,7468,8387,8388,8396,8477,8512,8514,9496,9802,9912,9913,9969);
		foreach (@nu) { if( $_ eq $_[0] ){ return 1; } }
		return 0;
	}

	sub chTelOB
	{
		my $cd1 = $_[0];
		my $cd2 = $_[1];
		my $cd3 = $_[2];
		if( $cd1 eq "1" )
		{
			if( $cd2 eq "1" ){ return 1; }
			if( $cd2 eq "5" ){ return &subInNum($cd3,"013");       }
			if( $cd2 eq "7" ){ return &subInNum($cd3,"017");       }
			if( $cd2 eq "8" ){ return &subInNum($cd3,"0189");      }
			if( $cd2 eq "9" ){ return &subInNum($cd3,"069");       }
		}
		if( $cd1 eq "2" )
		{
			if( $cd2 eq "2" ){ return &subInNum($cd3,"127");       }
			if( $cd2 eq "3" ){ return &subInNum($cd3,"01269");     }
			if( $cd2 eq "4" ){ return &subInNum($cd3,"59");        }
			if( $cd2 eq "5" ){ return &subInNum($cd3,"123");       }
			if( $cd2 eq "6" ){ return &subInNum($cd3,"2");         }
			if( $cd2 eq "7" ){ return &subInNum($cd3,"1235");      }
			if( $cd2 eq "8" ){ return &subInNum($cd3,"16");        }
			if( $cd2 eq "9" ){ return &subInNum($cd3,"028");       }
		}
		if( $cd1 eq "4" )
		{
			if( $cd2 eq "2" ){ return &subInNum($cd3,"01345679");  }
			if( $cd2 eq "3" ){ return &subInNum($cd3,"0123457");   }
			if( $cd2 eq "4" ){ return 1; }
			if( $cd2 eq "5" ){ return 1; }
			if( $cd2 eq "6" ){ return &subInNum($cd3,"12489");     }
			if( $cd2 eq "7" ){ return &subInNum($cd3,"12347");     }
			if( $cd2 eq "8" ){ return &subInNum($cd3,"123456789"); }
			if( $cd2 eq "9" ){ return &subInNum($cd3,"012678");    }
		}
		if( $cd1 eq "5" )
		{
			if( $cd2 eq "2" ){ return 1; }
			if( $cd2 eq "3" ){ return &subInNum($cd3,"045");       }
			if( $cd2 eq "4" ){ return &subInNum($cd3,"012369");    }
			if( $cd2 eq "5" ){ return &subInNum($cd3,"29");        }
			if( $cd2 eq "8" ){ return &subInNum($cd3,"02389");     }
			if( $cd2 eq "9" ){ return &subInNum($cd3,"0123");      }
		}
		if( $cd1 eq "7" )
		{
			if( $cd2 eq "2" ){ return &subInNum($cd3,"02346789");  }
			if( $cd2 eq "3" ){ return &subInNum($cd3,"01234");     }
			if( $cd2 eq "5" ){ return 1; }
			if( $cd2 eq "6" ){ return &subInNum($cd3,"0249");      }
			if( $cd2 eq "7" ){ return &subInNum($cd3,"57");        }
			if( $cd2 eq "8" ){ return 1; }
			if( $cd2 eq "9" ){ return &subInNum($cd3,"23");        }
		}
		if( $cd1 eq "8" )
		{
			if( $cd2 eq "2" ){ return &subInNum($cd3,"1258");      }
			if( $cd2 eq "3" ){ return &subInNum($cd3,"012");       }		#「08396-」以外の0839は「083-9」
			if( $cd2 eq "4" ){ return &subInNum($cd3,"012349");    }
			if( $cd2 eq "6" ){ return &subInNum($cd3,"0124");      }
			if( $cd2 eq "7" ){ return &subInNum($cd3,"0123468");   }
			if( $cd2 eq "8" ){ return &subInNum($cd3,"1268");      }
			if( $cd2 eq "9" ){ return &subInNum($cd3,"019");       }
		}
		if( $cd1 eq "9" )
		{
			if( $cd2 eq "2" ){ return &subInNum($cd3,"123456789"); }
			if( $cd2 eq "3" ){ return &subInNum($cd3,"123456789"); }
			if( $cd2 eq "5" ){ return &subInNum($cd3,"138");       }
			if( $cd2 eq "6" ){ return &subInNum($cd3,"0123");      }
			if( $cd2 eq "7" ){ return &subInNum($cd3,"0156");      }
			if( $cd2 eq "8" ){ return &subInNum($cd3,"189");       }
			if( $cd2 eq "9" ){ return &subInNum($cd3,"01289");     }	#「09912-」「09913-」以外の0991は「099-1」
		}
		return 0;
	}

	sub subInNum
	{
		my @nu = split(//,$_[1]);
		foreach (@nu) { if( $_ eq $_[0] ){ return 1; } }
		return 0;
	}

#-----------------------------------------------------------------------------
exit;
