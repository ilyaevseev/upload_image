#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use POSIX 'strftime';

our $UPLOAD_DIR = "/var/www/html/upload_images";  # ..prepare: mkdir, chown root:apache, chmod 770
our $UPLOAD_URL = "/upload_images";

our %Allowed_extensions = ( gif=>1, jpeg=>1, jpg=>1, png=>1, svg=>1, blob=>1 );
our %Allowed_mimetypes  = (
	'image/gif'    =>1,
	'image/jpeg'   =>1,
	'image/pjpeg'  =>1,
	'image/x-png'  =>1,
	'image/png'    =>1,
	'image/svg+xml'=>1,
);

my $client = $ENV{HTTP_X_REAL_IP} || $ENV{REMOTE_ADDR} || 'nobody';

sub Fail {
	print "Content-type: text/json\n\n{ \"error\": \"@_\" }";
	die "Upload_image failed for client $client: @_\n";
}

my $contents;
my @metainfo;
my $mimetype  = "UNDEFINED";
my $extension = "UNDEFINED";

while(<>) {
	s/[\r\n]+$//;
	last if $_ eq '';
	$extension = $1 if /^Content-Disposition: form-data.*; filename=\"[^\"]+\.([^\"]+)\"/;
	$mimetype  = $1 if /^Content-Type: (.+\/.+)$/;
	push @metainfo, $_;
}

Fail "invalid MIME type $mimetype"  if not $Allowed_mimetypes{$mimetype};
Fail "invalid extension $extension" if not $Allowed_extensions{$extension};

{
	local $/ = undef;
	binmode STDIN;
	$contents = <STDIN>;
}

Fail "empty contents" if !defined($contents) or !length($contents);

my $filename = strftime("%Y-%m-%d-%H%M%S-$$", localtime).".".$extension;
my $filepath = "$UPLOAD_DIR/$filename";
my $metapath = "$filepath.__meta__";

open  F, '>', $filepath or Fail "cannot create file $filepath: $!";
binmode F;
print F $contents;
close F;

open  F, '>', $metapath or Fail "cannot create metainfo for $filepath: $!";
print F "$_\n" foreach @metainfo;
close F;

print "Content-type: text/json\n\n{ \"link\": \"$UPLOAD_URL/$filename\" }";

## END ##
