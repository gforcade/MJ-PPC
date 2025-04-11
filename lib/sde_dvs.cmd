!(
	puts ";sde_dvs.cmd TCL code block to print sde schema code to create virtual contacts"
	global contact_list
	set contact_list [list]
	proc create_VContact {name yposition} {
		# Signature: define-contact-set name_of_set edgeThickness color facePattern
		# edgeThickness always seems to be 4.  (Do I have 4um of thickness then?)
		# facePattern argument not relevant (omitted)
		# Check sense_ug chapter 7 "Electrical and Thermal Contacts" or try it from the GUI (I think sde from version L works)
		global contact_list
		lappend contact_list $name
		puts "(sdegeo:define-contact-set \"$name\" 4 (color:rgb 0 0 1))"
		puts "(sdegeo:set-current-contact-set \"$name\")"
		puts "(sdegeo:define-2d-contact (find-edge-id (position (/ @wtot@ 2.0) $yposition 0)) \"$name\")"
		# Note that contacts correspond to entire edge widths... we use X=wtot/2.0 since that works everywhere, including the cap
	}
	# Tunnel contacts are not common to all projects and are created after including this file
)!