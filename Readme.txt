NAME
====
CGI::Explorer - A class to manage a tree of data, for use in CGI scripts

VERSION
=======
This document refers to version 1.00 of CGI::Explorer, released 24-02-2001.

SYNOPSIS
========
See the POD in Explorer.pm, or see ce.pl.

DESCRIPTION
===========
CGI::Explorer is a support module for CGI scripts. It manages a tree of data, so
that the script can display the tree, and the user can click on a node in the tree
to open or close that node.

Opening a node reveals all children of that node, and restores their open/close state.

Closing a node hides all children of that node.

Overview
========
CGI::Explorer reconstructs its internal representation of the tree each time the script
is invoked.

Some of data comes from the script calling $tree -> from_directory(...) or
$tree -> from_hash(...), and some of the data comes from CGI form fields returned
from the previous invocation of the script.

Specifically, the open/closed state of each node is sent on a round trip from one
invocation of the script out to the browser, and, via a 'form submit', back to the
next invocation of the script.

Also, clicking on a node on a form submits the form, and passed the id of the node
so clicked back to the second invocation of the script.

State maintenance - a complex issue - is discussed further below. See the 'state'
method.

Constructor and initialization
==============================
new(...) returns a CGI::Explorer object.

This is the class's contructor.

A call to new() is equivalent to:

new(a_href => 0, image_dir => '/images', show_current => 1, show_id => 1, show_name => 1)

Icons for Nodes
===============
CGI::Explorer ships with a set of icons, with a PNG and a GIF for each icon.

The default is GIF, because more browsers support GIF transparency than support
PNG transparency.

You don't have to pay UniSys a licence for usage of the GIF compression algorithm,
because the GIFs are uncompressed :-).

The make file does not install these files automatically. You must install them
manually under the web server's document root, and then use the image_dir option
to point to the directory containing these files.

Methods
=======
as_HTML($q)
-----------
Returns a string.

Converts the internal representation of the data into HTML, and returns that.

current_id()
------------
Returns the id of the 'current' node.

from_dir($dir_name)
-------------------
Returns nothing.

Tells the object to construct its internal representation of the data by parsing
the names of all sub-directories in the given directory.

You call as_HTML($q) later to retrieve a printable version of the data.

See ce.pl for an example.

from_hash($hash_ref)
--------------------
Returns nothing.

Tells the object to construct its internal representation of the data by extracting
information from the given hash.

You would call as_HTML($q) later to retrieve a printable version of the data.

See ce.pl for an example.

name()
------
Returns the name of the 'current' node.

parent_id()
-----------
Returns the id of the parent of the 'current' node.

set()
-----
Returns nothing.

Used to set a new value for any option, after a call to new().

set() takes the same parameters as new().

state($q)
---------
Returns the open/closed state of all nodes.

Tells the object to update its internal representation of the data by recovering
CGI form field data from the given CGI object.

Warning: You must use the return value as a field, presumably hidden, in a form,
in your script so that the value can do a round trip out to the browser and back.
This way the value can be recovered by the next invocation of your script.

This is the mechanism CGI::Explorer uses to maintain the open/closed state of each
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

Required Modules
================

Tree::Nary. Not shipped with Perl. Get it from a CPAN near you

AUTHOR
======
CGI::Explorer was written by Ron Savage <ron@savage.net.au> in 2001.

Home page: http://savage.net.au/index.html

COPYRIGHT
=========
Copyright (c) 2001, Ron Savage. All rights reserved.

This program is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.
