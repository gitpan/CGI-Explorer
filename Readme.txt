NAME
====
CGI::Explorer - A class to manage a tree of data, for use in CGI scripts

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

new(click_text => 0, css => '...', image_dir => '/images', show_current => 1,
show_id => 1, show_name => 1, sort_by => 'name')

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
