package CGI::Explorer;

# Reference:
#	Object Oriented Perl
#	Damian Conway
#	Manning
#	1-884777-79-1
#	P 114

use integer;
use strict;
use warnings;

use CGI;
use File::Find;
use Tree::Nary;

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
our $VERSION = '1.12';

# ---------------------------------------------------------------------------------

# Preloaded methods go here.

# An alias for $self, used in subs not called with a object ref as the 1st param.
# Specifically, used in _found(), which is called by File::Find.

use vars qw($myself);

# ---------------------------------------------------------------------------------

# Encapsulated class data.

{
	my(%_attr_data) =
	(
		_click_text		=> 1,
		_css			=> <<EOS,
<style type = 'text/css'>
<!--
input.explorer
{
background:_css_background;
border-top-width:0px;
border-bottom-width:0px;
border-left-width:0px;
border-right-width:0px;
color:_css_color;
font-family:tahoma;
font-size:8pt;
font-weight:bold;
width:auto;
}
-->
</style>
EOS
		_css_background	=> 'white',
		_css_color		=> 'navy',
		_image_dir		=> '/images',
		_show_current	=> 1,
		_show_id		=> 1,
		_show_name		=> 1,
		_sort_by		=> 'name',
	);

	my(%_icon_data) =
	(
		'root'	=>
		{
			clickable	=> 0,
			image		=> 'explorer_root.gif',
		},
		'**'	=>
		{
			clickable	=> 1,
			image		=> 'explorer_current_node.gif',
		},
		'-L'	=>
		{
			clickable	=> 1,
			image		=> 'explorer_minus_elbow.gif',
		},
		'--'	=>
		{
			clickable	=> 1,
			image		=> 'explorer_minus_tee.gif',
		},
		'+L'	=>
		{
			clickable	=> 1,
			image		=> 'explorer_plus_elbow.gif',
		},
		'+-'	=>
		{
			clickable	=> 1,
			image		=> 'explorer_plus_tee.gif',
		},
		' L'	=>
		{
			clickable	=> 0,
			image		=> 'explorer_elbow.gif',
		},
		' -'	=>
		{
			clickable	=> 0,
			image		=> 'explorer_tee.gif',
		},
		'  '	=>
		{
			clickable	=> 0,
			image		=> 'explorer_transparent.gif',
		},
		'| '	=>
		{
			clickable	=> 0,
			image		=> 'explorer_vertical.gif',
		},
	);

	sub _clickable
	{
		my($self, $icon_id) = @_;

		$_icon_data{$icon_id}{'clickable'};
	}

	sub _default_for
	{
		my($self, $attr_name) = @_;

		$_attr_data{$attr_name};
	}

	sub _image
	{
		my($self, $icon_id, $new_image)	= @_;
		my($old_image)					= '';

		if ($_icon_data{$icon_id})
		{
			$old_image						= $_icon_data{$icon_id}{'image'};
			$_icon_data{$icon_id}{'image'}	= $new_image if ($new_image);
		}

		$old_image;
	}

	sub _standard_keys
	{
		keys %_attr_data;
	}
}

# ---------------------------------------------------------------------------------

sub as_HTML
{
	my($self, $q) = @_;

	$self -> _build_result($$self{'_root'}, 1, '');

	my(@row);

	my($count)	= 0;
	my($image)	= $self -> _image('root');

	push(@row, $q -> img({src => "$$self{'_image_dir'}/$image", align => 'absmiddle'}) );

	for my $line (@{$$self{'_result'} })
	{
		$count++;
		my(@icon_id);

		my($icon_id, $id, $name)	= split(/$;/, $line);
		@icon_id = $icon_id			=~ /../g;
		my($explorer_id)			= "explorer_id_$id";
		my($s)						= '';

		for $icon_id (@icon_id)
		{
			# We need width & height because the transparent gif is 1 x 1.
			# Even worse, the root gif is 21 x 17.

			my($image)	= $self -> _image($icon_id);
			$image		= "$$self{'_image_dir'}/$image";
			$image		= ($self -> _clickable($icon_id))
							? $q -> image_button({name => $explorer_id, src => $image, align => 'absmiddle', width => 17, height => 17})
							: $q -> img({src => $image, align => 'absmiddle', width => 17, height => 17});
			$s			.= $image;
		}

		my($text)	= ($$self{'_show_id'}) ? $id : '';
		$text		= $$self{'_show_name'} ? ($text ? "$text: $name" : $name) : $text;
		$text		=	$q -> submit
				 		(
							{class => 'explorer', name => $explorer_id, value => $text}
						) if ($$self{'_click_text'});

		push(@row,	($s .
						$q -> font
						(
							{face => 'Helvetica', size => '-1'},
							$text
						)
					) );
	}

	join('', map{$_ . $q -> br()} @row);

}	# End of as_HTML.

