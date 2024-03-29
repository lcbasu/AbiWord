#!/usr/bin/perl -w 

#
#  The XML UI Translation Extractor
#
#  Copyright (C) 2000 Free Software Foundation.
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU General Public License as
#  published by the Free Software Foundation; either version 2 of the
#  License, or (at your option) any later version.
#
#  This script is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this library; if not, write to the Free Software
#  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
#  Authors: Kenneth Christiansen <kenneth@gnu.org>
#
#  Contributors: Ingo Brueckl <ib@wupperonline.de>



use strict;
use File::Basename;
use Getopt::Long;

#---------------------------

my $VERSION     = "0.9a";

#---------------------------

my $LOCAL_ARG	= "0";
my $HELP_ARG 	= "0";
my $VERSION_ARG = "0";
my $UPDATE_ARG  = "0";

#---------------------------

my $FILE;
my $OUTFILE;

#---------------------------

my %string = ();
my @elements;
my @items;
my $n;

#---------------------------

$| = 1;

GetOptions (
	    "local|l"    => \$LOCAL_ARG,
	    "help|h|?"   => \$HELP_ARG,
	    "version|v"  => \$VERSION_ARG,
	    "update"     => \$UPDATE_ARG,
	    ) or &Error;

&SplitOnArgument;


#---------------------------------------------------
# Check for options. 
# This section will check for the different options.
#---------------------------------------------------

sub SplitOnArgument {

    if ($VERSION_ARG) {
	&Version;

    } elsif ($HELP_ARG) {
	&Help;
   
    } elsif ($LOCAL_ARG) {
        &PlaceLocal;
        &Preparation;
        &WriteFile;

    } elsif ($UPDATE_ARG) {
	&PlaceNormal;
        &Preparation;
	&WriteFile;

    } elsif (@ARGV > 0) {
	&PlaceNormal;
	&Message;
	&Preparation;
	&WriteFile;

    } else {
	&Help;

    }  
}    

sub PlaceNormal {
    $FILE	 = $ARGV[0];
    $OUTFILE     = "$FILE.h";
}   

sub PlaceLocal {
    $FILE	 = $ARGV[0];
    $OUTFILE     = fileparse($FILE, ());
    if (!-e "tmp/") {
    system("mkdir tmp/");
    }
    $OUTFILE     = "./tmp/$OUTFILE.h"
}


#-------------------
sub Version{
    print "The XML UI Translations Extractor $VERSION\n";
    print "Written by Kenneth Christiansen, 2000.\n\n";
    print "Copyright (C) 2000 Free Software Foundation, Inc.\n";
    print "This is free software; see the source for copying conditions.  There is NO\n";
    print "warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.\n";
    exit;
}

#-------------------  
sub Help{
    print "Usage: ui-extract.pl [FILENAME] [OPTIONS] ...\n";
    print "Generates a headerfile from an xml source.\n\nGreps all strings ";
    print "between <_translatable_node> and its end tag,\nwhere tag are all allowed ";
    print "xml tags. Read the docs for more info.\n\n"; 
    print "  -V, --version                shows the version\n";
    print "  -H, --help                   shows this help page\n";
    print "\nReport bugs to <kenneth\@gnu.org>.\n";
    exit;
}

#------------------- 
sub Error{
#   print "ui-extract: invalid option @ARGV\n";
    print "Try `ui-extract.pl --help' for more information.\n";
    exit;
}

sub Message {
    print "Generating headerfile for translation.\n";
}

sub Preparation {

   if (-s "$OUTFILE"){
	unlink "$OUTFILE";
   }

   &Convert ($FILE);
}

sub WriteFile {

    open OUT, ">>$OUTFILE";
    &addMessages;
    close OUT;

    print  "Wrote $OUTFILE\n";
}

#-------------------
sub Convert($) {

    #-----------------
    # Reading the file
    #-----------------
    my $input; {
	local (*IN);
	local $/; #slurp mode
	open (IN, "<$FILE") || die "can't open $FILE: $!";
	$input = <IN>;
    }
 
    if (!-s "$OUTFILE"){
    	open OUT, ">$OUTFILE";

	print OUT "/*\n";
        print OUT " * Translatable strings file generated by extract-ui.\n";
        print OUT " * DO NOT compile this file as part of your application.\n";
        print OUT " */\n\n"; 
			
        }   
       	close OUT;

	### For generic translatable XML files ###
 
        if ($FILE =~ /xml$/sg){
        while ($input =~ /[\t\n\s]_[a-zA-Z0-9_]+=\"([^\"]+)\"/sg) {
	   	$string{$1} = [];
        }

	while ($input =~ /<_[a-zA-Z0-9_]+>(..[^_]*)<\/_[a-zA-Z0-9_]+>/sg) {
		$string{$1} = [];
 	}}

        ### For translatable Glade XML files ###

        if ($FILE =~ /glade$/sg){
        my $translate = "label|title|text|format|copyright|comments|
                         preview_text|tooltip";

        while ($input =~ /<($translate)>(..[^<]*)<\/($translate)>/sg) {

	    # Glade has some bugs, especially it uses translations tags to contain little
	    # non-translatable content. We work around this, by not including these
            # strings that only includes something like: label4, and window1
            if ($2 =~ /^(window|label)[0-9]$/g) {
            } else {
                $string{$2} = [];
            }
        }
        
        while ($input =~ /<items>(..[^<]*)<\/items>/sg) {
              @items =  split (/\n/, $1);
              for ($n = 0; $n < @items; $n++) {
                  $string{$items[$n]} = [];
              }
        }}

        ### For generic translatable XP header files ###
        
        if ($FILE =~ /\/xp\/(.*)\.h$/sg){
        while ($input =~ /\((\w+),(\s*)\"(.*)\"[)\s]+(\/\/xgettext:.*)*/g) {
               my $tag = $1;
		if (defined($4)) { $tag .= " */ /* " . substr($4, 2); }
		if (defined($string{$3})) {
			push @{$string{$3}}, $tag;
		} else {
			$string{$3} = [$tag];
		}
        }}

    }

sub addMessages{

    foreach my $theMessage (sort keys %string) {
	my (@tag) = @{ $string{$theMessage} };

    # Replace XML codes for special chars to
    # geniune gettext syntax
    #---------------------------------------
    $theMessage =~ s/&quot;/\\"/mg;
    $theMessage =~ s/&lt;/</mg;
    $theMessage =~ s/&gt;/>/mg;

    if ($theMessage =~ /\n/) {

        @elements =  split (/\n/, $theMessage);
        for ($n = 0; $n < @elements; $n++) {

           if ($n == 0) {
	       print OUT "gchar *s = N_"; 
               print OUT "(\"$elements[$n]\\n\"\n";
           }

           elsif ($n == @elements - 1) { 
	       print OUT "              ";
               print OUT "\"$elements[$n]\");\n";
           }

           elsif ($n > 0)  { 	
	       print OUT "             ";
               print OUT "(\"$elements[$n]\\n\");\n";
           }
        }

	} else {

	    for my $value (@tag) {
			if ($value) { print OUT "/* $value */\n"; }		
	    }
		print OUT "gchar *s = N_(\"$theMessage\");\n";

	}
	    
    }
}

