
#----------------------------------------------------------------------------------------------------------
#	全く新規にメール送るやつ
#		恐ろしく簡単になったもんです。
#----------------------------------------------------------------------------------------------------------

use utf8;
use strict;
use warnings;

use lib "./";
use mySendMail;

#----------------------------------------------------------------------------------------------------------
#	Test Main
#----------------------------------------------------------------------------------------------------------

	my $smtp = 'smtp.example.com';
	my $mSM = mySendMail->new($smtp);
	
	my $add  = 'user@smtp.example.com';
	if( $mSM->myEmailValid($add) )
	{
		#メール設定
		my $from = '"アドミン<"root@smtp.example.com>';
		my $to   = '"アカウント"<'.$add.'>';
		my $subj = 'タイトルが日本語でしかもある程度長くても自動で分割してくれる';
		my $body = '本文のテキスト部分、HTMLがあるときは見えない。';
		my $html = '<head><title>テスト</title></head><body>ほんぶん<br />HTMLメール<br />だよ</body></html>';

		#HTMLメール送信
		my $email1 = $mSM->myEmailMIME($from,$to,$subj,$body,$html);
		$mSM->myEmailSend($email1);

		#TEXTメール送信
		my $email2 = $mSM->myEmailMIME($from,$to,$subj,$body);
		$mSM->myEmailSend($email2);
	}

0;
