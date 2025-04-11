# $Id: MakeParDoc.tcl,v 1.3 2007/07/24 16:45:10 letay Exp $
set DEBUG 1
set CWD [pwd]
set CWD [file dirname $CWD]
set CWD [file dirname $CWD]
set CWD [file dirname $CWD]
set CWD [file dirname $CWD]

source $CWD../lib/helper.tcl
#- get local par directory
set parDir [lindex $argv 0]
#- get global par directory
set pardb [getPardb]
dbputs "parDir: $parDir pardb: $pardb"

# Reading reference file
if {[file exists "References.tcl"]} {
  set fileRef "References.tcl"
} elseif {[file exists [file join $parDir "References.tcl"]]} {
  set fileRef [file join $parDir "References.tcl"]
} else {
	set fileRef ""
}
if {[file exists $fileRef]} {
	puts "reading references from \"$fileRef\" ..."
	source $fileRef
}

# cd to par library
if {[file isdirectory "$parDir"]} {
  cd $parDir
} else {
  puts stderr "Local parameter db \"$parDir\" not found."
	exit 1
}
# Defining Fields
set FIELDS [list MODEL EXPRESSION {CALCULATED PARAMETER} VALIDITY REFERENCE NOTES]

#----------------------------------------------------------------------#
# Top Level
#----------------------------------------------------------------------#
# Creating Top Level Index:
puts "\nOpening: index.html"
set FIDtop [open  "index.html" w]
puts $FIDtop "<html><head><title>MatPar Documentation Top Level</title></head><body>"
puts $FIDtop "<h1>Material Parameter Database Documentation</h1>"

# Getting the list of local materials:
set Materials [glob -nocomplain -types d "*"]

set DEBUG 0
dbputs "Materials after glob: $Materials" 1
set DEBUG 0
#- sort files and remove cvs directories
set Materials [lsort -dictionary [lsearch -all -not -inline -regexp $Materials {[Cc][Vv][Ss]|[Mm][pP][rR][Pp][lL][oO][tT][tT][eE][rT]}]]
if {[llength $Materials] > 0} {
	puts "Found the materials: $Materials"
	puts $FIDtop "<h2>List of materials in database</h2>"
	puts $FIDtop "<ul>"
	foreach Mat $Materials {
		puts "Entry:   $Mat"
		puts $FIDtop "<li><a href=\"${Mat}/index.html\">$Mat</a></li>" 
	}
	puts $FIDtop "</ul>"
}

if 0 {
# append additional material parameter files which are not in directory structure, just for editing purpose
set files [glob -nocomplain "*.tcl"]
#- sort files 
set files [lsort -dictionary $files]
if {[llength $files] > 0} {
	puts $FIDtop "<h2>Additional local tcl-material files</h2>"
	puts $FIDtop "<ul>"
	foreach f $files {
		puts $FIDtop "<li><a href=$f>$f</a>"
	}
	puts $FIDtop "</ul>"
}

# append additional material parameter files which are not in directory structure, just for editing purpose
set files [glob -nocomplain  "*.par"]
#- sort files 
set files [lsort -dictionary $files]
if {[llength $files] > 0} {
	puts $FIDtop "<h2>Additional local par-material files</h2>"
	puts $FIDtop "<ul>"
	foreach f $files {
		puts $FIDtop "<li><a href=$f>$f</a>"
	}
	puts $FIDtop "</ul>"
}

# append a link to the global parameter index file
if {$pardb!=""&&$pardb!=$parDir} {
	puts $FIDtop "<h2><a href=\"[file join  "file://" $pardb "index.html"]\">Global Material Database</a></h2>"
}
} ;# end of block comment

#- close top file
puts $FIDtop "</body></html>"
puts "Closing: index.html"
close $FIDtop

