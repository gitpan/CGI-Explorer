use ExtUtils::MakeMaker;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

print "\n";
print "After installation of CGI::Explorer, you must copy the /images \n";
print "directory from the distribution to your web server's document root. \n";
print "Then copy ce.pl to your cgi-bin directory, and make it executable. \n";
print "\n";

WriteMakefile
(
	clean				=>
	{
		FILES			=> 'blib/* Makefile MANIFEST CGI-Explorer-*'
	},
	dist				=>
	{
		COMPRESS		=> 'gzip',
		SUFFIX			=> 'gz'
	},
	ABSTRACT			=> 'A CGI support module for tree management and display',
	AUTHOR				=> 'Ron Savage',
	DISTNAME			=> 'CGI-Explorer',
	NAME				=> 'CGI::Explorer',
	PREREQ_PM			=> {'Tree::Nary' => 1.0},
	VERSION_FROM		=> 'Explorer.pm',
);
