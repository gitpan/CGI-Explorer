NAME
    "CGI::Explorer" - A class to manage a tree of data, for use in CGI
    scripts

VERSION
    This document refers to version 1.12 of "CGI::Explorer", released
    23-Mar-2001.

SYNOPSIS
    This is tested code, altho the she-bang (#!) line must start in column
    1:

            #!/usr/Bin/Perl

            use strict;
            use warnings;

            use CGI;
            use CGI::Explorer;

            my($q)          = CGI -> new();
            my($tree)       = CGI::Explorer -> new();
            my($dir)        = 'D:/My Documents/HomePage';

            $tree -> from_dir($dir);

            my($state)      = $tree -> state($q); # Must follow from_dir() or from_hash().
            my($tree_set)   = $tree -> as_HTML($q);
            my($result_set) = 'Id: ' . $tree -> current_id() . '. Name: ' . $tree -> name();

            print   $q -> header(),
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

    *   #!/usr/Bin/Perl

    *   my($dir) = 'D:/My Documents/HomePage';

DESCRIPTION
    "CGI::Explorer" is a support module for CGI scripts. It manages a tree
    of data, so that the script can display the tree, and the user can click
    on the icon of a node in the tree to open or close that node.

    Opening a node reveals all children of that node, and restores their
    open/closed state.

    Closing a node hides all children of that node.

    Even when using the new(click_text => 1), clicking on the text of a node
    does not toggle the open/closed status of a node.

Overview
    "CGI::Explorer" reconstructs its internal representation of the tree
    each time the script is invoked.

    Some of data comes from the script calling from_dir() or from_hash(),
    and some of the data comes from CGI form fields returned from the
    previous invocation of the script.

    Specifically, the open/closed state of each node is sent on a round trip
    from one invocation of the script out to the browser, and, via a 'form
    submit', back to the next invocation of the script.

    Also, clicking on a node on a form submits the form, and passed the id
    of the node so clicked back to the second invocation of the script. When
    using the new() option click_text => 1, clicking on the text of the node
    also submits the form.

    State maintenance - a complex issue - is discussed further below. See
    the 'state' method.

Constructor and initialization
    new(...) returns a "CGI::Explorer" object.

    This is the class's contructor.

    A call to new() is equivalent to:

    new(click_text => 0, css => '...', image_dir => '/images', show_current
    => 1, show_id => 1, show_name => 1, sort_by => 'name')

    Options:

    *   click_text - Default is 1

        Make the displayed text (id and/or name) of the node a submit
        button.

    *   css - Default is <a very long string>. See source code for gory
        details

        Provide a style-sheet for submit buttons, for use when click_text ==
        1.

        A default style-sheet is provided. Yes, I know the submit button
        text, using the style-sheet, is really too wide, but as you'll see
        from the source, I cannot find a style-sheet command to make it
        narrower.

    *   css_background - Default is 'white'

        The background color for submit buttons.

    *   css_color - Default is 'navy'

        The foreground color for submit buttons.

    *   image_dir - Default is '/images'

        Specify the web server's directory in which the node icons are to be
        found.

        Note: This is not the operating system path of the directory, it is
        the path relative to the web server's document root.

    *   show_current - Default is 1

        Show a special icon for the 'current' node.

    *   show_id - Default is 1

        Show the id of the node, to the right of the node's icon.

    *   show_name - Default is 1

        Show the name of the node, to the right of the node's icon, and to
        the right of the node's id (if show_id == 1).

        If show_id == 0 && show_name == 0, nothing is displayed.

    *   sort_by - Default is 'name'

        When set to 'name' (any case), sort the nodes by their names. When
        set to 'id', sort them by their ids. Sorting applies to all nodes at
        the same depth.

Icons for Nodes
    "CGI::Explorer" ships with a set of icons, with a PNG and a GIF for each
    icon.

    The default is GIF, because more browsers support GIF transparency than
    support PNG transparency.

    You don't have to pay UniSys a licence for usage of the GIF compression
    algorithm, because the GIFs are uncompressed :-).

    The make file does not install these files automatically. You must
    install them manually under the web server's document root, and then use
    the image_dir option to point to the directory containing these files.

    Many GIFs are from a package called MySQLTool. Unfortunately the authors
    of this program have forgotten to put a download URI in their package.
    You may get some joy here: http://lists.dajoba.com/m/listinfo/mysqltool.

    I've renamed their files from the names used by MySQLTool.

    The icons for the root node, and for the current node, are not quite
    satisfactory. Let me know if you have better ones available.

    If the transparent PNG does not display properly on your browser, which
    is likely, update the browser, or try using the GIFs.

    Almost all icons are constrained to a size of 17 x 17. The exception is
    the icon for the root, which is unconstrained, so that you may use any
    image you wish.

    Use the method image($icon_id, $image_name) to change the image file
    name of an icon.

as_HTML($q)
    Returns a string.

    Converts the internal representation of the data into HTML, and returns
    that.

_build_result(...)
    Used internally.

css([$new_css])
    Returns a string of HTML containing a style-sheet for submit buttons.

    Can be used to set the style-sheet, like set(css => $new_css).

    See ce.pl for an example.

current_id()
    Returns the id of the 'current' node.

