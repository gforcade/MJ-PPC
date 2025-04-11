#----------------------------------------------------------------------#
# $Id: Default.tcl,v 1.1 2008/07/03 14:26:23 sameers Exp $ 
#----------------------------------------------------------------------#
#! MODEL: Temperature and Doping dependent model from Levinshtein
#! MATERIAL: GaInP
#! PROPERTY: SRH Recombination 
#! EXPRESSION: 
#! Temperature and doping dependent minority carrier lifetime is calculated using,
#! tau = taumin + ( taumax - taumin ) / ( 1 + ( N/Nref )^gamma)
#! where,
#! tau(T) = tau * ( (T/300)^Talpha )  
#! or
#! tau(T) = tau * exp( Tcoeff * ((T/300)-1) )
#! CALCULATED PARAMETER: 
#! taumin_i, taumax_i, Nref_i, gamma_i, Talpha_i, Tcoeff_i, Etrap, 
#! where i is n for n-type or p for p-type
#! VALIDITY: 
#! NOTES:
#! SDEVICE: Recombination(SRH)
#! REFERENCE: 
#! N. M. Hael, S. E. Williams, C. L. Franzen, C. Scandrett. Minority carrier lifetime variations associated with misfit dislocation networks in heteroepitaxial GaInP, Semiconductor Science and Technology, vol 25, p. 055017, 2010.
#! HISTORY:
#! Created on 2008/07/03 by Sameer Shah

namespace eval GaInP::Scharfetter {
    proc init {} {
    	variable Nref_n 1.0e19      ;# Default parameters from sdevice   
	variable Nref_p 1.0e19
    	variable gamma_n 1.0
	variable gamma_p 1.0
    	variable Talpha_n 0.0
	variable Talpha_p 0.0
    	variable Tcoeff_n 0.0
	variable Tcoeff_p 0.0
    	variable Etrap 0.0	
	variable taumin_n 0.0
	variable taumin_p 0.0

# Parameters from Levinshtein (default n and p are both 1e-9)    
# parameters from Strauss (interpolating between GaP and InP gives 1e-7 for both)   
# Parameters from above reference gives 20 ns for SRH recombination in bulk GaInP
#    	variable taumax_n $::tauSRH
#	variable taumax_p $::tauSRH
	variable taumax_n 2e-8
	variable taumax_p 2e-8		
   }
    proc print {} {printPar::ScharfetterSection}    
}
GaInP::Scharfetter::init
