# $Id: layers.tcl,v 1.7 2007/11/30 16:31:35 letay Exp $
namespace eval layers {
	#- create a profile for doping xmole or ymole
	proc createRegion {region material dimension xmin ymin zmin xmax ymax zmax} {
		dbputs "region: $region material: $material dimension: $dimension posmin:($xmin,$ymin,$zmin) posmax:($xmax,$ymax,$zmax)" 9
    switch $dimension {
      2 {set CObject "rectangle"}
      3 {set CObject "cuboid"}
      default {
        puts stderr "Error in createRegion: dimension = $dimension. Must be 2 or 3."
        exit 1 
      } 
    }
    set str ""
    set str "${str}(sdegeo:create-$CObject"
    set str "${str}  (position  $xmin   $ymin  $zmin)"
    set str "${str}  (position  $xmax   $ymax  $zmax) \"$material\" \"$region\" )"
    return $str
  }
	
	#- create a profile for doping xmole or ymole
	proc createProfile {species region cmd xmin ymin zmin xmax ymax zmax} {
		dbputs "species: $species cmd: $cmd region: $region posmin:($xmin,$ymin,$zmin) posmax:($xmax,$ymax,$zmax)" 9
		set value ""
		set func ""
		set res ""
		if {[llength $cmd] == 0} {
			set func "const"
			set value 0
		} elseif {[llength $cmd] == 1} {
			if {[isNumber $cmd]} {
				set value $cmd
				set func "const"
			} 
		} elseif {[llength $cmd] > 1&&[string match "*[lindex $cmd 0]*" "lin_erf_gauss"]} {
			set func [lindex $cmd 0]
			set value [lindex $cmd 1]
			set opts [lrange $cmd 2 end]
		} else {
			puts "  WARNING: create profile for region $region \"$cmd\" not supported"
		}
    dbputs "func: \"$func\" value: \"$value\"" 9
		set str ""
		if {[string equal -nocase "doping" $species]} {
			if {$value < 0} {
				set speciesType "BoronActiveConcentration"
				set species "pdop"
			} else {
				set speciesType "ArsenicActiveConcentration"
				set species "ndop"
			}
		} elseif {[string equal -nocase "xmole" $species]} {
			set speciesType "xMoleFraction"
		} elseif {[string equal -nocase "ymole" $species]} {
			set speciesType "yMoleFraction"
		} else {
			puts "WARNING in create profile for region \"$region\": species \"$species\" not supported"
		}
		set refWinName "${species}_refwin_${region}_$func"
		set profileName "${species}_${region}_$func"
		dbputs "profileName:>$profileName< refWinName: $refWinName speciesType: \"$speciesType\"" 9
		if {[string equal -nocase "const" $func]} {
			dbputs "place const profile" 9
			if {$value < 0} {
				set value [expr abs($value)]
                        }
			set str "${str}(sdedr:define-constant-profile \"$profileName\" \"$speciesType\" $value)\n"
			set str "${str}(sdedr:define-constant-profile-region \"$profileName\" \"$profileName\" \"$region\")"
		} elseif {[string equal -nocase "lin" $func]} {
			dbputs  "place linear profile" 9
			set a $value 
			set b [lindex $opts 0]
			set m [expr ($b-$a)/($ymax-$ymin)]
			#- put together the function "m*(y-ymin) + a"
			set funcstr "$m*(y-$ymin)+$a"
			set funcstr [string map {e {*10^}} $funcstr]
			dbputs "place lin profile:$speciesType ($funcstr)" 9
			set str "${str}(sdedr:define-refinement-window  \"$refWinName\"  \"Rectangle\"\n"
			set str "${str}  (position $xmin $ymin $zmin)\n"
			set str "${str}  (position $xmax $ymax $zmax))\n"
			set str "${str}(sdedr:define-analytical-profile-placement \"$profileName\" \"$profileName\"\n"
			set str "${str}  \"$refWinName\" \"Both\" \"NoReplace\" \"General\" \"$region\" 0. \"region\")\n"
			set str "${str}(sdedr:define-analytical-profile \"$profileName\" \"$speciesType\"\n"
			set str "${str}  \"\" \"$funcstr\"  0. \"General\")"
    } elseif {[string match -nocase "*$func*" "erf_gauss"]} {
			dbputs  "place erf or gauss profile" 9
			set cmax $value 
			if {![isNumber $cmax]} {puts "WARNING: createing profile for $region cmax \"$cmax\" not a number"}
			set ysym [lindex $opts 0]
			if {![isNumber $cmax]} {puts "WARNING: createing profile for $region ysym \"$ysym\" not a number"}
      set len  [lindex $opts 1]
			if {![isNumber $len]} {puts "WARNING: createing profile for $region len \"$len\" not a number"}
      if { [llength $opts] > 2} {
        set optstr [lindex $opts 2]
      } else {
         set optstr "ue" ;#default setting upper interface evaluate in region
      }
      dbputs "cmax=$cmax ysym=$ysym len=$len optstr=$optstr" 9
      # define upper or lower interface as line for profile
      if {[string match -nocase "*d*" $optstr]} {
        set ypos $ymax
      } else {
        set ypos $ymin
      }
      if {[string match -nocase "*r*" $optstr]} {
        set replace "Replace"
      } else {
        set replace "NoReplace"
      }
      if {[string match -nocase "*p*" $optstr]} {
        set direction "Positive"
      } elseif {[string match -nocase "*n*" $optstr]} {
        set direction "Negative"
      } else {
        set direction "Both"
      }
      dbputs "ypos=$ypos replace=$replace" 9
			if {[string equal -nocase "erf" $func]} {
        set str "${str}(sdedr:define-erf-profile \"$profileName\" \"$speciesType\"\n"
        set str "${str}  \"SymPos\" $ysym \"MaxVal\" $cmax \"Length\" $len \"Erf\" \"Factor\" 0.)\n"
      } elseif {[string equal -nocase "gauss" $func]} {
        set str "${str}(sdedr:define-gaussian-profile \"$profileName\" \"$speciesType\"\n"
        set str "${str}  \"PeakPos\" $ysym \"PeakVal\" $cmax \"Length\" $len \"Erf\" \"Factor\" 0.)\n"
			}
      set str "${str}(sdedr:define-refeval-window \"$refWinName\" \"Line\"\n"
      set str "${str}  (position $xmin $ypos $zmin) (position $xmax $ypos $zmin))\n"
      if {[string match -nocase "*e*" $optstr]} {
        set str "${str}(sdedr:define-analytical-profile-placement \"$profileName\" \"$profileName\" \"$refWinName\"\n"
        set str "${str}  \"$direction\" \"$replace\" \"Eval\" \"$region\" 0. \"region\")"
      } else {
        set str "${str}(sdedr:define-analytical-profile-placement \"$profileName\" \"$profileName\" \"$refWinName\"\n"
        set str "${str}  \"$direction\" \"$replace\" \"Eval\")"
      }
		} else {
			puts "WARNING: profile \"$func\" not implemented yet"
		}
		return $str
	}