depth($id)
    Returns the depth of the node whose id is given, or 0.

_depth()
    Used internally.

    Called by depth() via Tree::Nary::traverse.

_found()
    Used internally.

    Called by File::Find, which means it does not receive $self as its first
    parameter, which means in turn that it must use the class global $myself
    to access class data.

from_dir($dir_name)
    Returns nothing.

    Tells the object to construct its internal representation of the data by
    parsing the names of all sub-directories in the given directory.

    Usage:

    *   $tree -> from_dir('/home/rons');

    *   $tree -> from_dir('D:\My Documents');

    *   $tree -> from_dir('D:/My Documents');

    You call as_HTML($q) later to retrieve a printable version of the data.

    See ce.pl for an example.

from_hash($hash_ref)
    Returns nothing.

    Tells the object to construct its internal representation of the data by
    extracting information from the given hash.

    You would call as_HTML($q) later to retrieve a printable version of the
    data.

    Each key in %$hash_ref is a unique positive integer, and points to a
    hash ref with these sub keys:

    *   id - A unique positive integer, different for each node

        This is the identifier of this node. It is displayed with the
        constructor option new(show_id => 1), which is the default.

        Yes, this is a copy of the key within $hash_ref, for use within
        Tree::Nary-dependent code.

    *   name - A string

        This is the name of this node. It is displayed with the constructor
        option new(show_name => 1), which is the default.

    *   parent_id - An integer

        This is the identifier of the parent of this node.

        The relationship between id and parent_id is what makes the data a
        tree.

        0 means the node has no parent, ie this node is a child of a virtual
        root node. By virtual, I mean each "CGI::Explorer" object creates
        its own root node, so that you do not have to.

        If you do have your own root node, with id 1 (say), then your root
        node's parent will still be 0, and your next-level nodes will all
        have a parent id of 1.

    See ce.pl for an example.

get($option)
    Returns the current value of the given option, or undef if the option is
    unknown.

    $tree -> get('css_background') returns 'white', by default.

image($icon_id, $new_image)
    Returns the file name of the image for the given icon id.

    Sets a new image file name for the given icon id.

    See ce.pl for an example.

    The prefixes are:

    *
                'root' - The root icon

    *
                '**' - The current icon

    *
                '-L' - An open node with no siblings below it

    *
                '--' - An open node with siblings below it

    *
                '+L' - A closed node with no siblings below it

    *
                '+-' - A closed node with siblings below it

    *
                ' L' - A childless node with no siblings below it

    *
                ' -' - A childless node with siblings below it

    *
                '&nbsp;&nbsp;' - A horizontal spacer

    *
                '| ' - A vertical connector

    Note: These are indented because of a bug in pod2html: It complains
    about '-L' when that string is in column 1.

name()
    Returns the name of the 'current' node.

parent_id()
    Returns the id of the parent of the 'current' node.

set()
    Returns nothing.

    Used to set a new value for any option, after a call to new().

    set() takes the same parameters as new().

state($q)
    Returns the open/closed state of all nodes.

    Tells the object to update its internal representation of the data by
    recovering CGI form field data from the given CGI object.

    Warning: This method can only be called after from_dir() or from_hash().

    Warning: You must use the return value as a field, presumably hidden, in
    a form, in your script so that the value can do a round trip out to the
    browser and back. This way the value can be recovered by the next
    invocation of your script.

    This is the mechanism "CGI::Explorer" uses to maintain the open/closed
    state of each node. State maintenance is a quite a complex issue. For
    details, see:

            Writing Apache Modules with Perl and C
            Lincoln Stein and Doug MacEachern
            O'Reilly
            1-56592-567-X
            Chapter 5 'Maintaining State'

    You can see the problem: When you close and then re-open a node, you
    expect all child nodes to be restored to the open/close state they were
    in before the node was closed.

    With a program like Windows Explorer, this is simple, since the program
    remains in RAM, running, all the time nodes are being clicked. Thus it
    can maintain the state of each node in its own (process) memory.

    With a CGI script, 2 separate invocations of the script must maintain
    state outside their own memory. I have chosen to use (hidden) form
    fields in "CGI::Explorer".

    See ce.pl for an example.

    The form fields have these names:

    *   explorer_id_(\d+) - The id of the node clicked on

        There is 1 such form field per node.

        The click on this node, or the text of this node (when using
        click_text => 1), is what submitted the form. (\d+) is a unique
        positive integer.

        Your CGI script does not need to output these form fields.
        as_HTML($q) does this for you.

    *   explorer_state - The open/closed state of all nodes. Its value is a
        string

        Your CGI script must output this value.

        See ce.pl for an example.

Required Modules
    *   Tree::Nary. Not shipped with Perl. Get it from a CPAN near you

Changes
    See Changes.txt.

AUTHOR
    "CGI::Explorer" was written by Ron Savage *<ron@savage.net.au>* in 2001.

    Home page: http://savage.net.au/index.html

COPYRIGHT
    Austrlian copyright (c) 2001, Ron Savage. All rights reserved.

            All Programs of mine are 'OSI Certified Open Source Software';
            you can redistribute them and/or modify them under the terms of
            The Artistic License, a copy of which is available at:
            http://www.opensource.org/licenses/index.html

