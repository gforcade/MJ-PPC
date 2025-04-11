#----------------------------------------------------------------------#
# $Id: Default.tcl,v 1.1 2008/04/09 10:14:48 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Nonlocal tunneling parameters from sdevice
#! MATERIAL: Ge
#! PROPERTY: Nonlocal tunneling
#! EXPRESSION: 
#! Non Local Barrier Tunneling rate is calculated using
#! G(r) = g*A*T/kB*F(r)*Pt(r)*ln[(1+exp((E(r)-Es)/kB/T))/(1+exp((E(r)-Em)/kB/T))]
#! CALCULATED PARAMETER: 
#! g_n, g_p, mt_n, mt_p, alpha_n, alpha_p
#! VALIDITY: 
#! NOTES: 
#! SDEVICE: Recombination(BarrierTunneling)
#! REFERENCE: 
#! Sentaurus Device User Guide 
#! HISTORY:
#! Created on 2007/09/10 by Sameer Shah

namespace eval Ge::BarrierTunneling {
    proc init {} {
    	variable gc 1.19
	    variable gv 0.34
    	variable mc 0.0
	    variable mv 0.0
    	variable alphac 0.0
	    variable alphav 0.0
    }
    proc print {} {printPar::BarrierTunnelingSection}    
}
Ge::BarrierTunneling::init
