# $Id: helper.tcl,v 1.20 2007/11/30 09:24:03 letay Exp $
#set DEBUG 10
proc initProperty { material property args  } {
    set length_args [llength $args]
    if { $length_args == 1 } {
        set model $args
        set file [getParfileWithPath "$material/$property/$model.tcl"]
    } elseif { $length_args == 2 } {
        set parSection [lindex $args 0]
        set model [lindex $args 1]
        set file [getParfileWithPath "$material/$property/$parSection/$model.tcl"]
    } else {
        puts stderr "Error: Wrong number of arguments were passed to initProperty."
            puts stderr "       Number of arguments should be 3 or 4"
        exit 1
    }
	set ::pardb [getPardb]
	if {$file == ""} {
        if { $length_args == 1 } {
            puts stderr "Error: file \"$material/$property/$model.tcl\" not found."
        } elseif { $length_args == 2 } {
            puts stderr "Error: file \"$material/$property/$parSection/$model.tcl\" not found."
        }
        puts stderr "       neither in local pardb \"par\" "
		puts stderr "       nor in global pardb \"$::pardb\"."
        exit 1
    }
	# if file found and but no pardb found then the parameterset has to be in 
	# the local par directory set pardb accordingly.
	if {$::pardb==""} {
		set ::pardb "./par"
	}
	dbputs "pardb: \"$::pardb\" file: \"$file\"" 10
    source $file
}

proc ::readTable {file tableType} {
    set FID [open $file r]
    set i 0
    if {$tableType == "TableODB"} {
	set llist [list]
	set nlist [list]
	set klist [list]
	while {[gets $FID line] >= 0} {
	    if {[scan $line "%e,%e,%e" l n k] == 3 } {
		lappend llist $l
		lappend nlist $n
		lappend klist $k
		incr i
	    }
	}
	set lnklist [list $llist $nlist $klist]
	return $lnklist
    } elseif {$tableType == "TableBGN"} {
	set Nlist [list]
	set deltaEglist [list]
	while {[gets $FID line] >= 0} {
	    if {[scan $line "%e,%e" N deltaEg] == 2 } {
		lappend Nlist $N
		lappend deltaEglist $deltaEg
		incr i
	    }
	}
	set NdeltaEglist [list $Nlist $deltaEglist]
	return $NdeltaEglist
    }
    close $FID
}

# evaluates str which should give a variable name and then returns 
# the value of this variable
proc evalVar {str} {
    if {![string match "*\$*" "$str"]} {
	set str "\"\$$str\""
    }
    set cmdline "set res $str"
    set res ""
    dbputs "cmdline: $cmdline" 10
    if {[catch "eval $cmdline"]} {
	puts stderr "error in evalVar: \"$cmdline\" is not a variable"
    }
    return $res
}

proc evalVar2 {str} {
  set cmdline "set res $str"
  eval $cmdline
    return $res
}

# reverse order of a list
proc lreverse {lst} {
				set l [llength $lst]
				set pos [expr $l - 1]
				set revlst [list]
				while {$pos>=0} {
						lappend revlst [lindex $lst $pos]
						incr pos -1
				}
				return $revlst
		}

# dbputs "debug text" dbglevel
# puts text if global variable DEBUG > dbglevel
proc ::dbputs {str {dbglevel 1}} {
  global DEBUG
  if {![info exists DEBUG]} {set DEBUG 0}
 	#-if { [ catch { set caller "db0: [info level 0] db-1: [info level -1]"}]} {set caller "main"}
 	if { [ catch { set caller [lindex [info level -1] 0]}]} {set caller "main"}
	if {$DEBUG==1&&$DEBUG>=$dbglevel} {
		puts "DEBUG>$str"
	} elseif {$DEBUG>=$dbglevel} {
		puts "DEBUG>$caller>$str"
	}
}
    
