package CGI::Explorer;

# Name:
#	CGI::Explorer.
#
# Documentation:
#	POD-style documentation is at the end. Extract it with pod2html.*.
#
# Reference:
#	Object Oriented Perl
#	Damian Conway
#	Manning
#	1-884777-79-1
#	P 114
#
# Note:
#	o Tab = 4 spaces || die.
#
# Author:
#	Ron Savage <ron@savage.net.au>
#	Home page: http://savage.net.au/index.html
#
# Licence:
#	Australian copyright (c) 1999-2002 Ron Savage.
#
#	All Programs of mine are 'OSI Certified Open Source Software';
#	you can redistribute them and/or modify them under the terms of
#	The Artistic License, a copy of which is available at:
#	http://www.opensource.org/licenses/index.html

use strict;
use warnings;
no warnings 'redefine';

use Carp;

require 5.005_62;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use CGI::Explorer ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(

) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(

);
our $VERSION = '2.05';
our $myself;

# -----------------------------------------------

# Preloaded methods go here.

# -----------------------------------------------

# Encapsulated class data.

{
	my(%_attr_data) =
	(
		_behavior		=> 'classic',
		_css			=> '/css/xtree.css',
		_current_icon	=> '',
		_current_id		=> '',
		_current_key	=> '',
		_form_name		=> 'explorer_form',
		_hashref		=> {},
		_header_type	=> 'text/html;charset=ISO-8859-1',
		_js				=> '/js/xtree.js',
		_jscript		=> '',
		_left_style		=> 'position: absolute; width: 20em; top: 7em; left: 0.25em; padding: 0.25em; overflow: auto; border: 2px solid #e0e0e0;',
		_node_id		=> 'rm00000',
		_right_style	=> 'position: absolute; left: 20.25em; top: 7em; padding: 0.25em; border: 2px solid #e0e0e0;',
		_target			=> '',
		_tree			=> '',
		_url			=> '',
	);

	sub _default_for
	{
		my($self, $attr_name) = @_;

		$_attr_data{$attr_name};
	}

	sub _node_id
	{
		my($self) = @_;

		$$self{'_node_id'}++;
	}

	sub _scan_hash
	{
		my($self, $recursing, $hash, $parent, $previous_key) = @_;
		my($script)	= '';

		my($node_id, $new_key, $local_url, $shut_icon, $open_icon);

		# Due to the defined && croak test in hash2tree, we know this loop
		# will be executed only once by the original call from hash2tree.
		# (Recursive calls can execute the loop any number of times.)
		# This in turn means there will only be one $node_id generated
		# by the loop when _scan_hash is called by hash2tree.
		# We return this one $node_id to hash2tree for writing into the HTML.

		for my $key (sort grep{! /^_/} keys %$hash)
		{
			$node_id						= ( (ref($$hash{$key}) eq 'HASH') && $$hash{$key}{'_node_id'}) ? $$hash{$key}{'_node_id'} : $self -> _node_id();
			$local_url						= ( (ref($$hash{$key}) eq 'HASH') && $$hash{$key}{'_url'}) ? "$$hash{$key}{'_url'}/$node_id" : "$$self{'_url'}/$node_id";
			$new_key						= $previous_key ? "$previous_key$;$key" : $key;
			$$self{'_id2key'}{$node_id}		= $new_key;
			$$self{'_key2id'}{$new_key}		= $node_id;
			$$self{'_key2url'}{$new_key}	= $local_url;
			$shut_icon						= ( (ref($$hash{$key}) eq 'HASH') && $$hash{$key}{'_shut_icon'}) ? $$hash{$key}{'_shut_icon'} : '';
			$open_icon						= ( (ref($$hash{$key}) eq 'HASH') && $$hash{$key}{'_open_icon'}) ? $$hash{$key}{'_open_icon'} : '';
			$shut_icon = $open_icon			= $$self{'_current_icon'} if ($$self{'_current_id'} && ($$self{'_current_id'} eq $node_id) && $$self{'_current_icon'});

			if ($recursing)
			{
				$script .= <<EOS;
var $node_id = new WebFXTreeItem("$key", "$local_url");
EOS
			$script .= <<EOS if ($$self{'_target'});
$node_id.target = '$$self{'_target'}';
EOS
			$script .= <<EOS if ($shut_icon);
$node_id.icon = "$shut_icon";
EOS
			$script .= <<EOS if ($open_icon);
$node_id.openIcon = "$open_icon";
EOS
			$script .= <<EOS;
$parent.add($node_id);
EOS
			}
			else
			{
				$script = <<EOS;

if (document.getElementById)
{
var $node_id = new WebFXTree("$key", "$local_url");
$node_id.setBehavior('$$self{'_behavior'}');
EOS
	$script .= <<EOS if ($$self{'_target'});
$node_id.target = '$$self{'_target'}';
EOS
	$script .= <<EOS if ($shut_icon);
$node_id.icon = "$shut_icon";
EOS
	$script .= <<EOS if ($open_icon);
$node_id.openIcon = "$open_icon";
EOS
			}

			if (ref($$hash{$key}) eq 'HASH')
			{
				my($s, $rm)	= $self -> _scan_hash(1, $$hash{$key}, $node_id, $$self{'_id2key'}{$node_id});
				$script		.= $s;
			}
	 	}

		($script, $node_id);

	}	# End of _scan_hash.

	sub _standard_keys
	{
		keys %_attr_data;
	}
}

# -----------------------------------------------

sub hash2tree
{
	my($self, %arg) = @_;

	$self -> set(%arg);

	my(@root) = grep{! /^_/} keys %{$$self{'_hashref'} };

	# The highest subscript on the array 'keys %hash' must be 0 (ignoring special keys).

	defined($root[1]) && croak('Error: Your tree has more than 1 root');

	my($script)		= '';
	my($rm)			= '';
	($script, $rm)	= $self -> _scan_hash(0, $$self{'_hashref'}, '', '') if (ref($$self{'_hashref'}) eq 'HASH');
	$script			.= <<EOS if ($script);
document.write($rm);
}
EOS

	$$self{'_tree'} = $script;

	$$self{'_jscript'} . $script;

}	# End of hash2tree.

