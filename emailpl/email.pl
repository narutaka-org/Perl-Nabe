
#----------------------------------------------------------------------------------------------------------
#	全く新規にメール送るやつ
#----------------------------------------------------------------------------------------------------------

	use utf8;
	use strict;
	use warnings;

	use Email::Valid::Loose;
	use Email::MIME;
	use Email::Send;

#----------------------------------------------------------------------------------------------------------
#	Test Main
#----------------------------------------------------------------------------------------------------------

	my $add  = 'user@smtp.example.com';
	my $smtp = 'smtp.example.com';
	if( myEmailValid($add) )
	{
		my $from = '"アドミン<"root@smtp.example.com>';
		my $to   = '"アカウント"<'.$add.'>';
		my $subj = 'タイトルが日本語でしかもある程度長くても自動で分割してくれる';
		my $body = '本文のテキスト部分、HTMLがあるときは見えない。';
		my $html = '<head><title>テスト</title></head><body>ほんぶん<br />HTMLメール<br />だよ</body></html>';
		
		my $email = myEmailMIME($from,$to,$subj,$body,$html);
		myEmailSend($email,$smtp);
		
		$email = myEmailMIME($from,$to,$subj,$body);
		myEmailSend($email);
	}

#----------------------------------------------------------------------------------------------------------
#	myEmailPl
#----------------------------------------------------------------------------------------------------------

	#-----------------------------------------------------------
	#日本語メール生成
	#-----------------------------------------------------------

	sub myEmailMIME
	{
		my $from = $_[0];
		my $to   = $_[1];
		my $subj = $_[2];
		my $body = $_[3];
		my $html = "";
		if( defined($_[4]) ){ $html = $_[4]; }
		if($html)
		{
			my $email = Email::MIME->create
			(
				header_str => [ From => $from, To => $to, Subject => $subj, ],
				attributes => { content_type => 'multipart/alternative', charset => 'UTF-8', encoding => 'base64', },
				parts => [
					Email::MIME->create(
						attributes => { content_type => 'text/plain', charset => 'UTF-8', encoding => 'base64', },
						body_str => $body,
					),
					Email::MIME->create(
						attributes => { content_type => 'text/html', charset => 'UTF-8', encoding => 'base64', },
						body_str => $html,
					),
				],
			);
			return $email;
		}else{
			my $email = Email::MIME->create
			(
				header_str => [ From => $from, To => $to, Subject => $subj, ],
				attributes => { content_type => 'text/plain', charset => 'UTF-8', encoding => 'base64', },
				body_str => $body,
			);
			return $email;
		}
	}

	#-----------------------------------------------------------
	#メール送信
	#-----------------------------------------------------------

	sub myEmailSend
	{
		my $email = $_[0];
		my $smtp  = "";
		if( defined($_[1]) ){ $smtp = $_[1]; }
		if($smtp)
		{
			my $sender = new Email::Send( { mailer => 'SMTP' } );
			$sender->mailer_args( [ Host => $smtp ] );
			$sender->send($email);
		}else{
			my $sender = Email::Send->new({mailer => 'Sendmail'});
			$sender->send($email);
		}
	}

	#-----------------------------------------------------------
	#アドレスチェック
	#-----------------------------------------------------------

	sub myEmailValid
	{
		my $to = $_[0];
		if( $to =~ /\@(docomo|ezweb)\.ne\.jp$/ )
		{
			if( Email::Valid::Loose->address($to) ){ return 1; }
		}else{
			if( Email::Valid->address($to) ){ return 1; }
		}
		return 0;
	}

#-----------------------------------------------------------------------------
exit;
