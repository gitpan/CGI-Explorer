#!/usr/bin/perl
#
# Name:
#	hobbit.cgi.
#
# Purpose:
#	Test CGI::Explorer V 2.
#
# Note:
#	Tab = 4 spaces || die.
#
# Author:
#	Ron Savage <ron@savage.net.au>
#	http://savage.net.au/index.html

use strict;
use warnings;

use CGI;
use CGI::Explorer;
use DBI;
use DBIx::Table2Hash;
use Error qw/:try/;

# -----------------------------------------------

my($title)		= 'Test CGI::Explorer';
my($q)			= CGI -> new();
my($url)		= $q -> url();
my($current_id)	= $q -> path_info() || '';
$current_id		=~ s|^/||;

my($explorer, @html);

try
{
	my($dbh) = DBI -> connect
	(
		'DBI:mysql:test:127.0.0.1',
		'root',
		'toor',
		{
			AutoCommit			=> 1,
			HandleError			=> sub {Error::Simple -> record($_[0]); 0},
			PrintError			=> 0,
			RaiseError			=> 1,
			ShowErrorStatement	=> 1,
		}
	);
	my($hash) = DBIx::Table2Hash -> new
	(
		dbh				=> $dbh,
		table_name		=> 'hobbit',
		key_column		=> 'name',
		child_column	=> 'id',
		parent_column	=> 'parent_id'
	) -> select_tree;
	$explorer			= CGI::Explorer -> new(behavior => 'explorer', current_icon => '/images/current.png', url => $url);
	my($tree)			= $explorer -> hash2tree(current_id => $current_id, hashref => $hash);
	my($current_key)	= $explorer -> id2key();
	my(@current_key)	= split(/$;/, $current_key);
	my($breadcrumb)		= '';

	my($crumb);

	for (0 .. $#current_key)
	{
		$crumb		= $q -> a({href => $explorer -> key2url(current_key => join($;, @current_key[0 .. $_]) )}, $current_key[$_]);
		$breadcrumb	.= ($_ ? (' ' x ($_ - 1) . ' &gt; ') : '') . $crumb;
	}

	$breadcrumb	= 'Your breadcrumb trail here' if (! $breadcrumb);
	my($name)	= 'field01';

	if (@current_key)
	{
		@current_key	= map{$name++; $q -> td($q -> textfield({name => $name, size => 60, value => $_}) )} @current_key;
		my($node)		= $explorer -> get_node();

		push @current_key, map{$q -> td("$_: $$node{$_}")} grep{ref($$node{$_}) ne 'HASH'} sort keys %$node if (ref($node) eq 'HASH');
		push @current_key, $q -> td($q -> submit({name => $name, style => 'background: #80c0ff', value => 'Update'}) );
	}
	else
	{
		@current_key = $q -> td('No items selected yet');
	}

	my($table) = $q -> table($q -> Tr([@current_key]) );

	my($mids) = $q -> span({style => 'color: #0000ff; text-align: center; width: 80%'}, 'Hobbits and Hackers');
	push(@html, $q -> div({style => 'position: absolute; top: 0.25em; left: 0.25em; padding: 0em; overflow: auto; height: 2.50em; width: 100%; border-bottom: solid thin #e0e0e0;'}, 'Your logo here' . $mids) );
	my($menu) = $q -> span({style => 'color: #0000ff; text-align: left; width: 80%'}, 'Your menu here');
	push(@html, $q -> div({style => 'position: absolute; top: 3.00em; left: 0.25em; padding: 0em; overflow: auto;'}, $menu) );
	$breadcrumb = $q -> span({style => 'color: #0000ff; font-size: 10pt'}, $breadcrumb);
	push(@html, $q -> div({style => 'position: absolute; top: 4.50em; left: 0.25em; padding: 0em; overflow: auto; '}, $breadcrumb) );
	push(@html, $q -> div({style => $explorer -> get('left_style')}, $q -> script({language => 'JavaScript'}, $tree) ) );
	push(@html, $q -> div({style => $explorer -> get('right_style')}, $table) );
}
catch Error::Simple with
{
	my($error) = $_[0] -> text();
	chomp $error;
	push(@html, $q -> th('Error') . $q -> td($error) );
};

print	$q -> header({type => $explorer -> get('header_type')}),
		$q -> start_html({script => {src => $explorer -> get('js')}, style => {src => $explorer -> get('css')}, title => $title}),
		$q -> start_form({action => $url, name => $explorer -> get('form_name')}),
		@html,
		$q -> end_form(),
		$q -> end_html();
