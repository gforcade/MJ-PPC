# MW - reverse order of a list

proc lreverse2 l {
    set ret ""
    foreach i $l {
    set ret [linsert $ret 0 $i]

    }
    return $ret
} 
