# $Id: helper.tcl,v 1.20 2007/11/30 09:24:03 letay Exp $
#set DEBUG 10
# gradient
    #
    #    adjusts a color to be "closer" to either white or black
    #
    # Usage:
    #
    #    gradient color factor ?window?
    #
    # Arguments:
    #
    #    r,g,b	 - standard tk color;  rgb value from 0 to 255
    #              
    #    factor  - a number between -1.0 and 1.0. Negative numbers
    #              cause the color to be adjusted towards black;
    #              positive numbers adjust the color towards white.

    proc gradient {r g b factor} {



        ### Figure out color depth and number of bytes to use in
        ### the final result.
        set max 255
        set len 2

        ### Compute new red value by incrementing the existing
        ### value by a value that gets it closer to either 0 (black)
        ### or $max (white)
        set range [expr {$factor >= 0.0 ? $max - $r : $r}]
        set increment [expr {int($range * $factor)}]
        incr r $increment

        ### Compute a new green value in a similar fashion
        set range [expr {$factor >= 0.0 ? $max - $g : $g}]
        set increment [expr {int($range * $factor)}]
        incr g $increment

        ### Compute a new blue value in a similar fashion
        set range [expr {$factor >= 0.0 ? $max - $b : $b}]
        set increment [expr {int($range * $factor)}]
        incr b $increment

        ### Format the new rgb string
        set rgb \
            [format "#%.${len}X%.${len}X%.${len}X" \
                 [expr {($r>$max)?$max:(($r<0)?0:$r)}] \
                 [expr {($g>$max)?$max:(($g<0)?0:$g)}] \
                 [expr {($b>$max)?$max:(($b<0)?0:$b)}]]


        ### Return the new rgb string
        return $rgb
    }
