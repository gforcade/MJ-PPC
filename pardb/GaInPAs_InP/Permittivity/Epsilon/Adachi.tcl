#----------------------------------------------------------------------#
# $Id: Piprek.tcl,v 1.2 2021/11/24 11:32:09 G Forcade Exp $
#----------------------------------------------------------------------#
#! MODEL: Room temperature model from Piprek
#! MATERIAL: GaInPAs lattice matched to InP
#! PROPERTY: Static dielectric permittivity
#! EXPRESSION: 
#! Static dielectric permittivity is given by
#!     epsilon = constant
#! CALCULATED PARAMETER: 
#! epsilon returns static dielectric permittivity
#! VALIDITY: This model is valid only for T=300K
#! NOTES:
#! SDEVICE:
#! REFERENCE:
#! Adachi
#! HISTORY:  
#! Created on 2023/02/14 by Gavin Forcade - uOttawa SUNLAB

namespace eval GaInPAs_InP::Epsilon {
  proc init {} {

#Lattice matching condition for Ga(y)In(1-y)P(x)As(1-x) to InP. From Adachi 2017.   
	set xMol $::xMole
	set yMol [expr {(0.1893 - 0.1893*$xMol)/(0.4050 + 0.0132*$xMol)}] 


#epsilons for the various materials from Piprek
	set epsilon_InP 12.9
	set epsilon_GaAs 12.9
	set epsilon_InAs 14.3
	set epsilon_GaP 11.0

    variable epsilon [expr {$epsilon_GaAs*$yMol*(1.0 - $xMol) + $epsilon_InP*$xMol*(1.0 - $yMol) + $epsilon_InAs*(1.0 - $xMol)*(1.0 - $yMol) + $epsilon_GaP*$xMol*$yMol}]  
  }
  proc print {} {printPar::EpsilonSection}  
}
GaInPAs_InP::Epsilon::init

