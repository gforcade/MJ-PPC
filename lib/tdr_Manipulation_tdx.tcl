# this procedure outputs all x and y data of a particular region according to a specific dataset

proc exportData_v2 {Region Data File} {
  # Input: Region: name of region you want coordinates from.        Data: Dataset name.          File: tdr directory/name.tdr
  TdrFileOpen $File
  set ng [TdrFileGetNumGeometry $File]
  # loop through geometries
  for {set ig 0} {$ig < $ng} {incr ig} {
    set dims [TdrGeometryGetDimension $File $ig]
    set gname [TdrGeometryGetName $File $ig]
    set ns [TdrGeometryGetNumState $File $ig]
    set nr [TdrGeometryGetNumRegion $File $ig]
    #puts " Number of states $ns. Number of regions $nr."
    # loop through states
    for {set is 0} {$is < $ns} {incr is} {
      # loop through regions
      for {set ir 0} {$ir < $nr} {incr ir} {
		set rname [TdrRegionGetName $File $ig $ir]
		if {$rname == $Region} {
		  set nd [TdrRegionGetNumDataset $File $ig $ir 0]
		  variable Data_out
		  set Data_out [list]
		  for {set id 0} {$id < $nd} {incr id} {
			set datasetName [TdrDatasetGetName $File $ig $ir $is $id]
			#puts "    dataset is called $datasetName"
			if {$datasetName == $Data} {
			#puts "    dataset found ($datasetName)"
			  set nData [TdrDatasetGetNumValue $File $ig $ir $is $id]
			  # loop through all data values and append to relevant matrix
			  set xlist [list]
			  set ylist [list]
			  set zlist [list]
			  for {set iv 0} {$iv < $nData} {incr iv} {
				variable y [TdrDataGetCoordinate $File $ig $ir $is $id $iv 1 0]
				variable x [TdrDataGetCoordinate $File $ig $ir $is $id $iv 0 1]
				variable z [TdrDataGetCoordinate $File $ig $ir $is $id $iv 0 0 1]
				lappend xlist $x
				lappend ylist $y
 				lappend zlist $z
			  } ;# end loop over all data values in dataset
			  #puts $nData
			  #puts [TdrDataGetAllCoordinates $File $ig $ir $is $id]

			  ## save coordinates in seperate files
			  set xFile [open ./${Region}_x.txt w]
			  puts $xFile $xlist
			  close $xFile
			  set yFile [open ./${Region}_y.txt w]
			  puts $yFile $ylist
			  close $yFile
			  if { $dims == 3 } {
			  set zFile [open ./${Region}_z.txt w]
			  puts $zFile $zlist
			  close $zFile
			  }
			  
			} ;# end if statement for specific Data
		  } ;# end loop over all datasets
		} ;# end if statement for finding specific region
      } ;# end loop over regions
    } ;# end loop over states
  } ;# end loop over geometries
  TdrFileClose $File ;# close file
  return $dims
}