# ---------------------------------------------------------------------------------

sub _build_result
{
	my($self, $root, $level, $prefix) = @_;

	my(@node);

	# Get the children of $root.

	for (my $i = 0; $i < Tree::Nary -> n_children($root); $i++)
	{
		push(@node, Tree::Nary -> nth_child($root, $i) );
		${$node[$#node]}{'data'}{'last'} = 0;
	}

	# Sort these children by 'name' or 'id'. If there are any, flag the last.

	if ($$self{'_sort_by'} =~ /name/i)
	{
		@node = sort{$$a{'data'}{'name'} cmp $$b{'data'}{'name'} } @node;
	}
	else
	{
		@node = sort{$$a{'data'}{'id'} <=> $$b{'data'}{'id'} } @node;
	}
	
	${$node[$#node]}{'data'}{'last'} = 1 if ($#node >= 0);

	# Process each child and its children.

	for (my $i = 0; $i <= $#node; $i++)
	{
		# 1. Determine the prefix for the current node.

		my($node)			= $node[$i];
		my($id)				= $$node{'data'}{'id'};
		my($new_icon_id)	= '';

		# If this node has children...

		if (Tree::Nary -> n_children($node) > 0)
		{
			if ($$self{'_state'}{$id}{'open'})
			{
				$new_icon_id = ($$node{'data'}{'last'} ? '-L' : '--');
			}
			else
			{
				$new_icon_id = ($$node{'data'}{'last'} ? '+L' : '+-');
			}
		}
		else
		{
			$new_icon_id = ($$node{'data'}{'last'} ? ' L' : ' -');
		}

		# This node is the 'current' node.

		$new_icon_id = '**' if ($$self{'_show_current'} && $id == $$self{'_current_id'});

		# Warning: The text pushed here is split elsewhere, to recover prefix, id & name.

		push(@{$$self{'_result'} }, "$prefix$new_icon_id$;$id$;$$node{'data'}{'name'}");

		# 2. Determine the prefix for the node's children.

		$new_icon_id = $prefix . ($$node{'data'}{'last'} ? '  ' : '| ');

		# Recurse to process this node's children.

		$self -> _build_result($node, ($level + 1), $new_icon_id) if ($$self{'_state'}{$id}{'open'});
	}

}	# End of _build_result.

# ---------------------------------------------------------------------------------

sub css
{
	my($self, $new_css)	= @_;
	$$self{'_css'}		= $new_css if ($new_css);
	$$self{'_css'}		=~ s/_css_background/$$self{'_css_background'}/;
	$$self{'_css'}		=~ s/_css_color/$$self{'_css_color'}/;

	$$self{'_css'};

}	# End of css.

# ---------------------------------------------------------------------------------

sub current_id
{
	my($self) = @_;

	$$self{'_current_id'};

}	# End of current_id.

# ---------------------------------------------------------------------------------

sub depth
{
	my($self, $id)		= @_;
	$$self{'_depth'}	= 0;

	Tree::Nary -> traverse($$self{'_root'}, $Tree::Nary::IN_ORDER, $Tree::Nary::TRAVERSE_ALL, -1, \&_depth, $id);

	$$self{'_depth'};
	
}	# End of depth.

# ---------------------------------------------------------------------------------

sub _depth
{
	my($node, $data) = @_;

	if ($$node{'data'}{'id'} == $data)
	{
		# Subtract 1 because of our fake root node.

		$$myself{'_depth'} = Tree::Nary -> depth($node) - 1;
		return $Tree::Nary::TRUE;
	}
	else
	{
		return $Tree::Nary::FALSE;
	}
	
}	# End of _depth.

# ---------------------------------------------------------------------------------

sub _found
{
	my(@bit)	= split(/\//, $File::Find::dir);
	my($prefix)	= '';

	if (! $$myself{'_dir_name'})
	{
		$$myself{'_dir_name'}	= $File::Find::dir;
		$$myself{'_dir_bit'}	= $#bit;
	}
	
	splice(@bit, 0, $$myself{'_dir_bit'});

	my($parent);

	for my $bit (@bit)
	{
		$parent	= $prefix;
		$prefix	.= "/$bit";

		next if (${$$myself{'_seen'} }{$prefix});

		$$myself{'_id'}++;

		${$$myself{'_seen'} }{$prefix}					= $$myself{'_id'};
		${$$myself{'_tree'} }{$$myself{'_id'} }			= {};
		${$$myself{'_tree'} }{$$myself{'_id'} }{'id'}	= $$myself{'_id'};
		${$$myself{'_tree'} }{$$myself{'_id'} }{'name'}	= $prefix;
		my($parent_id)									= 0;

		for my $key (keys %{$$myself{'_tree'} })
		{
			$parent_id = ${$$myself{'_tree'} }{$key}{'id'} if ($parent eq ${$$myself{'_tree'} }{$key}{'name'});
		}

		${$$myself{'_tree'} }{$$myself{'_id'} }{'parent_id'} = $parent_id;
	}

}	# End of _found.

# ---------------------------------------------------------------------------------

sub from_dir
{
	my($self, $dir_name)	= @_;
	$$self{'_id'}			= 0;
	$$self{'_seen'}			= {};
	$$self{'_tree'}			= {};

	File::Find::find(\&_found, $dir_name);

	$self -> from_hash($$self{'_tree'});

	$$self{'_id'}  	= 0;
	$$self{'_seen'}	= {};
	$$self{'_tree'}	= {};

}	# End of from_dir.

# ---------------------------------------------------------------------------------

sub from_hash
{
	my($self, $hash_ref) = @_;

	# We must loop repeatedly to ensure we have processed all nodes.
	# On any loop we skip a hash_ref if it's parent has not been done,
	# but we get it on the loop after processing its parent.
	# Start by building a hash of all keys, and delete them as they are processed.

	my(%seen)		= ();
	my(@keys)		= keys %$hash_ref;
	@seen{@keys}	= (1) x (1 + $#keys);
	my($count)		= 1;

	# Insert the base nodes.

	my($id, %inserted);

	for my $key (keys %$hash_ref)
	{
		next if ($$hash_ref{$key}{'parent_id'} != 0);

		$id								= $$hash_ref{$key}{'id'};
		$seen{$key}						= 0;
		my($node)						= Tree::Nary -> new($$hash_ref{$key});
		$inserted{$id}					= $node;
		$$self{'_state'}{$id}{'open'}	= 0;
		$$self{'_name'}{$id}			= $$node{'data'}{'name'};
		Tree::Nary -> append($$self{'_root'}, $node);
	}

	# Insert all other nodes.

	while ($count > 0)
	{
		# Have we finished?

		$count = 0;

		for my $seen (keys %seen)
		{
			$count++ if ($seen{$seen});
		}

		# Yes.

		next if ($count == 0);

		# No.

		for my $key (keys %$hash_ref)
		{
			$id = $$hash_ref{$key}{'id'};
			
			next if ($inserted{$id});
			next if (! $inserted{$$hash_ref{$key}{'parent_id'} });
	
			# This hash_ref is absent, but its parent is present. Add it to its parent.
	
			$seen{$key}						= 0;
			my($node)						= Tree::Nary -> new($$hash_ref{$key});
			$inserted{$id}					= $node;
			$$self{'_state'}{$id}{'open'}	= 0;
			$$self{'_name'}{$id}			= $$node{'data'}{'name'};
			Tree::Nary -> append($inserted{$$hash_ref{$key}{'parent_id'} }, $node);
		}
	}

	$$self{'_current_id'} = (sort @keys)[0];

}	# End of from_hash.

# ---------------------------------------------------------------------------------

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

# ---------------------------------------------------------------------------------

sub image
{
	my($self, $icon_id, $new_image) = @_;

	$self -> _image($icon_id, $new_image);

}	# End of name.

# ---------------------------------------------------------------------------------

sub name
{
	my($self) = @_;

	$$self{'_current_id'} ? $$self{'_name'}{$$self{'_current_id'} } : '';

}	# End of name.

# ---------------------------------------------------------------------------------

sub new
{
	my($caller, %arg)		= @_;
	my($caller_is_obj)		= ref($caller);
	my($class)				= $caller_is_obj || $caller;
	my($self)				= bless({}, $class);
	$myself					= $self; # Since $self is not available inside _found().
	$$self{'_current_id'}	= 0;
	$$self{'_dir_name'}		= '';
	$$self{'_dir_bit'}		= 0;
	$$self{'_name'}			= {};
	$$self{'_result'}		= [];
	$$self{'_root'}			= Tree::Nary -> new({id => 0, name => 'Root node'});
	$$self{'_state'}		= {};

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

	return $self;

}	# End of new.

# ---------------------------------------------------------------------------------

sub parent_id
{
	my($self) = @_;

	$$self{'_current_id'} ? ${$$self{'_tree'} }{$$self{'_current_id'} }{'parent_id'} : 0;

}	# End of parent_id.

# ---------------------------------------------------------------------------------

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

# ---------------------------------------------------------------------------------

sub state
{
	my($self, $q)		= @_;
	my($icon_clicked)	= '';
	
	for ($q -> param() )
	{
		($$self{'_current_id'}, $icon_clicked) = ($1, $2) if (/^explorer_id_(\d+)(.*)/);
	}							

	if ($q -> param('explorer_state') )
	{
		for my $id_open (split(/;/, $q -> param('explorer_state') ) )
		{
			my($id, $open)					= split(/=/, $id_open);
			$$self{'_state'}{$id}			= {};
			$$self{'_state'}{$id}{'open'}	= $open;
		}
	}
	
	# Toggle the 'open' status of the current id.

	$$self{'_state'}{$$self{'_current_id'} }{'open'} = 1 - $$self{'_state'}{$$self{'_current_id'} }{'open'}
		if ($$self{'_current_id'} && $icon_clicked);

	join(';', map{"$_=$$self{'_state'}{$_}{'open'}"} sort{$a <=> $b} keys %{$$self{'_state'} });

}	# End of state.

# ---------------------------------------------------------------------------------

1;

__END__

=head1 NAME

C<CGI::Explorer> - A class to manage a tree of data, for use in CGI scripts

=head1 VERSION

This document refers to version 1.12 of C<CGI::Explorer>, released 23-Mar-2001.

=head1 SYNOPSIS

This is tested code, altho the she-bang (#!) line must start in column 1:

	#!D:/Perl/Bin/Perl

	use integer;
	use strict;
	use warnings;

	use CGI;
	use CGI::Explorer;

	my($q)		= CGI -> new();
	my($tree)	= CGI::Explorer -> new();
	my($dir)	= 'D:/My Documents/HomePage';

	$tree -> from_dir($dir);
	
	my($state)	= $tree -> state($q); # Must follow from_dir() or from_hash().
	my($tree_set)	= $tree -> as_HTML($q);
	my($result_set)	= 'Id: ' . $tree -> current_id() . '. Name: ' . $tree -> name();

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

You need only change 2 lines at most, after cutting and pasting it:

=over 4

=item *

#!D:/Perl/Bin/Perl

=item *

my($dir) = 'D:/My Documents/HomePage';

=back

=head1 DESCRIPTION

C<CGI::Explorer> is a support module for CGI scripts. It manages a tree of data, so
that the script can display the tree, and the user can click on B<the icon> of a node
in the tree to open or close that node.

Opening a node reveals all children of that node, and restores their open/closed state.

Closing a node hides all children of that node.

Even when using the B<new>(click_text => 1), clicking on B<the text> of a node does
not toggle the open/closed status of a node.

=head1 Overview

C<CGI::Explorer> reconstructs its internal representation of the tree each time the script
is invoked.

Some of data comes from the script calling B<from_dir()> or
B<from_hash()>, and some of the data comes from CGI form fields returned
from the previous invocation of the script.

Specifically, the open/closed state of each node is sent on a round trip from one
invocation of the script out to the browser, and, via a 'form submit', back to the
next invocation of the script.

Also, clicking on a node on a form submits the form, and passed the id of the node
so clicked back to the second invocation of the script. When using the B<new()> option
click_text => 1, clicking on the text of the node also submits the form.

State maintenance - a complex issue - is discussed further below. See the 'state'
method.

=head1 Constructor and initialization

new(...) returns a C<CGI::Explorer> object.

This is the class's contructor.

A call to B<new()> is equivalent to:

new(click_text => 0, css => '...', image_dir => '/images', show_current => 1,
show_id => 1, show_name => 1, sort_by => 'name')

Options:

=over 4

=item *

click_text - Default is 1

Make the displayed text (id and/or name) of the node a submit button.

=item *

css - Default is <a very long string>. See source code for gory details

Provide a style-sheet for submit buttons, for use when click_text == 1.

A default style-sheet is provided. Yes, I know the submit button text,
using the style-sheet, is really too wide, but as you'll see from the source,
I cannot find a style-sheet command to make it narrower.

=item *

css_background - Default is 'white'

The background color for submit buttons.

=item *

css_color - Default is 'navy'

The foreground color for submit buttons.

=item *

image_dir - Default is '/images'

Specify the web server's directory in which the node icons are to be found.

Note: This is B<not> the operating system path of the directory, it is the path
relative to the web server's document root.

=item *

show_current - Default is 1

Show a special icon for the 'current' node.

=item *

show_id - Default is 1

Show the id of the node, to the right of the node's icon.

=item *

show_name - Default is 1

Show the name of the node, to the right of the node's icon, and to the right of the
node's id (if show_id == 1).

If show_id == 0 && show_name == 0, nothing is displayed.

=item *

sort_by - Default is 'name'

When set to 'name' (any case), sort the nodes by their names. When set to 'id', sort
them by their ids. Sorting applies to all nodes at the same depth.

=back

=head1 Icons for Nodes

C<CGI::Explorer> ships with a set of icons, with a PNG and a GIF for each icon.

The default is GIF, because more browsers support GIF transparency than support
PNG transparency.

You don't have to pay UniSys a licence for usage of the GIF compression algorithm,
because the GIFs are uncompressed :-).

The make file does not install these files automatically. You must install them
manually under the web server's document root, and then use the image_dir option
to point to the directory containing these files.

Many GIFs are from a package called MySQLTool. Unfortunately the authors of this
program have forgotten to put a download URI in their package. You may get some joy
here: http://lists.dajoba.com/m/listinfo/mysqltool.

I've renamed their files from the names used by MySQLTool.

The icons for the root node, and for the current node, are not quite satisfactory.
Let me know if you have better ones available.

If the transparent PNG does not display properly on your browser, which is likely,
update the browser, or try using the GIFs.

Almost all icons are constrained to a size of 17 x 17. The exception is the icon
for the root, which is unconstrained, so that you may use any image you wish.

Use the method B<image($icon_id, $image_name)> to change the image file name of an icon.

=head1 as_HTML($q)

Returns a string.

Converts the internal representation of the data into HTML, and returns that.

=head1 _build_result(...)

Used internally.

=head1 css([$new_css])

Returns a string of HTML containing a style-sheet for submit buttons.

Can be used to set the style-sheet, like B<set>(css => $new_css).

See ce.pl for an example.

=head1 current_id()

Returns the id of the 'current' node.

=head1 depth($id)

Returns the depth of the node whose id is given, or 0.

=head1 _depth()

Used internally.

Called by B<depth()> via Tree::Nary::traverse.

=head1 _found()

Used internally.

Called by File::Find, which means it does not receive $self as its first parameter,
which means in turn that it must use the class global $myself to access class data.

=head1 from_dir($dir_name)

Returns nothing.

Tells the object to construct its internal representation of the data by parsing
the names of all sub-directories in the given directory.

Usage:

=over 4

=item *

$tree -> from_dir('/home/rons');

=item *

$tree -> from_dir('D:\My Documents');

=item *

$tree -> from_dir('D:/My Documents');

=back

You call B<as_HTML($q)> later to retrieve a printable version of the data.

See ce.pl for an example.

=head1 from_hash($hash_ref)

Returns nothing.

Tells the object to construct its internal representation of the data by extracting
information from the given hash.

You would call B<as_HTML($q)> later to retrieve a printable version of the data.

Each key in %$hash_ref is a unique positive integer, and points to a hash ref with these
sub keys:

=over 4

=item *

id - A unique positive integer, different for each node

This is the identifier of this node. It is displayed with the constructor option
B<new>(show_id => 1), which is the default.

Yes, this is a copy of the key within $hash_ref, for use within
Tree::Nary-dependent code.

=item *

name - A string

This is the name of this node. It is displayed with the constructor option
B<new>(show_name => 1), which is the default.

=item *

parent_id - An integer

This is the identifier of the parent of this node.

The relationship between id and parent_id is what makes the data a tree.

0 means the node has no parent, ie this node is a child of a virtual root node.
By virtual, I mean each C<CGI::Explorer> object creates its own root node, so that you
do not have to.

If you do have your own root node, with id 1 (say), then your root node's parent will
still be 0, and your next-level nodes will all have a parent id of 1.

=back

See ce.pl for an example.

=head1 get($option)

Returns the current value of the given option, or undef if the option is unknown.

$tree -> get('css_background') returns 'white', by default.

=head1 image($icon_id, $new_image)

Returns the file name of the image for the given icon id.

Sets a new image file name for the given icon id.

See ce.pl for an example.

The prefixes are:

=over 4

=item *

	'root' - The root icon

=item *

	'**' - The current icon

=item *

	'-L' - An open node with no siblings below it

=item *

	'--' - An open node with siblings below it

=item *

	'+L' - A closed node with no siblings below it

=item *

	'+-' - A closed node with siblings below it

=item *

	' L' - A childless node with no siblings below it

=item *

	' -' - A childless node with siblings below it

=item *

	'&nbsp;&nbsp;' - A horizontal spacer

=item *

	'| ' - A vertical connector

=back

Note: These are indented because of a bug in pod2html: It complains about '-L' when
that string is in column 1.

=head1 name()

Returns the name of the 'current' node.

=head1 parent_id()

Returns the id of the parent of the 'current' node.

=head1 set()

Returns nothing.

Used to set a new value for any option, after a call to B<new()>.

B<set()> takes the same parameters as B<new()>.

=head1 state($q)

Returns the open/closed state of all nodes.

Tells the object to update its internal representation of the data by recovering
CGI form field data from the given CGI object.

Warning: This method can only be called after B<from_dir()> or B<from_hash()>.

Warning: You B<must> use the return value as a field, presumably hidden, in a form,
in your script so that the value can do a round trip out to the browser and back.
This way the value can be recovered by the next invocation of your script.

This is the mechanism C<CGI::Explorer> uses to maintain the open/closed state of each
node. State maintenance is a quite a complex issue. For details, see:

	Writing Apache Modules with Perl and C
	Lincoln Stein and Doug MacEachern
	O'Reilly
	1-56592-567-X
	Chapter 5 'Maintaining State'

You can see the problem: When you close and then re-open a node, you expect all child
nodes to be restored to the open/close state they were in before the node was closed.

With a program like Windows Explorer, this is simple, since the program remains in
RAM, running, all the time nodes are being clicked. Thus it can maintain the state of
each node in its own (process) memory.

With a CGI script, 2 separate invocations of the script must maintain state outside
their own memory. I have chosen to use (hidden) form fields in C<CGI::Explorer>.

See ce.pl for an example.

The form fields have these names:

=over 4

=item *

explorer_id_(\d+) - The id of the node clicked on

There is 1 such form field per node.

The click on this node, or the text of this node (when using click_text => 1), is
what submitted the form. (\d+) is a unique positive integer.

Your CGI script does not need to output these form fields. B<as_HTML($q)> does this
for you.

=item *

explorer_state - The open/closed state of all nodes. Its value is a string

Your CGI script must output this value.

See ce.pl for an example.

=back

=head1 Required Modules

=over 4

=item *

Tree::Nary. Not shipped with Perl. Get it from a CPAN near you

=back

=head1 Changes

See Changes.txt.

=head1 AUTHOR

C<CGI::Explorer> was written by Ron Savage I<E<lt>ron@savage.net.auE<gt>> in 2001.

Home page: http://savage.net.au/index.html

=head1 COPYRIGHT

Copyright &copy; 2001, Ron Savage. All rights reserved.

This program is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