# returns an array containing all parameters for a given node
proc getparams {node projdir} {
  array set r {}
  #if projdir is not specified try to find gtree.dat
  if {[string length [string trim $projdir]] == 0} {
    if {[file exists [file join [pwd] "gtree.dat"]]} {
      set projdir [pwd]
     } elseif {[file exists [file join [pwd] ".." "gtree.dat"]]} {
      set projdir [file join [pwd] ".."]
     }
  }
  # if gtree.dat does not exists, return empty list.
  #Gavin update: changed [pwd] to $projdir
  if {![file exists [file join $projdir "gtree.dat"]]} {return [array get r]}

  dbputs "projdir: $projdir" 10
  dbputs "gtree::TreePathname: [::gtree::TreePathname]" 10
  if {[string length [::gtree::TreePathname]] > 0} {
    dbputs "gtree::SetCurrent: [::gtree::SetCurrent $projdir]" 10
   } else {
    dbputs "gtree::New: [::gtree::New $projdir]" 10
    dbputs "gtree::Load: [::gtree::Load $projdir/gtree.dat]" 10
  }
	set nodelist [lreverse [::gtree::NodeAncestors $node]] ;#list of all nodes incl nkey
  	lappend nodelist $node ;#add last node
	set pnamelist {} ;# list of parameter names
  	foreach n $nodelist {
		set name [::gtree::NodePname $n]
      if {$name != {}} {
      lappend pnamelist $name
    }
  }
  	set values [::gtree::NodePvalues $node] ;#list of parameter values
	foreach val $values pname $pnamelist {
  		set r($pname) $val
	}
  return [array get r]
}

# set all swb-parameters as tcl varialbes ::gparam($name)
proc exportParams {node {projdir ""}} {
  array set p [getparams $node $projdir]
	foreach name [array names p] {
  		set str "set ::gparam($name) $p($name)" 
      dbputs "str" 10
		if {[catch "eval $str"]} {"error during evaluation in exportParams: \"$str\""}
	}
}

# returns the lower value
proc min {a b} {
		if {$a < $b} {
				return $a
		} else {
				return $b
		}
}

#-- returns the bigger value
proc max {a b} {
		if {$a > $b} {
				return $a
		} else {
				return $b
		}
}

#-- checks whether n is a number
proc isNumber {n} {
		if {[catch {set b [expr $n+1]}]} {
				return 0
		} else {
				return 1
		}
}
#-- converts a string list consisting of () to a tcl list
proc strToList {str} {
		set cmd "set l \"\[string map \{( \" \\{ \" ) \" \\} \"\} \$str\]\""
		dbputs "cmd: $cmd" 10
		if {[catch {eval $cmd}]} {
				puts stderr "Cannot convert \"$str\" to a list"
		}
		return $l
}

#special print command which is a puts -nonewline in tcl par files used in mpr.
proc print { STRING  } {
 global TCLPP_FIDo
 puts -nonewline $TCLPP_FIDo "$STRING"
}

# determines whether material string is a binary material
proc isBinary {str} {
	set ok 0
	set binaries {Si Ge GaAs InP}
	foreach mat $binaries {
		if {[string equal -nocase $str $mat ]} {
			set ok 1
			break
		}
	}
	return ok
}

# determines whether material string is a ternary material
proc isTernary {str} {
	set ok 0
	set ternaries {AlGaAs GaAlAs GaInP InGaP GaInAs InGaAs}
	foreach mat $ternaries {
		if {[string equal -nocase $str $mat ]} {
			set ok 1
			break
		}
	}
	return ok
}

# load layer variables from epi(key) into variables with columnNames
proc loadLayerVariables {key} {
	set str ""
	foreach columnName [concat $::columnNames] {
		if {[info exists ::epi($key,$columnName)]} {
			set value $::epi($key,$columnName)
		} else {
			set value {}
		}
		set ::$columnName $value
		set str "${str} $columnName=$value"
	}
	set ::xMole [getDefaultValue ${::mole}]
	set ::yMole [getDefaultValue ${::mole} ymole]
	set str "${str} xMole=$::xMole yMole=$::yMole"
	dbputs "str: $str" 10
}

# returns a list of all layer keys that matches pattern
# e.g. "region,*" will return all keys of regions
# to access data from epi() use e.g. epi($key,doping)
# list order is as in the epi layer file
# if valuePattern is specified only those keys will be returned
# where the value matches valuePattern
proc getLayerKeyList {pattern {valuePattern "*"}} {
	set keylist {}
	#-dbputs "namelist: [array names ::epi "$pattern"]" 10
	foreach n [array names ::epi "$pattern"] {
		set key [regsub {([a-zA-Z0-9_/-]+,[a-zA-Z0-9_/-]+),[a-zA-Z0-9_/-]+} $n {\1}]
		#-dbputs "key: $key" 10
		if {[lsearch $keylist $key ] < 0&&[string match "$valuePattern" $::epi($n)]} {
			lappend keylist $key
		}
	}
	dbputs "keylist: $keylist" 10
	set result {}
	foreach key $keylist {
		lappend result [list $key $::epi($key,row)]
	}
	dbputs "unsorted result: $result" 10
	set result [lsort -real -index 1 $result]
	dbputs "sorted result: $result" 10
	set result [lindex [transpose $result] 0]
	return $result
}

