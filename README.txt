Mail/Webmail/TempMail.pm is Copyright (C) 2014, Drahoslav Zan.

# ==================================================================

# NAME:
# -----

# Mail::Webmail::TempMail - Perl module providing API for accessing
# "temp-mail.org" service.

# ==================================================================

# SYNOPSIS:
# ---------

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
# until time expire or user dispose mail address.

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

# ==================================================================