# this procedure modifies (or sums up) all optical generation data for a particular region
proc modifyOptGen_v2 {inOpt Opt_in rNameEmit {multiplier 1.0}} {
  ## INPUT:     inOpt: input tdr filename.            Opt_in: optical generation data array.      rNameEmit: Region name to change Optical generation data
  set Opt_inFile [open $Opt_in "r"]
  set Opt_inData [read $Opt_inFile]
  set Opt_inData [split $Opt_inData]
  TdrFileOpen $inOpt
  set ngOpt [TdrFileGetNumGeometry $inOpt]
  for {set igOpt 0} {$igOpt < $ngOpt} {incr igOpt} {
    # puts stderr "entering geometry $igOpt"
    set gnameOpt [TdrGeometryGetName $inOpt $igOpt]
    set nsOpt [TdrGeometryGetNumState $inOpt $igOpt]
    set nrOpt [TdrGeometryGetNumRegion $inOpt $igOpt]
    # loop through states
    for {set isOpt 0} {$isOpt < $nsOpt} {incr isOpt} {
	# loop through regions
	# puts stderr "entering state $isOpt"
	for {set irOpt 0} {$irOpt < $nrOpt} {incr irOpt} {
	  set rnameOpt [TdrRegionGetName $inOpt $igOpt $irOpt]
	  set ndOpt [TdrRegionGetNumDataset $inOpt $igOpt $irOpt $isOpt]
	  # start a new loop over all datasets in each region
	  if {$rnameOpt == $rNameEmit} {
	    for {set idOpt 0} {$idOpt < $ndOpt} {incr idOpt} {
	      set datasetNameOpt [TdrDatasetGetName $inOpt $igOpt $irOpt $isOpt $idOpt]
	      if {$datasetNameOpt == "OpticalGeneration"} {
			set nOptGen [TdrDatasetGetNumValue $inOpt $igOpt $irOpt $isOpt $idOpt]
			# loop through all data values of Optical Generation
			for {set ivOpt 0} {$ivOpt < $nOptGen} {incr ivOpt} {
			  # write optical generation to file
			  set modOptGen [expr [lindex $Opt_inData $ivOpt]*$multiplier]
			  TdrDataSetComponent $inOpt $igOpt $irOpt $isOpt $idOpt $ivOpt 0 0 $modOptGen
			  # puts stderr "Modified the optGen in layer $rNameEmit from [format %e $OptGen] to [format %e $modifiedOptGen]"

			} ;# end loop over all data values in OptGen
	      } ;# end if statement for optGen
	    } ;# end loop over datasets
	  } ;# end if statement for locating region of interest
	} ;# end loop through regions
    } ;# end loop through states
  } ;# end loop through geometries
  TdrFileSave $inOpt 
  TdrFileClose $inOpt
}



#### old functions from Alex. Above are my new functions

proc exportData {Region Data File} {
  # Input: Region: name of region you want coordinates from.        Data: Dataset name.          File: tdr directory/name.tdr
  TdrFileOpen $File
  set ng [TdrFileGetNumGeometry $File]
  # look through geometries
  for {set ig 0} {$ig < $ng} {incr ig} {
    set gname [TdrGeometryGetName $File $ig]
    set ns [TdrGeometryGetNumState $File $ig]
    set nr [TdrGeometryGetNumRegion $File $ig]
    puts " Number of states $ns. Number of regions $nr."
    # loop through states
    for {set is 0} {$is < $ns} {incr is} {
      # loop through regions
      for {set ir 0} {$ir < $nr} {incr ir} {
		set rname [TdrRegionGetName $File $ig $ir]
		if {$rname == $Region} {
		  set nd [TdrRegionGetNumDataset $File $ig $ir 0]
		  variable Data_out
		  set Data_out [list]
		  for {set id 0} {$id < $nd} {incr id} {
			set datasetName [TdrDatasetGetName $File $ig $ir $is $id]
			puts "    dataset is called $datasetName"
			if {$datasetName == $Data} {
			puts "    dataset found ($datasetName)"
			  set nData [TdrDatasetGetNumValue $File $ig $ir $is $id]
			  # loop through all data values and append to relevant matrix
			  set xlist [list]
			  set ylist [list]
			  set datalist [list]
			  for {set iv 0} {$iv < $nData} {incr iv} {
				variable y [TdrDataGetCoordinate $File $ig $ir $is $id $iv 1 0]
				variable x [TdrDataGetCoordinate $File $ig $ir $is $id $iv 0 1]
				variable DataMagnitude [TdrDataGetValue $File $ig $ir $is $id $iv]
				lappend xlist $x
				lappend ylist $y
				lappend datalist $DataMagnitude
			  } ;# end loop over all data values in dataset
			  set Data_out [list $xlist $ylist $datalist]
			} ;# end if statement for specific Data
		  } ;# end loop over all datasets
		} ;# end if statement for finding specific region
      } ;# end loop over regions
    } ;# end loop over states
  } ;# end loop over geometries
  TdrFileClose $File ;# close file
  return $Data_out
}



