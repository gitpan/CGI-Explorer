#!/usr/bin/perl
#
# Name:
#	ce.pl.
#
# Purpose:
#	Test program for CGI::Explorer.
#
# Author:
#	Ron Savage <ron@savage.net.au>
#	http://savage.net.au/index.html
#
# Licence:
#	Australian Copyright (c) 1999-2002 Ron Savage.
#
#	All Programs of mine are 'OSI Certified Open Source Software';
#	you can redistribute them and/or modify them under the terms of
#	The Artistic License, a copy of which is available at:
#	http://www.opensource.org/licenses/index.html

use strict;
use warnings;

use CGI qw/fieldset legend/;
use CGI::Explorer;

# ---------------------------------------------------------------------------------

my(%hash) =
(
	9	=>
	{
		id			=> 9,
		name		=> 'Great grand gnome',
		parent_id	=> 0,

	},
	2	=>
	{
		id			=> 2,
		name		=> 'Great gnome',
		parent_id	=> 9,

	},
	3	=>
	{
		id			=> 3,
		name		=> 'Grand gnome',
		parent_id	=> 9,

	},
	4	=>
	{
		id			=> 4,
		name		=> 'Eldest great gnome',
		parent_id	=> 2,

	},
	5	=>
	{
		id			=> 5,
		name		=> 'Youngest great gnome',
		parent_id	=> 2,

	},
	6	=>
	{
		id			=> 6,
		name		=> 'Smartest grand gnome',
		parent_id	=> 3,

	},
	7	=>
	{
		id			=> 7,
		name		=> 'Prettiest grand gnome',
		parent_id	=> 3,

	},
	8	=>
	{
		id			=> 8,
		name		=> 'Long lost grand gnome',
		parent_id	=> 3,

	},
);

# ---------------------------------------------------------------------------------

my($q)		= CGI -> new();
my($tree)	= CGI::Explorer -> new(css_color => 'maroon', sort_by => 'id');
my($dir)	= '/home/rons';

$tree -> image('root', 'explorer_server.gif');

# Choose 1 of these 2 alternatives.

# 1:
#$tree -> from_dir($dir);

# 2:
$tree -> from_hash(\%hash);

# The very first time thru, fabricate a 'state' for nodes being open/closed.
# The function 1 - ($_ % 2) returns 1 for even numbers, so even keys are open.
# This means oddd keys are closed. Since the root is 9, it is closed.
# When you open it, you'll see 2 is open, as expected for even keys.

if (! $q -> param('explorer_state') )
{
	my($s) = join(';', map{"$_=" . (1 - ($_ % 2) )} keys %hash);
	$q -> param('explorer_state', $s);
}

my($state) = $tree -> state($q); # Must follow from_dir() or from_hash().

# Choose 1 of these 2 alternatives.

# 1:
my($tree_set) =
	$q -> fieldset
	(
		{style => 'color: blue'},
		$q -> legend
		(
			{style => 'color: maroon'},
			"CGI::Explorer V $CGI::Explorer::VERSION " .
			$q -> img({src => '/images/explorer_root.gif', align => 'absmiddle', width => 17, height => 17})
		),
		$tree -> as_HTML($q)
	);

# 2:
#my($tree_set) = $tree -> as_HTML($q);

# Choose 1 of these 2 alternatives.

# 1:
my($result_set) =
	$q -> fieldset
	(
		{style => 'color: blue'},
		$q -> legend
		(
			{style => 'color: maroon'},
			'Node clicked'
		),
		'Id: ' . $tree -> current_id() . '. Name: ' . $tree -> name() . '. Depth: ' .
		$tree -> depth($tree -> current_id() ) . '. Sort option: ' . $tree -> get('sort_by')
	);

# 2:
#my($result_set) = 'Id: ' . $tree -> current_id() . '. Name: ' . $tree -> name();

print	$q -> header(),
		$q -> start_html(),
		$tree -> css(),
		$q -> start_form({action => $q -> url()}),
		$q -> hidden({name => 'explorer_state', value => $state, force => 1}),
		$q -> table
		(
			{border => 1},
			$q -> Tr
			([
				$q -> td($tree_set) .
				$q -> td($result_set),
			])
		),
		$q -> end_form(),
		$q -> end_html();