#----------------------------------------------------------------------#
# Material Level
#----------------------------------------------------------------------#
foreach Mat $Materials {
	
	# Getting the list of property groups:
	set PropertyGroup [glob -nocomplain -types d [file join $Mat "*"]]
	set PropertyGroup [lsort -dictionary [lsearch -all -not -inline -regexp $PropertyGroup {[Cc][Vv][Ss]}]]
	puts "\nMakeParDoc: For $Mat found the property groups $PropertyGroup"

	# Creating Material Level Index:
	puts "\nOpening: ${Mat}/index.html"
	set FIDmat [open ${Mat}/index.html w]
	puts $FIDmat "<html><head><title>MatPar Documentation $Mat</title></head>"
	puts $FIDmat "<body>"
	puts $FIDmat "<a name=\"top\" href=\"../index.html\">\[up\]</a>"
	puts $FIDmat "<h1>Material Parameter Database Documentation for $Mat</h1>"
	puts $FIDmat "<h2>List of Property Groups</h2>"
	puts $FIDmat "<ul>"
	foreach Group $PropertyGroup {
		set GroupName [file tail $Group] 
		puts "Entry:   $Group"
		puts $FIDmat "<li><a href=\"${GroupName}/index.html\">$GroupName</a></li>" 
	}
	puts $FIDmat "</ul></body></html>"
	puts "Closing: ${Mat}/index.html"
	close $FIDmat
	
	
	#--------------------------------------------------------------------#
	# ParameterSection Level
	#--------------------------------------------------------------------#
	foreach Group $PropertyGroup {
	
		# Getting the list of models:
		set Models [glob -nocomplain -types d [file join $Group "*"]]
		set Models [lsort -dictionary [lsearch -all -not -inline -regexp $Models {[Cc][Vv][Ss]}]]
		puts "\nMakeParDoc: For $Group found the models $Models"

		# Creating Property Group Level Index:
		puts "\nOpening: ${Group}/index.html"
		set FIDgroup [open ${Group}/index.html w]
		puts $FIDgroup "<html><head><title>MatPar Documentation $Group</title></head>"
		puts $FIDgroup "<body>"
		puts $FIDgroup "<a name=\"top\" href=\"../index.html\">\[up\]</a>"
		puts $FIDgroup "<h1>Material Parameter Database Documentation for $Group</h1>"
		puts $FIDgroup "<h2>List of Parameter Sections</h2>"
		puts $FIDgroup "<ul>"
		foreach Mod $Models {
			set ModName [file tail $Mod] 
			puts "Entry:   $Mod"
			puts $FIDgroup "<li><a href=\"${ModName}/index.html\">$ModName</a></li>" 
		}
		puts $FIDgroup "</ul></body></html>"
		puts "Closing: ${Group}/index.html"
		close $FIDgroup
		#----------------------------------------------------------------------#	
		# Model Level
		#----------------------------------------------------------------------#
		# Creating ModelVar Level Index:
		foreach Mod $Models {
		
			# Getting the list of models:
			set ModelVariants [glob -nocomplain [file join $Mod "*.tcl"]]
			puts "\nMakeParDoc: For $Mod found the model variants $ModelVariants"
		
			# Reading the ModelVar files into array DATA:
			foreach ModVar $ModelVariants {
				puts "Reading: $ModVar"
				set FID [open "$ModVar" r]
				set res {}
				set varname ""
				set vardata ""
				foreach f $FIELDS {set DATA($ModVar,$f) ""} 
				set DATA($ModVar,TITLE) ""
				while {[gets $FID line] >= 0} {
					if {[regexp {^\#!} $line]} {
						#puts "line: $line"
						if {[regexp {^\#![ ]*([A-Z0-9_ ]+):[ ]*(.*)} $line junk reg]} {
							set reg [string trim $reg]
							#puts "varline reg: $reg"
							if {$reg != $varname&&$varname!=""} {
								set DATA($ModVar,$varname) $vardata
								#puts "--save: $varname: $vardata"
							}
							set varname $reg
							regexp {^\#![ ]*[A-Z0-9_ ]+:(.*)} $line junk vardata
						} elseif {[regexp {^\#!(.+)} $line junk reg]} {
							#puts "--append: $reg"
							set vardata "[string trim $vardata]\n[string trim $reg]"
						} 
					}
				}
				set DATA($ModVar,$varname) [string trim $vardata]
				#puts "--save: $varname: $vardata"
				close $FID
			}
		
			# writing header
			puts "\nOpening: ${Mod}/index.html"
			set FIDmod [open ${Mod}/index.html w]
			puts $FIDmod "<html><head><title>MatPar Documentation $Mod</title></head>"
			puts $FIDmod "<body>"
			puts $FIDmod "<a name=\"top\" href=\"../index.html\">\[up\]</a>"
			puts $FIDmod "<h1>Material Parameter Database Documentation for $Mod</h1>"
			puts $FIDmod "<h2>List of Models</h2>"

			# content table
			puts "writing content"
			puts $FIDmod "<ul>"
			foreach ModVar $ModelVariants {
				set fname [file tail $ModVar]
				if {[string length $DATA($ModVar,MODEL)] > 0} {
					set name $DATA($ModVar,MODEL)
				} elseif {[string length $DATA($ModVar,TITLE)] > 0} {
					set name $DATA($ModVar,TITLE)
				}
				puts $FIDmod "  <li> <a href=\"\#$ModVar\">$DATA($ModVar,MODEL) ($fname)</a>"
			}
			puts $FIDmod "</ul>"

			#writing the models
			foreach ModVar $ModelVariants {
				#puts "DATA:"
				#foreach f [array get DATA "$ModVar,*"] {puts $f}
				# add all fields from $ModVar in the order of FIELDS
				set fieldlist $FIELDS 
				# append all additional fields
				#foreach f [array names DATA "$ModVar,*"] {
				#		regsub "$ModVar," $f "" f
				#		if {[lsearch $FIELDS $f] < 0} {
				#				lappend fieldlist $f
				#		}
				#}
				puts "fields: $fieldlist"
				regsub -all "$ModVar," $fieldlist "" fieldlist
				puts "writing $ModVar fields: $fieldlist"
				foreach FIELD $fieldlist {
					if { $FIELD == "MODEL"} {
					
						if {[string length $DATA($ModVar,MODEL)] > 0} {
							set name $DATA($ModVar,MODEL)
						} elseif {[string length $DATA($ModVar,TITLE)] > 0} {
							set name $DATA($ModVar,TITLE)
						} else {
							set name "<b><font color=red>Missing MODEL or TITLE field in par-file!</font></b>"
						}
						puts $FIDmod "<hr><p><a name=\"$ModVar\" href=\"\#top\">\[top\]</a><b>$name</b>"
						puts $FIDmod "<p><b>FILE:</b> <tt><a href=\"[file tail $ModVar]\">[file tail $ModVar]<a></tt>"
					} elseif { $FIELD == "EXPRESSION"&&[string length $DATA($ModVar,$FIELD)] > 0} {
						puts $FIDmod "<br><b>$FIELD:</b>"
						puts $FIDmod "<PRE>"
						puts $FIDmod "$DATA($ModVar,$FIELD)"
						puts $FIDmod "</PRE>"
					} elseif { $FIELD == "REFERENCE"&&[string length $DATA($ModVar,$FIELD)] > 0} {
						if { [string first "\$" $DATA($ModVar,$FIELD)] > -1 } {
							set TMP [eval $DATA($ModVar,$FIELD)]
							puts $FIDmod "<br><b>$FIELD:</b><br> $TMP"
						} else {
							puts $FIDmod "<br><b>$FIELD:</b><br> $DATA($ModVar,$FIELD)"
						}
					} elseif {[string length $DATA($ModVar,$FIELD)] > 0} {
						puts $FIDmod "<br><b>$FIELD:</b> $DATA($ModVar,$FIELD)"
					}
				}
			}
		}
		puts $FIDmod "</body></html>"
		puts "Closing: ${Mod}/index.html"
		close $FIDmod
	}
}
