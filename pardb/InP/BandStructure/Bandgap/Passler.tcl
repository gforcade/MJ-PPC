#----------------------------------------------------------------------#
# $Id: Passler.tcl,v 1.1 2008/07/14 12:05:22 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Temperature dependent model from Passler
#! MATERIAL: InP
#! PROPERTY: Bandgap
#! EXPRESSION: 
#! Temperature dependent Bandgap is calculated using
#!	Eg(T) = Eg(0) - ($a*$theta/2)*((1+(2*temp/theta)^(1/p))^(1/p)-1)     
#! where,
#!	 Eg(T) =  Bandgap [eV] at temperature, temp [K]  
#!        Eg(0) =  Bandgap at 0K [eV]
#!        p     =  Passler parameter [1]
#!        a     =  Passler parameter [eV/K]
#! Temperature dependent electron affinity is calculated using 
#! Chi(T) = Chi(Tpar)- alpha*Tpar^2/(Tpar + beta) + alpha*T^2/(2*(T + beta)) + Bgn2Chi*Ebgn
#! Ebgn   =  Bandgap narrowing [eV] depending on BGN model not set here!
#! CALCULATED PARAMETER: 
#! Eg returns Eg(T) [eV]
#! Chi returns Chi(T) with Ebgn = 0 [eV]
#! VALIDITY: 
#! NOTES:
#! The Passler model is implemented by expressing Varshni parameters in terms of Passler parameters. 
#! The value of Ebgn depends on the BGN model chosen. It is not taken into account and set to 0 in the calculation of the parameter Bandgap::Chi.
#! The value of Chi0 is the sdevice default value.
#! SDEVICE: 
#! REFERENCE: 
#! R. Passler, "Parameter sets due to fittings of the temperature dependencies of fundamental bandgaps in semiconductors", Phys. Stat. Sol.(b), vol. 216, pp. 975-1007, 1999
#! "Semiconductor Optoelectronic Devices: Introduction to Physics and Simulation", J. Piprek, Elsevier Science(USA), 2003
#! HISTORY:
#! Created on 2008/07/14 by Sameer Shah

namespace eval InP::Bandgap {
    proc init {} {
# parameters from Passler
	set p 2.51           ;#[1]
	set a 0.391e-3       ;#[eV/K]
	set theta 243.00     ;#[K]
	set Eg00 1.424       ;#[K]

# Calculate sdevice parameters (Varshni) for Bandgap section
	variable alpha 0.0   ;# Dependence of Eg on temperature is taken into account in Passler model. 
	variable beta 1e-5   ;# Since Tpar=0, beta is set to a very small value to avoid divide by zero error in Chi calculation below.
	variable Tpar 0.0
	variable Eg  	    
	variable Eg0 
	variable Chi0
	variable Chi 	 
	variable Bgn2Chi 0.5     
	variable Egsubstrate 
	variable Chisubstrate

# Calculate Eg and Eg0
        set Eg [expr {$Eg00 - ($a*$theta/2)*(pow(1.00+pow((2*$::temp/$theta), $p), 1.00/$p)-1)}]  
	set Eg0 $Eg     ;# Since T dependence is suppressed, Eg=Eg0

# Calculate Chi0 and Chi
        if {[info exists ::cbo]} {
            if {[info exists ::substrate]} {
        # For heterostructures, substrate and cbo are defined. Calculate Chi for heterostructures                                          
	        set Egsubstrate [evalVar "${::substrate}::Bandgap::Eg"]
	        set Chisubstrate [evalVar "${::substrate}::Bandgap::Chi"]
	        puts "Egsubstrate: $Egsubstrate Chisubstrate: $Chisubstrate"
	        set Chi [expr {$Chisubstrate - $::cbo*($Eg - $Egsubstrate)}]
	        set Chi0 [expr {$Chi + $alpha*$Tpar*$Tpar/(2*($Tpar + $beta)) - $alpha*$::temp*$::temp/(2*($::temp + $beta))}]
	    } else {
                puts stderr "Please specify the substrate material to calculate Chi according to cbo."
                exit -1    
            }
        } else {
        # Calculate Chi for bulk                
            # In Piprek, Chi is defined for T=300K. Let this value be Chi300. We use Piprek's value since Passler model is discussed in Piprek
            set Chi300 4.40
            # Calculate Chi0 using Chi300
   	    set Chi0 [expr {$Chi300 - $alpha*300.0*300.0/(2*(300.0 + $beta))} ]
            # Calculate Chi
	    set Chi [expr {$Chi0 - $alpha*$Tpar*$Tpar/(2*($Tpar + $beta)) + $alpha*$::temp*$::temp/(2*($::temp + $beta))}]  
	}		   	
    }
    proc print {} {printPar::BandgapSection}    
}
InP::Bandgap::init