# -----------------------------------------------

sub get
{
	my($self, $arg) = @_;

	my($result);

	for my $attr_name ($self -> _standard_keys() )
	{
		my($arg_name) = $attr_name =~ /^_(.*)/;

		if (exists($$self{$attr_name}) && ($arg eq $arg_name) )
		{
			$result = $$self{$attr_name};
		}
	}

	$result;

}	# End of get.

# -----------------------------------------------

sub get_node
{
	my($self, %arg) = @_;

	$self -> set(%arg);

	$$self{'_current_key'}	= $self -> id2key();
	my(@current_key)		= split(/$;/, $$self{'_current_key'});
	my($node)				= $$self{'_hashref'};

	for my $current_key (@current_key)
	{
		$node = $$node{$current_key} if (ref($node) eq 'HASH');
	}

	$node;

}	# End of get_node.

# -----------------------------------------------

sub id2key
{
	my($self, %arg) = @_;

	$self -> set(%arg);

	$$self{'_current_key'} = $$self{'_id2key'}{$$self{'_current_id'} } ? $$self{'_id2key'}{$$self{'_current_id'} } : '';

}	# End of id2key.

# -----------------------------------------------

sub key2id
{
	my($self, %arg) = @_;

	$self -> set(%arg);

	$$self{'_key2id'}{$$self{'_current_key'} } ? $$self{'_key2id'}{$$self{'_current_key'} } : '';

}	# End of key2id.

# -----------------------------------------------

sub key2url
{
	my($self, %arg) = @_;

	$self -> set(%arg);

	$$self{'_key2url'}{$$self{'_current_key'} } ? $$self{'_key2url'}{$$self{'_current_key'} } : '';

}	# End of key2url.

