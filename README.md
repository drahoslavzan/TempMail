Perl Module Providing API for Accessing [temp-mail.org][tm] Service
===================================================================


### NAME:

> Mail::Webmail::TempMail - Perl module providing API for accessing
> [temp-mail.org][tm] service.


### SYNOPSIS:

~~~Perl
use strict;
use warnings;

use Mail::Webmail::TempMail;

# Get new or an existing mail address and show some informations about it.

my $mail = Mail::Webmail::TempMail->new;
# my $mail = Mail::Webmail::TempMail->new('jikoxafove@solvemail.info');

print "Address  = " . $mail->address . "\n";
print "User     = " . $mail->user    . "\n";
print "Time [s] = " . $mail->refresh . "\n";

$mail->addHour;

print "Time [s] = " . $mail->refresh . "\n";

# Set mail address to an existing one, inbox stay intact
# until time expiration.

$mail->setAddress('jikoxafove@solvemail.info');

# Read inbox.

my @inbox = $mail->inbox;

print "Inbox:\n";

foreach my $m (@inbox)
{
	print "\n";
	print "Sender  = " . $m->{sender}  . "\n";
	print "Subject = " . $m->{subject} . "\n";
	print "Url     = " . $m->{url}     . "\n";
}

# Delete all messages and dispose mail address.

$mail->dispose;
~~~

[tm]: http://temp-mail.org "TempMail"