# this procedure modifies (or sums up) all optical generation data for a particular region
proc modifyOptGen {inOpt outOpt x_in y_in z_in PR_in rNameEmit} {
  ## INPUT:     inOpt: input tdr filename.       outOpt: output tdr filename.      x_in: array of x coordinates
  TdrFileOpen $inOpt
  set ngOpt [TdrFileGetNumGeometry $inOpt]
  for {set igOpt 0} {$igOpt < $ngOpt} {incr igOpt} {
    # puts stderr "entering geometry $igOpt"
    set gnameOpt [TdrGeometryGetName $inOpt $igOpt]
    set nsOpt [TdrGeometryGetNumState $inOpt $igOpt]
    set nrOpt [TdrGeometryGetNumRegion $inOpt $igOpt]
    # loop through states
    for {set isOpt 0} {$isOpt < $nsOpt} {incr isOpt} {
	# loop through regions
	# puts stderr "entering state $isOpt"
	for {set irOpt 0} {$irOpt < $nrOpt} {incr irOpt} {
	  set rnameOpt [TdrRegionGetName $inOpt $igOpt $irOpt]
	  set ndOpt [TdrRegionGetNumDataset $inOpt $igOpt $irOpt $isOpt]
	  # start a new loop over all datasets in each region
	  if {$rnameOpt == $rNameEmit} {
	    for {set idOpt 0} {$idOpt < $ndOpt} {incr idOpt} {
	      set datasetNameOpt [TdrDatasetGetName $inOpt $igOpt $irOpt $isOpt $idOpt]
	      if {$datasetNameOpt == "OpticalGeneration"} {
			set nOptGen [TdrDatasetGetNumValue $inOpt $igOpt $irOpt $isOpt $idOpt]
			# loop through all data values of Optical Generation
			set xlist [list]
			set ylist [list]
			set OptGenlist [list]
			set modOptGenlist [list]
			for {set ivOpt 0} {$ivOpt < $nOptGen} {incr ivOpt} {
			  # extract Opt Gen for coordinate (x,y)
			  variable OptGen [TdrDataGetValue $inOpt $igOpt $irOpt $isOpt $idOpt $ivOpt] 
			  variable y [TdrDataGetCoordinate $inOpt $igOpt $irOpt $isOpt $idOpt $ivOpt 1 0]
			  variable x [TdrDataGetCoordinate $inOpt $igOpt $irOpt $isOpt $idOpt $ivOpt 0 1]
			  # for this particular ivOpt index, also compare to point (x,y) in PR dataset: they should MATCH.
			  variable x_in_ivOpt [lindex $x_in $ivOpt]
			  variable y_in_ivOpt [lindex $y_in $ivOpt]
			  if {(($x_in_ivOpt == $x) && ($y_in_ivOpt == $y))} {
				  # puts stderr "we have a match. Computing modified optical generation at this point..."
				  variable PR_ivOpt [lindex $PR_in $ivOpt]
			  } else {
				  puts stderr "we do not have a match for optGen pos ($x, $y) vs PR pos ($x_in_ivOpt,$y_in_ivOpt)"
				  # variable PR_ivOpt 0
			  } ;# end if statement for position match

			  # modify optical generation due to additional PR magnitude
			  set modifiedOptGen [expr { ( $OptGen + $PR_ivOpt ) }]
			  TdrDataSetComponent $inOpt $igOpt $irOpt $isOpt $idOpt $ivOpt 0 0 $modifiedOptGen
			  # puts stderr "Modified the optGen in layer $rNameEmit from [format %e $OptGen] to [format %e $modifiedOptGen] using PR = [format %e $PR_ivOpt]"

			} ;# end loop over all data values in OptGen
	      } ;# end if statement for optGen
	    } ;# end loop over datasets
	  } ;# end if statement for locating region of interest
	} ;# end loop through regions
    } ;# end loop through states
  } ;# end loop through geometries
  TdrFileSave $inOpt $outOpt
  TdrFileClose $inOpt
}
