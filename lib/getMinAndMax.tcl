# functions to read input file to get x data, and minimum and maximum values.


proc xData filename {
## reads in file and outputs the x data as a list

#read file
set fp [open $filename "r"]
set fData [read $fp]
close $fp

#split newlines into elements of list
set data [split $fData "\n"]
set x []

#loop through list to only grab numerical data
foreach line $data {
set ln [split $line ","]
if { [string is double [lindex $ln 0]] } {
 lappend x [lindex $ln 0]
}
}

return $x

}


proc max args {
    set res [lindex $args 0]
    set res [lindex $res 0]
    foreach element [lrange [lindex $args 0] 1 end] {
        if {$element > $res} {set res $element}
    }
    return $res
}

proc min args {
    set res [lindex $args 0]
    set res [lindex $res 0]
    foreach element [lrange [lindex $args 0] 1 end] {
        if {$element < $res && $element != ""} {set res $element}
    }
    return $res
}