# -----------------------------------------------

sub new
{
	my($caller, %arg)		= @_;
	my($caller_is_obj)		= ref($caller);
	my($class)				= $caller_is_obj || $caller;
	my($self)				= bless({}, $class);

	for my $attr_name ($self -> _standard_keys() )
	{
		my($arg_name) = $attr_name =~ /^_(.*)/;

		if (exists($arg{$arg_name}) )
		{
			$$self{$attr_name} = $arg{$arg_name};
		}
		elsif ($caller_is_obj)
		{
			$$self{$attr_name} = $$caller{$attr_name};
		}
		else
		{
			$$self{$attr_name} = $self -> _default_for($attr_name);
		}
	}

	$$self{'_hash'}		= '';
	$$self{'_id2key'}	= {};
	$$self{'_key2id'}	= {};
	$$self{'_key2url'}	= {};
	$myself				= $self;

	return $self;

}	# End of new.

# -----------------------------------------------

sub set
{
	my($self, %arg) = @_;

	for my $attr_name ($self -> _standard_keys() )
	{
		my($arg_name) = $attr_name =~ /^_(.*)/;

		if (exists($arg{$arg_name}) )
		{
			$$self{$attr_name} = $arg{$arg_name};
		}
	}

}	# End of set.

# -----------------------------------------------

1;

__END__

=head1 NAME

C<CGI::Explorer> - A class to manage displaying a hash tree of data, for use in CGI scripts

The format of the hash is discussed in the FAQ section.

=head1 Synopsis