# transposes a list
proc transpose {l} {
	set res {}
	if {[llength $l] == 0} {
		return {}
	}
	if {[llength [lindex $l 0]] == 0} {
		return $l
	}
	for {set j 0} {$j < [llength [lindex $l 0]]} {incr j} {
		set r {}
		for {set i 0} {$i < [llength $l]} {incr i} {
			lappend r [lindex $l "$i $j"]
		}
		lappend res $r
	}
	return $res
}

# returns a list without any doublicates. Unlike lsort -unique the order remains the same.
proc unique {l} {
	set res {}
	foreach i $l {
		if {[lsearch $l $i] < 0} {
			lappend res $i
		}
	}
	return $res
}

##--------------------------------------------------
#takes as .csv string and returns a list of the items.
#csv2list is taken from:
#http://aspn.activestate.com/ASPN/Cookbook/Tcl/Recipe/65433
#(license is public domain)
proc csv2list {str {sepChar ,}} {
	dbputs  "csv2list: str0: $str" 10
	regsub -all {(\A\"|\"\Z)} $str \0 str
	dbputs  "csv2list: str1: $str" 10
	set str [string map [list $sepChar\"\"\" $sepChar\0\" \
		 \"\"\"$sepChar \"\0$sepChar \
		 $sepChar\"\"$sepChar $sepChar$sepChar \
		 \"\" \" \
		 \" \0 ] $str]
  set end 0
	dbputs  "csv2list: str2: $str" 10
	while {[regexp -indices -start $end {(\0)[^\0]*(\0)} $str \
      -> start end]} {
    set start [lindex $start 0]
		set end   [lindex $end 0]
		set range [string range $str $start $end]
		set first [string first $sepChar $range]
		if {$first >= 0} {
			set str [string replace $str $start $end \
				 [string map [list $sepChar \1] $range]]
		}
		incr end
	}
	dbputs  "csv2list: str3: $str" 10
	set str [string map [list $sepChar \0 \1 $sepChar \0 {} ] $str]
	dbputs  "csv2list: str4: $str" 10
	set res [split $str \0]
	dbputs  "csv2list: res: [join $res "|"]" 10
	return $res
}

##--------------------------------------------------
# determines the global parameter directory
# first looks whether a global tcl variable pardb is set
# then uses the environment variable $STPARDB
# and last tries to look at the default location $STDB/pardb
proc getPardb {} {
	if {[info exists ::pardb]&&[string trim $::pardb]!=""} {
		set res $::pardb
		dbputs "info exists pardb: $res" 10
		if {![file isdirectory $res]} {
			puts stderr "Error: Variable \"pardb\" points to \"$res\" which does not exists."
			puts stderr "       probably the Variable \"pardb\" has been set to a wrong value in"
			puts stderr "       the MatPar tool. Please check."
			exit 1
		}
	} else {
		#- or defined as environment variable STPARDB
		global env
		if {[info exists env(STPARDB)]&&[string trim $env(STPARDB)]!=""} {
			dbputs "STPARDB found: $env(STPARDB)" 10
			set res $env(STPARDB)
			if {![file isdirectory $res]} {
				puts stderr "Error: environment variable \"STPARDB\" points to \"$res\" which does not exists."
				puts stderr "       probably the Variable \"pardb\" has been set to a wrong value in"
				puts stderr "       the MatPar tool. Please check."
				exit 1
			}
			#- or try default location STDB/pardb
		} elseif {[info exists env(STDB)]&&[string trim $env(STDB)]!=""} {
			dbputs "Trying STDB/pardb: $env(STDB)" 10
			if {[file isdirectory [file join $env(STDB) "pardb"]]} {
				set res [file join $env(STDB) "pardb"]
			} else {
				dbputs "no pardb" 10
				set res ""
			}
		} else {
			dbputs "no pardb" 10
			set res ""
		}
	}
	dbputs "res: $res" 10
	return $res
} 

proc getParfileWithPath {parfile} {
	#-- get the project directory 
	set CWD [pwd]
	set CWD [file dirname $CWD]
	set CWD [file dirname $CWD]
	set CWD [file dirname $CWD]
	set CWD [file dirname $CWD]

	set file ""
  if {[file exists [file join "../par" "$parfile"]]} {
		set file  [file join "../par" "$parfile"]
  } elseif {[file exists [file join "$CWD/par" "$parfile"]]} {
		set file  [file join "$CWD/par" "$parfile"]
  } else {
		set pardb [getPardb]
		if {[file exists [file join $pardb "$parfile"]]} {
			set file [file join $pardb "$parfile"]
		} 
	}
	return $file		
}

proc ::linspace {min max N} {
# Creates a list of N linearly spaced elements between min and max 
# a) N should be greater than 1 b)min != max c) min < max
    
# Validate inputs
    if {$N <= 1.0} {
        puts stderr "Error:linspace: N <= 1! N should be greater than 1"  
        exit -1
    }
    if {$min > $max} {
        puts stderr "Error:linspace: min > max! min should be less than max"
        exit -1
    }
# Calculate step size
    set step [expr {($max-$min)/($N-1.0)}]
# Calculate list of x values
    set xvalue_s [list]
    set xvalue $min
    if {$min == $max} {
        for {set i 0} {$i < $N} {incr i} {
            lappend xvalue_s $min
        }
    } elseif {$min < $max} {        
         while { $xvalue <= $max } {
            lappend xvalue_s $xvalue
            set xvalue [expr {$xvalue+$step}]
        }
    }
    return $xvalue_s
}

proc ::logspace {min max N} {
# Creates a list of N logarithmically spaced elements between min and max
# a) N should be greater than 1 b)min != max c) min < max
# d) min > 0 and max > 0
    
# Validate inputs
    if {$N <= 1.0} {
        puts stderr "Error:logspace: N <= 1! N should be greater than 1"  
        exit -1
    }
    if {($min <= 0) || ($max <= 0)} {
        if {$min <= 0} {
            puts stderr "Error:logspace: min <= 0! min should be a positive number"
        } elseif {$max <= 0} {
            puts stderr "Error:logspace: max <= 0! max should be a positive number"
        }
        exit -1
    }       
    if {$min > $max} {
        puts stderr "Error:logspace: min > max! min should be less than max"
        exit -1
    }
# Calculate step size
    set step [expr {(log10($max)-log10($min))/($N-1)}]
# Calculate list of x values
    set xvalue_s [list]
    set xvalue $min
    if {$min == $max} {
        for {set i 0} {$i < $N} {incr i} {
            lappend xvalue_s $min
        }
    } elseif {$min < $max} {  
         while { $xvalue <= $max } {
            lappend xvalue_s $xvalue
            set xvalue [expr {pow(10,(log10($xvalue)+$step))}]
        }
    }
    return $xvalue_s
}


proc ::decadelinspace {min max N} {
# Creates a list of linearly spaced elements between each decade
# a) N should be greater than 1 b)min != max c) min < max
# d) min > 0 and max > 0
# N = number of elements in each decade interval
    
# Validate inputs
    if {$N <= 1.0} {
        puts stderr "Error:decadelinspace: N <= 1! N should be greater than 1"  
        exit -1
    }
    if {($min <= 0) || ($max <= 0)} {
        if {$min <= 0} {
            puts stderr "Error:decadelinspace: min <= 0! min should be a positive number"
        } elseif {$max <= 0} {
            puts stderr "Error:decadelinspace: max <= 0! max should be a positive number"
        }
        exit -1
    }       
    if {$min >= $max} {
        if {$min > $max} {
            puts stderr "Error:decadelinspace: min > max! min should be less than max"
            exit -1
        } else {
             puts stderr "Error:decadelinspace: min = max! min should not be equal to max"
             exit -1
        }    
    }

    set listAll [linspace 1 10 $N]
    set N_decade [expr {log10($max)-log10($min)}] 

    set dopingList [list]
    for {set i 0} {$i < $N_decade} {incr i} {
         set Nlist($i) [list]
         foreach tmpList $listAll {                 
            set tmp [expr $min*pow(10,$i)*$tmpList]
            lappend Nlist($i) $tmp
        }
    set Nlist($i) [lrange $Nlist($i) 0 end-1]
    set dopingList [concat $dopingList $Nlist($i)]
    }
    set dopingList [concat $dopingList $max]
    return $dopingList
}    

# Find maxima in a list numbers
proc ::maxima {Xdata} {
    set maxima [lindex $Xdata 0]
    foreach x $Xdata {
        if {$maxima < $x} {
            set maxima $x
        }
    }
    return $maxima
}
    
# Find minima in a list of numbers
proc ::minima {Xdata} {
    set minima [lindex $Xdata 0]
    foreach x $Xdata {
        if {$minima > $x} {
            set minima $x
        }
    }
    return $minima
}

# Find minima in a list of numbers and the corresponding index
proc ::minIndex {Xdata} {
    set minima [lindex $Xdata 0]
    set index 0
    set min_index $index
    foreach x $Xdata {
        if {$minima > $x} {
            set minima $x
            set min_index $index
        }
        set index [expr {$index+1}]        
    }
    set minIndex [list $minima $min_index]
    return $minIndex
}

proc getDefaultValue {str {ymole {}}} {
	set val {}
	dbputs "str: @$str@ ymole: @$ymole@" 10
	set str [string trim $str]
	if {$str == ""} {return ""}
	set item $str
	if {$ymole!={}} {;# ymole
		# ...(y default 0.3)
		if {[regexp {\(\s*y\s+default\s+[0-9\+\-eE\.]+} $item]} {
			set val [regsub {.*\(\s*y\s+default\s+([0-9\+\-eE\.]+).*} $item {\1}]
			dbputs "val: @$val@" 10
			if {[isNumber $val]} {return $val}
		}
		# ...(y 0.3)
		if {[regexp {.*\(\s*y\s+[0-9\+\-eE\.]+.*} $item]} {
			set val [regsub {.*\(\s*y\s+([0-9\+\-eE\.]+).*} $item {\1}]
			dbputs "val: @$val@" 10
			if {[isNumber $val]} {return $val}
		}
		# ...(y lin 0.3)
		if {[regexp {.*\(\s*y\s+[[:alnum:]+]\s+[0-9\+\-eE\.]+} $item]} {
			set val [regsub {.*\(\s*y\s+[[:alnum:]+]\s+([0-9\+\-eE\.]+)} $item {\1}]
			dbputs "val: @$val@" 10
			if {[isNumber $val]} {return $val}
		}
		# ...(0.2 0.3)
		if {[regexp {.*\(\s*[0-9\+\-eE\.]+\s+[0-9\+\-eE\.]+\s*\)} $item]} {
			set val [regsub {.*\(\s*[0-9\+\-eE\.]+\s+([0-9\+\-eE\.]+)\s*\)} $item {\1}]
			dbputs "val: @$val@" 10
			if {[isNumber $val]} {return $val}
		}
	} else { ;# xmole
		# ...(default 0.3)
		if {[regexp {.*\(\s*default\s+[0-9\+\-eE\.]+.*} $item ]} {
			set val [regsub {.*\(\s*default\s+([0-9\+\-eE\.]+).*} $item {\1}]
			dbputs "val: @$val@" 10
			if {[isNumber $val]} {return $val}
		}
		# ... 0.3
		if {[regexp {\s*[0-9\+\-eE\.]+.*} $item]} {
			set val [regsub {\s*([0-9\+\-eE\.]+).*} $item {\1}]
			dbputs "val: @$val@" 10
			if {[isNumber $val]} {return $val}
		}
		# ... (...) 0.3
		if {[regexp {\s*\(.*\)\s*[0-9\+\-eE\.]+.*} $item ]} {
			set val [regsub {\s*\(.*\)\s*([0-9\+\-eE\.]+).*} $item {\1}]
			dbputs "val: @$val@" 10
			if {[isNumber $val]} {return $val}
		}
		# ...(0.3 ...
		if {[regexp {.*\(\s*[0-9\+\-eE\.]+.*} $item]} {;#\)
			set val [regsub {.*\(\s*([0-9\+\-eE\.]+).*} $item {\1}]
			dbputs "val: @$val@" 10
			if {[isNumber $val]} {return $val}
		}
		# ...(lin 0.3)
		if {[regexp {.*\(\s*\w+\s+[0-9\+\-eE\.]+.*} $item]} {
			set val [regsub {.*\(\s*\w+\s+([0-9\+\-eE\.]+).*} $item {\1}]
			dbputs "val: @$val@" 10
			if {[isNumber $val]} {return $val}
		}
	}
	if {$ymole == {}} {
		puts "Warning getDefaultValue: \"$str\" does not contain any useful default doping or xmole value"
#	} else {
#		puts "Warning getDefaultValue: \"$str\" does not contain any useful default ymole value"
	}
	return ""
}