	#----------------------------------------
	#- create refinements
	proc createConstantRefinement {region dimension xmin ymin zmin {xmax ""} {ymax ""} {zmax ""} {x1 ""} {y1 ""} {z1 ""} {x2 ""} {y2 ""} {z2 ""}} {
		dbputs "region:$region dimension:$dimension" 9
		set str ""
		if {$xmax == ""} {set xmax $xmin}
		if {$ymax == ""} {set ymax $ymin}
		if {$zmax == ""} {set zmax $zmin}
		if {$xmin==0.} {set xmin $xmax}
		if {$ymin==0.} {set ymin $ymax}
		if {$zmin==0.} {set zmin $zmax}
		set xmin [min $xmin xmax]
		set ymin [min $ymin ymax]
		set zmin [min $zmin zmax]
		set refname "Ref_$region"
    # do we have refinement-window specifications?
    if {$x1 != ""} {
      switch $dimension {
        2 {
					set RObject "Rectangle"
					set z1 0 ;# in 2D we do not need z coordinates
					set z2 0
				}
        3 {set RObject "Cuboid"}
        default {
          puts stderr "Error in createConstantRefinement: dimension = $dimension. Must be 2 or 3."
          return ""
        } 
      }
      set str "${str}(sdedr:define-refinement-window \"${refname}\"  \"${RObject}\"" 
      set str "${str}\n  (position $x1 $y1 $z1) (position $x2 $y2 $z2))" 
    }
		set str "${str}\n(sdedr:define-refinement-size \"$refname\" $xmax $ymax $zmax $xmin $ymin $zmin)"
    if {$x1 == ""} {
      set str "${str}\n(sdedr:define-refinement-region \"$refname\" \"$refname\" \"$region\")"
    } else {
      set str "${str}\n(sdedr:define-refinement-placement \"$refname\" \"$refname\" \"$refname\")"
    }
		return $str
	}

