#! /usr/bin/perl

#*
#	Tk実験用三目並べ
#	Written by narutaka@minamide.org
#	Version : 3.0 ( 2017/03/22 )
#*

#--- φ(.. ) ---

	#

#--------------- 宣言 ---------------

	#use utf8;
	use 5.010;
	use strict;
	use warnings;

	use Tk;
	use Encode qw(decode);


#--------------- 変数 ---------------

	our $message = "";					#メッセージ
	our @game = (0,0,0,0,0,0,0,0,0);	#ゲーム盤情報
	our $canvas;						#キャンパスポインタ
	our $ford = 0;						#先攻後攻情報
	our $livel = 1;						#強さ

#--------------- 開始 ---------------

	&WinMain();

#--------------- 開始 ---------------

	#----------------------------------
	# メイン画面
	#----------------------------------
	sub WinMain
	{
		#画面生成
		my $top = MainWindow->new();
		my $menu = $top->Menu( -type => 'menubar' );
		   $top->configure( -menu => $menu );
		my $m1 = $menu->cascade(-label => decode('utf-8', "ファイル"),  -underline => 0, -tearoff => 0);
		   $m1->command(-label => decode('utf-8', "終了"), -underline => 0, -command => \&exit );
		my $m2 = $menu->cascade(-label => decode('utf-8', "強さ"),  -underline => 0, -tearoff => 0);
		   $m2->command(-label => decode('utf-8', "弱い"), -underline => 0, -command => [\&exit,1] );
		   $m2->command(-label => decode('utf-8', "普通"), -underline => 0, -command => [\&exit,2] );
		   $m2->command(-label => decode('utf-8', "強い"), -underline => 0, -command => [\&exit,3] );
		my $m3 = $menu->cascade(-label => decode('utf-8', "編集"), -underline => 0, -tearoff => 0);
		   $m3->command(-label => decode('utf-8', "リスタート"),  -underline => 0, -command => \&GameReset);
		my $label  = $top->Label( -textvariable => \$message )->pack( -anchor => 'w' );

		#三目盤面
		$canvas = $top->Canvas( -width => 210, -height => 210 )->pack();
		$canvas->create( 'rectangle', 10, 10, 200, 200, -fill => 'white' );
		$canvas->create( 'line', 15,  75, 195,  75 );
		$canvas->create( 'line', 15, 135, 195, 135 );
		$canvas->create( 'line', 15, 135, 195, 135 );
		$canvas->create( 'line', 75,  15,  75, 195 );
		$canvas->create( 'line', 135, 15, 135, 195 );
		&GameStart();														#ゲームスタート
		$canvas->pack();
		MainLoop();
	}

	#----------------------------------
	# 画面　（終了画面）
	#----------------------------------
	sub GameEnd
	{
		my $result = &ThGameCh();
		my $msg = "";
		if($result eq "1"){ $msg = decode('utf-8', "　引き分け　"); }
		if($result eq "2"){ $msg = decode('utf-8', "あなたの勝ち"); }
		if($result eq "3"){ $msg = decode('utf-8', "あなたの負け"); }
		my $id5 = $canvas->create( 'rectangle', 25, 90, 185, 110, -fill => 'green', -outline => 'white', -tags => "st5" );
		my $id6 = $canvas->create( 'text', 100, 100, -text => $msg, -fill => 'white', -tags => "st6"  );
		$canvas->bind( $id5, "<Button-1>" => [\&GameReset,1] );
		$canvas->bind( $id6, "<Button-1>" => [\&GameReset,1] );
	}

	#----------------------------------
	# 画面　（先攻・後攻　確認）
	#----------------------------------
	sub GameStart
	{
		#先攻後攻確認
		$message = decode('utf-8', "先攻か後攻を選んでください。");
		my	$id0 = $canvas->create( 'rectangle', 10, 10, 200, 200, -fill => 'grey', -tags => "st0" );
		my	$id1 = $canvas->create( 'rectangle', 25, 90, 95, 110, -fill => 'white', -outline => 'white', -tags => "st1" );
		my	$id2 = $canvas->create( 'text', 60, 100, -text => decode('utf-8', "先攻"), -tags => "st2"  );
		my	$id3 = $canvas->create( 'rectangle', 115, 90, 185, 110, -fill => 'white', -outline => 'white', -tags => "st3" );
		my	$id4 = $canvas->create( 'text', 150, 100, -text => decode('utf-8', "後攻"), -tags => "st4"  );
		$canvas->bind( $id1, "<Button-1>" => [\&FightMode,1] );
		$canvas->bind( $id2, "<Button-1>" => [\&FightMode,1] );
		$canvas->bind( $id3, "<Button-1>" => [\&FightMode,2] );
		$canvas->bind( $id4, "<Button-1>" => [\&FightMode,2] );
	}

	#----------------------------------
	# 画面　（ゲーム設定）
	#----------------------------------
	sub FightMode
	{
		#先攻後攻確認削除
		$canvas->delete("st0");
		$canvas->delete("st1");
		$canvas->delete("st2");
		$canvas->delete("st3");
		$canvas->delete("st4");
		if( $_[1] eq "1" )
		{
			$message = decode('utf-8', "あなたが先攻です。");
			$ford = 1;
		}else{
			$message = decode('utf-8', "あなたは後攻です。");
			$ford = 2;
			my $farst = int(rand(9));
			$game[$farst] = 1;
			&debug_game($farst);
		}
		&ButtonStart();
	}

	#----------------------------------
	# 画面　（ゲーム開始）
	#----------------------------------
	sub ButtonStart
	{
		for (my $i = 0; $i <= $#game; $i++)
		{
			#位置設定
			my ($x,$y) = (0,0);
			if( $i == 1 ){ $x +=  60; }
			if( $i == 2 ){ $x += 120; }
			if( $i == 3 ){            $y +=  60; }
			if( $i == 4 ){ $x +=  60; $y +=  60; }
			if( $i == 5 ){ $x += 120; $y +=  60; }
			if( $i == 6 ){            $y += 120; }
			if( $i == 7 ){ $x +=  60; $y += 120; }
			if( $i == 8 ){ $x += 120; $y += 120; }
		 	if( $game[$i] == 0 || $game[$i] == 1 )
			{
				#先攻
				$canvas->create( 'oval', 20+$x, 20+$y, 70+$x, 70+$y, -tags => "ff$i" );
			}
		 	if( $game[$i] == 0 || $game[$i] == 2 )
			{
				#後攻
				$canvas->create( 'line', 20+$x, 20+$y, 70+$x, 70+$y, -tags => "d1$i" );
				$canvas->create( 'line', 20+$x, 70+$y, 70+$x, 20+$y, -tags => "d2$i" );
			}
		 	if( $game[$i] == 0 )
			{
				#ボタン
				my $id = $canvas->create( 'rectangle', 20+$x, 20+$y, 70+$x, 70+$y, -fill => 'white', -outline => 'white', -tags => "bu$i" );
				$canvas->bind( $id, "<Button-1>" => [\&ButtonClick,$i] );
			}
		}
	}

	#----------------------------------
	# 画面　（ボタン差し替え）
	#----------------------------------
	sub ButtonSet
	{
		my $click = $_[0];
		my $con = &GetPlayCount() +1;
		if( $con % 2 )
		{
			$game[$click] = 1;
			$canvas->delete("bu$click");
			$canvas->delete("d1$click");
			$canvas->delete("d2$click");
		}else{
			$game[$click] = 2;
			$canvas->delete("bu$click");
			$canvas->delete("ff$click");
		}
	}

	#----------------------------------
	# 画面　（ゲーム再開）
	#----------------------------------
	sub GameReset
	{
		#盤面データーリセット
		@game = (0,0,0,0,0,0,0,0,0);
		#ボタン全削除
		for (my $i = 0; $i <= $#game; $i++)
		{
			if( $game[$i] eq "0" )
			{
				$canvas->delete("bu$i");
				$canvas->delete("d1$i");
				$canvas->delete("d2$i");
				$canvas->delete("ff$i");
			}
		}
		#終了画面削除
		$canvas->delete("st5");
		$canvas->delete("st6");
		&GameStart();
	}

	#----------------------------------
	# ボタンクリック
	#----------------------------------
	sub ButtonClick
	{
		&ButtonSet($_[1]);						#ボタン差し替え
		&debug_game($_[1]);						#デバッグ情報
		if( &ThGameCh() )
		{
			&GameEnd();
		}else{
			my $iti = &ThGameEn();				#PCターン
			&ButtonSet($iti);					#ボタン差し替え
			&debug_game($iti);					#デバッグ情報
			if( &ThGameCh() ){ &GameEnd(); }
		}
	}


#--------------- 三目 ---------------


	#----------------------------------
	# デバッグ
	#----------------------------------
	sub debug_game
	{
		my $con = &GetPlayCount();
		print qq( $con - $_[0] : @game \n);
	}


	#----------------------------------
	# 0以外のカウント（手数を出す）
	#----------------------------------
	sub GetPlayCount
	{
		my $temp= join('',@game);
		return 9-($temp =~ s/0//g);
	}

	#----------------------------------
	# 盤面チェック
	#----------------------------------
	sub ThGameCh
	{
		# 0:続行
		# 1:引き分け
		# 2:あなたの勝ち
		# 3:あなたの負け
		
		my @end = ('TTT******','***TTT***','******TTT','T***T***T','**T*T*T**','T**T**T**','*T**T**T*','**T**T**T');
		my $now= join('',@game);
		my $maru = $now; $maru =~ s/1/T/g;
		my $batu = $now; $batu =~ s/2/T/g;
		
		my $fine = 0;
		my $flg = "";
		foreach(@end)
		{
			if( &ListCh($_,$maru) ){ $fine = 1; $flg = $_; last; }
			if( &ListCh($_,$batu) ){ $fine = 2; $flg = $_; last; }
		}
		my $con = &GetPlayCount();
		
		if( $fine )
		{
			if( $fine == 1 )
			{
				if( $ford == 1 ){ return 2; }else{ return 3; }
			}else{
				if( $ford == 2 ){ return 2; }else{ return 3; }
			}
		}else{
			if( $con eq "9" ){ return 1; }
		}
		return 0;
	}
	
	#----------------------------------
	# リスト比較（三列パターン）
	#----------------------------------
	sub ListCh
	{
		my $flg = 1;
		my $A = $_[0];
		my $B = $_[1];
		my @AL = split(//,$A);
		my @BL = split(//,$B);
		for (my $i = 0; $i <= 8; $i++)
		{
			if( $AL[$i] ne "*" )
			{
				if( $BL[$i] ne "T" ){ $flg = 0; last; }
			}
		}
		return $flg;
	}
	
	#----------------------------------
	# PCターンを返す
	#----------------------------------
	sub ThGameEn
	{
		#常ランダムバージョン
		my @pos = ();
		for (my $i = 0; $i <= $#game; $i++)
		{
			if( $game[$i] eq "0" ){ push(@pos, "$i"); }
		}
		my $cot = @pos;
		return $pos[int(rand($cot))];
	}

#--------------- 終了 ---------------
exit(0);
