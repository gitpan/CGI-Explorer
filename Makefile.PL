use ExtUtils::MakeMaker;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

print "\n";
print "After installation of CGI::Explorer, you must copy the 3 directories \n";
print "css/, images/ and js/ from the distro to your web server's doc root. \n";
print "\n";

WriteMakefile
(
	($] ge '5.005') ?
	(
		'AUTHOR' => 'Ron Savage (ron@savage.net.au)',
		'ABSTRACT' => 'A CGI support module for tree management and display',
    ) : (),
	clean				=>
	{
		FILES			=> 'blib/* Makefile MANIFEST CGI-Explorer-*'
	},
	dist				=>
	{
		COMPRESS		=> 'gzip',
		SUFFIX			=> 'gz'
	},
	DISTNAME			=> 'CGI-Explorer',
	NAME				=> 'CGI::Explorer',
	PREREQ_PM			=> {},
	VERSION_FROM		=> 'Explorer.pm',
);
