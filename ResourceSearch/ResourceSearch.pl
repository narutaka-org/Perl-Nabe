
	# --------------------------------------------------------------------------
	#
	#	リソースが使われているかどうか調べてみるスクリプト
	#
	#		注1：Windows以外は試してないです
	#		注2：同名のリソースやソースは区別してません
	#		注3：手抜きなのでパスに日本語があるとだめです（ファイル名は可）
	#
	# --------------------------------------------------------------------------

	my $project = './Project';
	
	my $retyaml = './list.dat';
	
	my @resource = ('*.bmp','*.png','*.ico','*.jpg');
	my @source = ('*.cpp','*.c','*.h','*.rc','*.rc2','*.ini','*.html');

	use utf8;
	use strict;
	use warnings;
	use Encode;

	use Path::Tiny;
	use File::Find::Rule;
	use Encode::Guess;
	use Data::Dumper;

	#拡張子の大文字も追加
	sub uclen{ my @temp = (); foreach(@_){ push(@temp, uc($_)); } return @temp; }
	push(@resource, &uclen(@resource));
	push(@source, &uclen(@source));

	#リソースらしきファイル名取得
	my @failname = ();
	my @rcfiles = File::Find::Rule->file()->name( @resource )->in( $project );
	foreach(@rcfiles)
	{
		my $file = path(decode('Shift_JIS', $_));
		push(@failname, $file->basename);
	}

	#ソースらしきファイルを順に開く
	my %insose;
	my @scfiles = File::Find::Rule->file()->name( @source )->in( $project );
	foreach(@scfiles)
	{
		my $name = (path(decode('Shift_JIS', $_)))->basename;				#ソース ファイル名取得
		my $data = (path($_))->slurp;										#ソース コード取得
		my $enc  = guess_encoding($data, qw/euc-jp cp932 7bit-jis utf8/);
		if(ref $enc){}else{ print "$name enc [",$enc,"]\n"; next; }			#開けなかったファイル名表示
		my $utf8 = $enc->decode($data);
		foreach(@failname)
		{
			my @fname = split(/\./,$_);										#リソース名の拡張子を外す
			if( index($utf8, $_) >= 0 ){ push(@{$insose{$_}},$name); }
		}
	}

	#リソースごとにソース名を表示
	my $datafile = "";
	foreach my $key(keys(%insose))
	{
		$datafile .= qq(resource:'$key'\nsource:\n);
		foreach(@{$insose{$key}}){ $datafile .= qq(-'$_'\n); }
	}
	my $yaml = path($retyaml);
	$yaml->spew( { binmode => ':utf8' }, $datafile );

exit;
