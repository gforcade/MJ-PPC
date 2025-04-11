#----------------------------------------------------------------------#
# $Id: Piprek.tcl,v 1.2 2008/07/14 11:32:09 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Room temperature model from Piprek
#! MATERIAL: GaInPAs lattice matched to InP
#! PROPERTY: Optical dielectric permittivity
#! EXPRESSION: 
#! Optical dielectric permittivity is given by
#!     epsilon = constant
#! CALCULATED PARAMETER: 
#! epsilon_inf returns optical dielectric permittivity
#! VALIDITY: This model is valid only for T=300K
#! NOTES:
#! SDEVICE:
#! REFERENCE:
#! "Semiconductor Optoelectronic Devices: Introduction to Physics and Simulation", J. Piprek, Elsevier Science(USA), 2003
#! HISTORY:  
#! Created on 2021/11/19 by Sameer Shah

namespace eval GaInPAs_InP::Epsilon_inf {
  proc init {} {

#Lattice matching condition for Ga(y)In(1-y)P(x)As(1-x) to InP. From Adachi 2017.   
	set xMol $::xMole
	set yMol [expr {(0.1893 - 0.1893*$xMol)/(0.4050 + 0.0132*$xMol)}] 


#epsilons for the various materials from Piprek
	set epsilon_InP 9.61
	set epsilon_GaAs 10.9
	set epsilon_InAs 12.25
	set epsilon_GaP 9.08

    variable epsilon_inf [expr {$epsilon_GaAs*$yMol*(1.0 - $xMol) + $epsilon_InP*$xMol*(1.0 - $yMol) + $epsilon_InAs*(1.0 - $xMol)*(1.0 - $yMol) + $epsilon_GaP*$xMol*$yMol}]  
  }
  proc print {} {printPar::Epsilon_infSection}  
}
GaInPAs_InP::Epsilon_inf::init

