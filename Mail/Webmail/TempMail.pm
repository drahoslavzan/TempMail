#!/usr/bin/perl


# Perl API for "temp-mail.org" service.
#
# Copyright (C) 2014, Drahoslav Zan.
# 
# This module is free software; you
# can redistribute it and/or modify it under the same terms
# as Perl 5.10.0.
#
# This program is distributed in the hope that it will be
# useful, but without any warranty; without even the implied
# warranty of merchantability or fitness for a particular purpose.


package Mail::Webmail::TempMail;


use strict;
use warnings;

use HTML::TreeBuilder;
use HTML::TableExtract;
use LWP::UserAgent;
use Carp qw(croak);


###########################################################################
# CONSTANTS
###########################################################################

use constant SITE    => 'http://temp-mail.org';

use constant DELETE  => SITE . '/option/delete';
use constant ADDHOUR => SITE . '/option/time';
use constant REFRESH => SITE . '/option/refresh';
use constant CHANGE  => SITE . '/option/change';


###########################################################################
# METHODS
###########################################################################

sub new
{
	my ($class, $address) = @_;

	my $self = {
			_ua => LWP::UserAgent->new(
					ssl_opts => { verify_hostname => 1 },
					keep_alive => 1,
					requests_redirectable => [ 'GET', 'HEAD', 'POST' ],
			),
			_address => '',
	};

	$self->{_ua}->cookie_jar( {} );
	$self->{_ua}->agent('Mozilla/5.0 (X11; Linux x86_64; rv:26.0) Gecko/20100101 Firefox/26.0');
	push(@{ $self->{_ua}->requests_redirectable }, 'POST');

	bless $self, $class;

	$self->setAddress($address) if defined($address);

	return $self;
}

sub address
{
	my $self = shift;

	return $self->{_address} if $self->{_address};

	my $page = $self->{_ua}->get(SITE);
	croak "ERROR: " . $page->status_line . "\n" unless $page->is_success;

	my $tree = HTML::TreeBuilder->new;
	$tree->parse($page->content);

	my $address = $tree->look_down(_tag => 'b', id => 'email')->as_text;

	$self->{_address} = $address;

	$tree->delete;

	return $address;
}

sub user
{
	my $self = shift;

	my $address = $self->{_address};
	$address = $self->address if not $address;
	
	$address =~ /(.*)@/;

	return $1 if defined $1;
}

sub dispose
{
	my $self = shift;

	my $page = $self->{_ua}->get(DELETE, Referer => SITE);
	croak "ERROR: " . $page->status_line . "\n" unless $page->is_success;

	$self->{_address} = '';
}

sub addHour
{
	my $self = shift;

	my $page = $self->{_ua}->get(ADDHOUR, Referer => SITE);
	croak "ERROR: " . $page->status_line . "\n" unless $page->is_success;
}

sub setAddress
{
	my ($self, $address) = @_;

	my $page = $self->{_ua}->get(CHANGE, Referer => SITE);
	croak "ERROR: " . $page->status_line . "\n" unless $page->is_success;

	$address =~ /(.*)@(.*)/;

	my $login = $1;

	$page->content =~ m/<option\s+value="([0-9]+)">\@$2/;

	my $form = [
		login  => $login,
		domain => $1,
		expiry => 1,
	];

	$page = $self->{_ua}->post(CHANGE, $form);
	croak "ERROR: " . $page->status_line . "\n" unless $page->is_success;

	$self->{_address} = '';
}

sub inbox
{
	my $self = shift;

	my $page = $self->{_ua}->get(SITE, Referer => SITE);
	croak "ERROR: " . $page->status_line . "\n" unless $page->is_success;

	my $te = HTML::TableExtract->new(keep_html => 1, headers => [qw(Sender Subject)]);
	$te->parse($page->content);

	my ($t) = $te->tables;

	my @out;
	if(defined($t))
	{
		foreach my $r ($t->rows)
		{
			my $sender  = @$r[0];

			@$r[1] =~ m/href="(.*?)".*>(.*?)</;

			my $subject = $2;
			my $url     = $1;

			push(@out, { sender => $sender, subject => $subject, url => $url });
		}
	}

	wantarray ? @out : \@out;
}

sub refresh
{
	my $self = shift;

	my $page = $self->{_ua}->get(REFRESH, Referer => SITE);
	croak "ERROR: " . $page->status_line . "\n" unless $page->is_success;

	$page->content =~ m/until:\s*"\+([0-9]+)s",/;

	return $1;
}


return 1;