Install /css/xtree.css, /js/xtree.js, and /images/*, as per the installation
instructions, below.

Then run the demos example/bootstrap-hobbit.pl, which creates a database table using C<DBIx::Hash2Table>, and then
example/hobbit.cgi, which reads a database table using C<DBIx::Table2Hash>.

Or, run example/hobbit-hash.cgi which has the same hash directly in the source code.

=head1 Description

C<CGI::Explorer> is a pure Perl module.

It is a support module for CGI scripts. It manages a hash, a tree of data, so that the script
can display the tree, and the user can single-click on the B<[+]> or B<[-]> of a node,
or double-click on the B<icon> of a node, to open or close that node's sub-tree.

Opening a node reveals all children of that node, and restores their open/closed state.

Closing a node hides all children of that node.

When you click on the text of a node, the node's id is submitted to the CGI script via
the path info of the URL attached to that node. This path info mechanism can be
overridden.

The id is assigned to the node when you call the method C<hash2tree()>, which is where the
module converts your hash into JavaScript.

Neither the module CGI.pm, nor any of that kidney, are used by this module.

=head1 Installation

The makefile will install /perl/site/lib/CGI/Explorer.pm.

You must manually install <Document Root>/css/xtree.css, <Document Root>/js/xtree.js, and
<Document Root>/images/explorer/*.

If you choose to put the CSS elsewhere, you'll need to call new(css => '/new/path/xtree.css').

If you choose to put the JavaScript elsewhere, you'll need to call new(js => '/new/path/xtree.js').

These last 2 options can be used together, and can be passed into C<hash2tree()> or C<set()> rather than
C<new()>.

If you choose to put the images elsewhere, you'll need to edit lines 69 .. 81 of xtree.js V 1.17.

=head1 Warning: V 1 'v' V 2

The API for C<CGI::Explorer> version 2 is not compatible with the API for version 1.

This is because version 2 includes CSS and JavaScript to handle expanding and
contracting sub-trees purely within the client. No longer do client mouse clicks cause
a round trip to the server/CGI script and back.

=head1 Constructor and initialization

new(...) returns a C<CGI::Explorer> object.

This is the class's contructor.

Almost every option is demonstrated by the program example/hobbit.cgi.

Note: All methods (except C<get()>) use named parameters.

Options:

=over 4

=item *

behavior

Usage: CGI::Explorer -> new(behavior => 'classic').

This option takes one of two values:

=over 4

=item *

classic

This is the default.

classic means the leaf nodes on the tree have a document icon.

=item *

explorer

explorer means the leaf nodes have a folder icon, ie they look like those in MS
Windows Explorer, even though they can't be opened.

=back

Note: I have adopted the non-Australian spelling of behavior, as used by Emil A Eklund in the
JavaScript shipped with C<CGI::Explorer>.

=item *

css

Usage: CGI::Explorer -> new(css => '/css/xtree.css').

This points to a file of CSS used to display the tree.

The default is '/css/xtree.css'.

Emil A Eklund is the author of xtree.css.

The make file does not install this CSS file automatically. You must install it
manually under the web server's document root.

=item *

current_icon

Usage: CGI::Explorer -> new(current_icon => '/path/to/image for current icon').

This option takes one of two values:

=over 4

=item *

'' (the empty string)

This is the default.

This stops the currently selected node from being given a special icon.

=item *

'/path/to/image for current icon'

Eg: the file '/images/current.png' is shipped with this module.

This gives the currently selected node the icon defined by the value of the string.

=back

=item *

current_id

Usage: CGI::Explorer -> hash2tree(current_id => $id, ...).

This is the value retrieved by you from the URL's path info, and passed into one of the methods.

The default value is ''.

=item *

current_key

Usage: $key = $explorer -> id2key() or $key = $explorer -> get('current_key').

This is the value of the string of keys, joined by $;, which lead from the root of the tree to the node whose id
is the value of current_id.

The default value is ''.

=item *

form_name

Usage: CGI::Explorer -> new(form_name => 'explorer_form').

This is simply a convenient place to store a default form name. Ignore this parameter if you wish.

The default is 'explorer_form'.

Warning: Under MS Internet Explorer, some words are reserved, and can not be used as form names. I think
you'll find 'explorer', and perhaps 'form', are reserved in such circumstances.

=item *

hashref

Usage: CGI::Explorer -> new(hashref => {...}).

This is a reference to a tree-structured hash which contains the data to be displayed.

From example/hobbit.cgi it will be clear that some CPAN modules' methods, eg my DBIx::Table2Hash -> select_tree(),
can return a hash suitable for passing directly into C<new()> or C<hash2tree()>.

The default is {}.

=item *

header_type

Usage: CGI::Explorer -> new(header_type => 'text/html;charset=ISO-8859-1').

This is simply a convenient place to store a default HTTP header type. Ignore this parameter if you wish.

The default is 'text/html;charset=ISO-8859-1'.

=item *

js

Usage: CGI::Explorer -> new(js => '/js/xtree.js').

This points to a file of JavaScript used to manipulate the tree.

The default is '/js/xtree.js'.

Emil A Eklund is the author of xtree.js.

The make file does not install this JavaScript file automatically. You must install it
manually under the web server's document root.

Note: I've made one systematic change to xtree.js V 1.15. I've changed lines 62 .. 74
to add a '/' prefix to the paths of the images. This means you should install the images/
directory under your web server's document root.

=item *

jscript

Usage: CGI::Explorer -> new(jscript => '...').

This is any JavaScript you wish, and which becomes the prefix of the JavaScript generated
to populate the tree from the given hash.

The default is ''.

Warning: Be clear about the differences between the 2 parameters 'js' and 'jscript'.

=item *

left_style

Usage: CGI::Explorer -> new(left_style => '<Some CSS>').

This is a string of CSS used to format the HTML div of the left-hand pane, ie the one
in which the tree is displayed.

The default is 'position: absolute; width: 20em; top: 7em; left: 0.25em; padding: 0.25em; overflow: auto; border: 2px solid #e0e0e0;'.

=item *

node_id

Usage: CGI::Explorer -> new(node_id => 'js_rm_00').

The default is 'rm00000', where rm stands for run mode.

See the FAQ for a discussion of the role of this parameter.

Note especially the warnings mentioned in the FAQ regarding the syntax of values for this option.

=item *

right_style

Usage: CGI::Explorer -> new(right_style => '<Some CSS>').

This is a string of CSS used to format the HTML div of the right-hand pane, ie the one
in which the CGI script's output is displayed.

The default is 'position: absolute; left: 20.25em; top: 7em; padding: 0.25em; border: 2px solid #e0e0e0;'.

=item *

target

Usage: CGI::Explorer -> new(target => '<name of a frame>').

Recall the operating environment: A CGI script uses this module, and that script has been
run, so the user is looking at a tree which contains clickable node names. That tree could
be in one frame, and you want clicks on node names to re-run the CGI script, and to have
the script's output go to a different frame than the frame containing the tree itself.

This option, then, allows you to have your script output to a named frame, and specifically
a frame different than the one which received the user's click on the node's name.

Note: After you use this option, clicks on nodes all output to the same frame.
You cannot use this option to direct clicks on node A to one frame and clicks on node
B to a different frame. In other words, this option is currently tree-wide, and cannot be
changed on a node-by-node basis.

If you are using CGI.pm, call header() thus:

	print $q -> header({type => 'text/html', target => 'right'});

Lincoln Stein's book on CGI.pm contains a mis-print on page 222 which says
frame => 'responses'. Do not use 'frame'.

As you can see, I pass an anonymous hash into every one of CGI.pm's methods. This always
works, whereas using '-type' etc sometimes fails silently :-(.

If you are using raw HTML, specify target thus:

	<a href = 'http://some.domain.net.au/cgi-bin/x.cgi' target = 'right'>Log in</a>

=item *

tree

Usage: $tree = $explorer -> get('tree').

This is the tree of JavaScript returned by C<hash2tree()>.

=item *

url

Usage: CGI::Explorer -> new(url => $q -> url() ).

This is a string for the URL to be submitted when the node's text is clicked.

The default is ''.

If you use C<CGI.pm>'s C<url()> method to obtain the default URL, you get something like
'http://127.0.0.1/perl/hobbit.cgi'. You're advised to shorten this to '/perl/hobbit.cgi'
before passing it into C<new()> or C<hash2tree()>, since a copy of this string is attached to each
node, and the shorter version saves you around 20 bytes per node.

Each node will, by default, be given the same URL, with only the path info varying
from node to node. The URL has the node's id appended as path info, when the node is copied from your hash and
inserted into the tree. Hence the node's URL will then be of the form "$url/$id".

See the FAQ for a discussion of how ids are generated.

It is this final URL, "$url/$id", which is passed back to your CGI script when a node's text is clicked.

It is up to you, as author of the CGI script, to know what to do, ie what code to execute, for a given id.

You can think of your CGI script as a callback, being triggered by events in the client. Then, this id is
what your callback uses to determine what action to take for each client request.

If you wish to override this system, use the reserved hash key '_url', as described in the FAQ.

=back

=head1 FAQ

Q: What is the format of this thing you call a 'hash tree'?

A: It is simply a hash, with these characteristics:

=over 4

=item *

It has a single root.

So, if your hash looks like this:

	my($h) = {Key => {...} };

then you can pass $h into method C<hash2tree()>.

But, if you hash has multiple roots like this:

	my($h) = {Key_1 => {...}, Key_2 => {...} };

you must call C<hash2tree()> like this:

	$explorer -> hash2tree(hashref => {Mother_Of_All_Roots => $h});

so as to ensure hashref points to a hash with a single root.

=item *

Hash keys are displayed in sorted order

This uses Perl's default sorting mechanism.

=item *

Keys and sub-keys

Keys either point to a string, eg undef, '' or 'Data', or keys point to hashrefs, which is what makes the hash a
tree. Eg:

	my($h)={Root=>{Key_1=>undef,Key_2=>{Key_3=>{...},Data=>''},Key_4=>{}};

Note: See how Key_4 can point to an empty hash.

See example/hobbit-hash.cgi for a CGI script with a hash embedded in the source.

See example/bootstrap-hobbit.pl for a command line script with the same hash embedded in the source, and which writes
the hash to a database table. See example/hobbit.cgi for a CGI script which reads and displays that database table.

Note: Some of the URLs in the demo hash point to non-existant CGI scripts. It's a demo, after all.

=item *

All hash keys matching /^_/ are treated specially

That is, they are ignored when building the visible part of the tree.

This is slightly unusual, so read slowly :-).

=over 4

=item *

Hash keys matching /^_node_id$/ are used to override the default id appended to a node's URL

See the discussion of _url 2 items down for details.

=item *

Hash keys matching /^_(open|shut)_icon$/ are special

These apply to each node, and hence could be different for every node.

These options allow you to specify an image for when a specific node is in the open and/or closed state.

Note: The _current_icon parameter to new() applies to the tree as a whole.

=item *

Hash keys matching /^_url$/ are used to override the default URL of a node

Given a hash key like:

Mega_key => {Nested_key_if_any => {} }

then the default URL attached to the node labelled Mega_key is overridden thus:

Mega_key => {_url => 'Special URL', Nested_key_if_any => {} }

See how _url is a sub-key (child) of the key who actually owns this URL.

Clearly, this overriding mechanism operates on a node-by-node basis, so any node can
be given any node id and/or URL.

Even when this option is used, the node's id is still appended to this special URL as path info.

=back

=item *

The tree must be constant

The hash used to build the tree must be constant from one execute of the CGI script
to the next, or the id generated for a node on the first execute and hence returned by the
client may not match the id generated for the same node on the second execute.

=item *

Bugs in Apache/mod_perl/Perl/CGI.pm

In this environment: Win2K, Apache 1.3.26, mod_perl 1.27_01-dev, Perl 5.6.1, CGI.pm 2.89,
the CGI method path_info(), when given a URL without any path info, returns the path info
from the previous submit, but only if the CGI script is running as an Apache::Registry script.
When the CGI script is run as a simple cgi-bin script, this bug is not manifest.

This is very like the behavior of my()-scoped variables in nested subroutines, documented
here:

http://perl.apache.org/docs/general/perl_reference/perl_reference.html

Click on: 'my() Scoped Variable in Nested Subroutines' for details.

You have been warned.

=back

Q: Why use em rather than px in left_style and right_style?

A: The designers of CSS2, Hakon Lie and Bert Bos, recommend using relative sizes, and specifically em.

Q: Why does my tree display 'funny'?

A: Because browsers vary in how well they render CSS.

Under Win2K, IE 6.00.2600, the style 'overflow: auto' in left_style renders as it
should.

Under Win2K, IE 5.00.3502, 'overflow: auto' renders as though you had specified
'overflow: visible'.

Q: How do I configure Apache V 2 to use /perl/ the way you recommend in the next Q?

A: Add these options to httpd.conf and restart the server:

	Alias /perl/ "/apache2/perl/"
	<Location /perl>
		SetHandler perl-script
		PerlResponseHandler ModPerl::Registry
		Options +ExecCGI
		PerlOptions +ParseHeaders
		Order deny,allow
		Deny from all
		Allow from 127.0.0.1
	</Location>

Q: How do I run the demo?

A: Install example/hobbit.cgi as /apache2/perl/hobbit.cgi and run it via your browser, by typing

	http://127.0.0.1/perl/hobbit.cgi

into your browser. Study the screen.

Now, click on the [+] signs to open the tree until you can see 'Evil Grey Gnome', noting the spelling of Grey.

Now click on the text 'Evil Grey Gnome'.

Lastly, click on 'Prettiest grand gnome' in the breadcrumb trail. Neat, huh?

Note: The update button in example/hobbit.cgi does not actually do anything.

Q: How are node ids generated?

A: Well, by rolling your mouse over the nodes' texts, you can see in the browser's status line URLs like:

	http://127.0.0.1/perl/hobbit.cgi/rm00006

(for Evil Grey Gnome)

These ids are generated sequentially, starting with 'rm00000'. So, the second id will be 'rm00001', and so on.

The initial value is the default value for the node_id parameter to C<new()> or C<hash2tree()>.

Hence you can control the values of the ids by initializing the node_id parameter, subject to the warnings
which follow.

Values for node_id are generated for all nodes in the hash tree for which you have not supplied a node-specific
value for node_id.

Warning:

=over 4

=item *

The node_id string has a trailing integer

The code C<$$self{'_node_id'}++;> is used to increment ids. This means that if you wish to override the default
value for node_id, you absolutely must supply an initial value for node_id which has a nice set of trailing zeros
(just like the cheque you're thinking of sending me for releasing such a great module :-).

Hence the default value 'rm00000'.

Warning: You can't use a value like '_00' because Perl discards the '_' when incrementing such a string.

=item *

All values of the node_id string are the names of JavaScript variables

This means that if you wish to override the default value for node_id, you absolutely must supply a value
for node_id which is a valid JavaScript variable name.

Hence the default value 'rm00000'.

Hence, also, the values in the _node_id column of the hobbit table generated by the program
example/bootstrap-hobbit.cgi.

=back

Q: How is the breadcrumb trail in example/hobbit.cgi generated?

A: See the source.

Q: How do I know when to pass a given parameter in to a method? Eg: Do I call C<new()> or C<hash2tree()> to
set a value for node_id or current_icon?

A: You can pass in any parameter to any method (except C<get()>) at any time before that parameter is actually needed.

All methods (except C<get()>) take a list of named parameters, and store the values of the parameters internally
within the object.

So, when you see this code in example/hobbit.cgi:

	my($tree)       =$explorer->hash2tree(current_id=>$current_id,hashref=>$hash);
	my($current_key)=$explorer->id2key();

you know the call to C<id2key()> must be using the value of current_id passed in in the call to C<hash2tree()>.

You could have used this code:

	my($tree)       =$explorer->hash2tree(hashref=>$hash);
	my($current_key)=$explorer->id2key(current_id=>$current_id);

but that would mean the value of current_id was not available during the call to C<hash2tree()>, so the
current node in the tree could not have had the special icon designated by the value of the parameter
current_icon (if you passed in a value for current_icon in the call to C<new()> or C<hash2tree()> of course.),
because at the time of calling C<hash2tree()>, the code in that module would not know the value of current_id.

Even worse, if current_id somehow had a value from a previous call to a method, the wrong node would be flagged as
the current node.

Q: I'm running on a Pentium II at 266MHz. I'm finding that as I get up to many hundreds of nodes, it takes a
long time to update the screen.

A: Yes.

Emil has kindly offered to work on speeding things up. I have one idea, but have not tried implementing it yet.

=head1 Method: hash2tree(current_id => $current_id, hashref => $hash)

Returns the JavaScript which populates the tree.

You can also retrieve this JavaScript by calling:

	$explorer -> hash2tree(hashref => $hashref);
	my($tree) = $explorer -> get('jscript') . $explorer -> get('tree');

Note: $explorer -> get('js') returns the name of the file of JavaScript written by Emil, ie
'/js/xtree.js', by default. Try not to get the 2 options 'js' and 'jscript' confused. It'll make you look
silly :-).

The 2 parameters listed here are those you would normally pass into C<hash2tree()>, but you are not limited to
these parameters.

=head1 Method: get('Name of object attribute')

Returns the value of the named attribute. These attributes are discussed above, in the
section called 'Constructor and initialization'.

The demo example/hobbit.cgi calls this method a number of times.

=head1 Method: get_node([current_id => $id])

Returns a hash ref.

The [] refer to an optional parameter, not to an array ref.

This method uses the value of current_id to find and return the node corresponding to current_id.

If current_id is '', the get_node returns the value you previously passed in for the hashref option.

=head1 Method: id2key([current_id => $id])

Returns a string.

The [] refer to an optional parameter, not to an array ref.

This method converts a node id, eg retrieved from the path info, into a string which contains,
in order, all hash keys required to find the node within the tree.

The hash keys are separated by $;, aka $SUBSCRIPT_SEPARATOR.

The demo example/hobbit.cgi has an example which uses this method.

=head1 Method: key2id([current_key => $key])

Returns a string.

The [] refer to an optional parameter, not to an array ref.

This method converts a string of hash keys, concatenated with $;, into the corresponding
node id.

By default, this method uses the value of current_key generated by a previous call to C<id2key()>.

=head1 Method: key2url([current_key => $key])

Returns a string.

The [] refer to an optional parameter, not to an array ref.

This method converts a string of hash keys, concatenated with $;, into the corresponding
node URL.

By default, this method uses the value of current_key generated by a previous call to C<id2key()>.

=head1 Method: new(...)

Returns a object of type C<CGI::Explorer>.

See above, in the section called 'Constructor and initialization'.

=head1 Method: set(%arg)

Returns nothing.

This allows you to set any option after calling the constructor.

Eg: $explorer -> set(css => '/css/even_better.css');

=head1 Icons for Nodes

C<CGI::Explorer> ships with an images/ directory containing 1 or 2 (open/closed) PNGs
for each icon.

Most of these icons are those shipped by Emil A Eklund in his xtree package.

I have added 3 icons to the set, all from this web site:

http://www.geocities.com/windowsicons/

=over 4

=item *

open.png

Collection: Replacements for Win95/98 system-icons.

Original icon file: foldrs02.ico.

=item *

shut.png

Collection: Replacements for Win95/98 system-icons.

Original icon file: foldrs01.ico.

=item *

current.png

Collection: Pointers, arrows and hands.

Original icon file: 'arrow #3.ico'.

=back

The make file does not install this images/ directory automatically. You must install it
manually under the web server's document root.

=head1 Required Modules

None, not even CGI.pm. Well OK, one - Exporter.

In particular, the fine module Tree::Nary, used in V 1 of C<CGI::Explorer>, is
no longer needed.

=head1 Changes

See Changes.txt.

=head1 Credits

C<CGI::Explorer> V 2 depends heavily on the superb package xtree, written by Emil A Eklund,
and in fact my module is no more than a Perl wrapper around xtree.

Please visit the web site http://www.eae.net (from his initials) where more goodies by
Emil and his colleague Erik Arvidsson are on display.

=head1 Unused Namespace - DBIx::CSS::TreeMenu

In the POD for 2 recent modules, I intimated I was going to release a module called
DBIx::CSS::TreeMenu, which of course was to be based on xtree.

However, I've since decided to incorporate these ideas into C<CGI::Explorer> V 2.

There is clearly no need for the current module to be linked into the DBIx:: namespace.
Further, CSS is a mechanism used, and while it could be in the namespace, I no longer think
that is appropriate. Otherwise, any module using CSS would have CSS:: in it's name,
and taken to the illogical extreme, all modules would be in the Perl:: namespace!

So, I'm abandoning all plans to issue a module called DBIx::CSS::TreeMenu.

However, I still have my eye on another package, by Erik Arvidsson, called tabpane.
I am intending to put a Perl wrapper around tabpane, but have not yet decided on a
Perl module name.

=head1 Author

C<CGI::Explorer> was written by Ron Savage I<E<lt>ron@savage.net.auE<gt>> in 2001.

Home page: http://savage.net.au/index.html

=head1 Copyright

Australian copyright (c) 2001, Ron Savage. All rights reserved.

	All Programs of mine are 'OSI Certified Open Source Software';
	you can redistribute them and/or modify them under the terms of
	The Artistic License, a copy of which is available at:
	http://www.opensource.org/licenses/index.html

=cut
