
#----------------------------------------------------------------------------------------------------------
#	mySendMail
#----------------------------------------------------------------------------------------------------------

package mySendMail;

use utf8;
use strict;
use warnings;

use Email::Valid::Loose;
use Email::MIME;
use Email::Send;


#----------------------------------------------------------------------------------------------------------
#	Test Main
#----------------------------------------------------------------------------------------------------------

	# --- クラス生成 ---

	#-----------------------------------------------------------
	# クラス生成
	#-----------------------------------------------------------
	sub new
    {
		my ( $class, @args ) = @_;
		my $self = {};
		$self->{SMTP} = $args[0];
		return bless($self);
	}

	#-----------------------------------------------------------
	# 日本語メール生成
	#-----------------------------------------------------------

	sub myEmailMIME
	{
		my $self = shift;
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
	# メール送信
	#-----------------------------------------------------------

	sub myEmailSend
	{
		my $self = shift;
		my $email = $_[0];
		my $smtp  = $self->{SMTP};
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
	# アドレスチェック
	#-----------------------------------------------------------

	sub myEmailValid
	{
		my $self = shift;
		my $to = $_[0];
		if( $to =~ /\@(docomo|ezweb)\.ne\.jp$/ )
		{
			if( Email::Valid::Loose->address($to) ){ return 1; }
		}else{
			if( Email::Valid->address($to) ){ return 1; }
		}
		return 0;
	}

	#-----------------------------------------------------------
	# HTMLの日本語を文字参照に変換
	#-----------------------------------------------------------

	sub myEmailEncHtml
	{
		my $self = shift;
		my $html = $_[0];

		utf8::decode($htm);
		$html =~ s/([^\s\!-\~])/'&#'.ord($1).';'/eg;
		$html =~ s/\&\#65279;//g;
		$html =~ s/&#199#19979;/&#19979;/g;
		$html =~ s/[\t\r\n]//g;
		return $html;
	}

#-----------------------------------------------------------------------------
1;
