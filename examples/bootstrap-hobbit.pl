#!/usr/bin/perl
#
# Name:
#	bootstrap-hobbit.pl.
#
# Purpose:
#	Test DBIx::Hash2Table.
#
# Note:
#	Lines 85 .. 86 allow you to control the output.
#
# Author:
#	Ron Savage <ron@savage.net.au>
#	http://savage.net.au/index.html

use strict;
use warnings;

use Data::Dumper;
use DBI;
use DBIx::Hash2Table;

# -----------------------------------------------

sub test
{
	my($dbh)	= @_;
	my(%hobbit) =
	(
		'Great grand gnome'	=>
		{
			code			=> 'G-g-g', # Code of 'Great grand gnome'.
			_url			=> '/test/test-menu.cgi',
			'Great gnome'	=>
			{
				code					=> 'G-g-one',
				_node_id				=> 'G_g_one_00',
				_url					=> '/test/test-fancy-hash.cgi',
				'Eldest great gnome'	=> {code => 'E-g-g-one'},
				'Youngest great gnome'	=> {code => 'Y-g-g'},
			},
			'Grand gnome' =>
			{
				code					=> 'G-g-two',
				_node_id				=> 'G_g_two_00',
				'Smartest grand gnome'	=> {code => undef},
				'Prettiest grand gnome'	=>
				{
					code			=> '',
					'Evil gnome'	=>
					{
						code				=> undef,
						'Evil gray gnome'	=> {code => ''},
						'Evil grey gnome'	=> {code => 'E-g-g-two'},
					},
				},
				'Long lost grand gnome'	=> {code => 'L-l-g-g'},
			},
		},
	);

	my($table_name)	= 'hobbit';

	print "Create table: $table_name. \n";
	print "\n";

	# The evals protect against non-standard SQL
	# and against a non-existant table.

	eval{$dbh -> do("drop table if exists $table_name")};
	eval{$dbh -> do("drop table $table_name") };

	my($sql) = "create table $table_name (id int, parent_id int, name varchar(255), code varchar(255), _url varchar(255), _node_id varchar(255) )";

	$dbh -> do($sql);

	print "Populate table. \n";
	print "\n";

	DBIx::Hash2Table -> new
	(
		hash_ref   => \%hobbit,
		dbh        => $dbh,
		table_name => $table_name,
		columns    => ['id', 'parent_id', 'name'],
		extras     => ['_node_id', '_url', 'code']
	) -> insert();

	my($data) = $dbh -> selectall_hashref("select * from $table_name", 'id');

	print "Dump hash. \n";
	print "\n";

	$Data::Dumper::Indent = 1;
	print Data::Dumper->Dump([$data], ['$hobbit']);

}	# End of test.

# -----------------------------------------------

print "$0. \n";
print "\n";

my($dbh) = DBI -> connect
(
	'DBI:mysql:test:127.0.0.1', 'root', 'toor',
	{
		AutoCommit			=> 1,
		HandleError			=> sub {Error::Simple -> record($_[0]); 0},
		PrintError			=> 0,
		RaiseError			=> 1,
		ShowErrorStatement	=> 1,
	}
);

test($dbh);
