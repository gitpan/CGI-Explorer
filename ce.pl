#!D:/Perl/Bin/Perl
#
# Name:
#	ce.pl.
#
# Purpose:
#	Test program for CGI::Explorer.

use integer;
use strict;
use warnings;

use CGI qw/fieldset legend/;
use CGI::Explorer;
use Tree::Nary;

# ---------------------------------------------------------------------------------

my(%hash) =
(
	1	=>
	{
		id			=> 1,
		name		=> 'Great grand gnome',
		parent_id	=> 0,

	},
	2	=>
	{
		id			=> 2,
		name		=> 'Great gnome',
		parent_id	=> 1,

	},
	3	=>
	{
		id			=> 3,
		name		=> 'Grand gnome',
		parent_id	=> 1,

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
my($tree)	= CGI::Explorer -> new();
my($dir)	= 'D:/Program Files/Apache Group/Apache';

# Choose 1 of these 2 alternatives.

# 1:
$tree -> from_dir($dir);

# 2:
#$tree -> from_hash(\%hash);

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
			'Tree'
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
			'Result'
		),
		'Id: ' . $tree -> current_id() . '. Name: ' . $tree -> name()
	);

# 2:
#my($result_set) = 'Id: ' . $tree -> current_id() . '. Name: ' . $tree -> name();

print	$q -> header(),
		$q -> start_html(),
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