	#----------------------------------------
	#- create multibox refinement
	proc createMboxRefinement {region dimension x1 y1 z1 x2 y2 z2 msize mratio {msides "b"}} {
		dbputs "region: $region ($x1 $y1 $z1)-($x2 $y2 $z2) msize: $msize mratio:$mratio msides:$msides" 9
		set str ""
		set msides [string map -nocase {up u down d both ud left l right r front f back b} $msides]
		set width [expr abs($x2-$x1)]
		set depth [expr abs($z2-$z1)]
		set thickness [expr abs($y2-$y1)]
		set mboxname ""
		set refname "Ref_$region"
		set geoelement "Rectangle"
		if {$dimension == 3} {
			set geoelement "Cuboid"
		}
		dbputs "width: $width depth: $depth thickness: $thickness geoelement:$geoelement msides:$msides" 9
		set str "${str}(sdedr:define-refinement-window \"$refname\" \"$geoelement\"\n"
		set str "${str}  (position $x1 $y1 $z1) (position $x2 $y2 $z2))"
		if {[string match -nocase "*u*" $msides]} {
			set mboxname "mbox_${region}_up"
			set str "${str}\n(sdedr:define-multibox-size \"$mboxname\" $width $thickness $depth\n"
			set str "${str}  $width $msize $depth     1.0  $mratio 1.0)\n"
			set str "${str}(sdedr:define-multibox-placement \"$mboxname\" \"$mboxname\" \"$refname\")"
		}
		if {[string match -nocase "*d*" $msides]} {
			set mboxname "mbox_${region}_down"
			set str "${str}\n(sdedr:define-multibox-size \"$mboxname\" $width $thickness $depth \n"
			set str "${str}  $width $msize $depth     1.0 -$mratio 1.0)\n"
			set str "${str}(sdedr:define-multibox-placement \"$mboxname\" \"$mboxname\" \"$refname\")"
		}
		if {[string match -nocase "*l*" $msides]} {
			set mboxname "mbox_${region}_left"
			set str "${str}\n(sdedr:define-multibox-size \"$mboxname\" $width $thickness $depth \n"
			set str "${str}  $msize $thickness $depth $mratio 1.0 1.0)\n"
			set str "${str}(sdedr:define-multibox-placement \"$mboxname\" \"$mboxname\" \"$refname\")"
		}
		if {[string match -nocase "*r*" $msides]} {
			set mboxname "mbox_${region}_right"
			set str "${str}\n(sdedr:define-multibox-size \"$mboxname\" $width $thickness $depth \n"
			set str "${str}  $msize $thickness $depth -$mratio 1.0 1.0)\n"
			set str "${str}(sdedr:define-multibox-placement \"$mboxname\" \"$mboxname\" \"$refname\")"
		}
		if {[string match -nocase "*f*" $msides]} {
			set mboxname "mbox_${region}_front"
			set str "${str}\n(sdedr:define-multibox-size \"$mboxname\" $width $thickness $depth \n"
			set str "${str}  $width $thickness $msize 1.0 1.0 $mratio)\n"
			set str "${str}(sdedr:define-multibox-placement \"$mboxname\" \"$mboxname\" \"$refname\")"
		}
		if {[string match -nocase "*b*" $msides]} {
			set mboxname "mbox_${region}_back"
			set str "${str}\n(sdedr:define-multibox-size \"$mboxname\" $width $thickness $depth \n"
			set str "${str}  $width $thickness $msize 1.0 1.0 -$mratio)\n"
			set str "${str}(sdedr:define-multibox-placement \"$mboxname\" \"$mboxname\" \"$refname\")"
		}
		return $str
	}
	
	#----------------------------------------
	#- create multibox refinement
	proc addContact {name side {dim 2}} {
		dbputs "name: $name side: $side" 9
		set str ""
		if {[string match -nocase "top" $side]} {
			set ystr "Ytop"
		} elseif {[string match -nocase "bottom" $side]} {
			set ystr "Ybot"
		}
		set str "${str}(sdegeo:define-contact-set \"${name}\" 4  (color:rgb 0 1 0 ) \"\#\#\" )"
		set str "${str}\n(sdegeo:set-current-contact-set \"${name}\")"
		if {$dim <= 2} {
			set str "${str}\n(sdegeo:define-2d-contact (find-edge-id (position (/ (+ Xmin Xmax) 2) $ystr 0)) (sdegeo:get-current-contact-set))"
		} else {
			set str "${str}\n(sdegeo:define-3d-contact (find-face-id (position (/ (+ Xmin Xmax) 2) $ystr (/ (+ Zmin Zmax) 2))) (sdegeo:get-current-contact-set))"
		}
		return $str
	}

}
