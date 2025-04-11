#----------------------------------------------------------------------#
# $Id: Levinshtein.tcl,v 1.1 2008/06/30 13:49:34 sameers Exp $ 
#----------------------------------------------------------------------#
#! MODEL: Temperature and Doping dependent model from sdevice
#! MATERIAL: InP
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
#! "Handbook series on Semiconductor Parameters, Vol I"
#! M. Levenshtein, S. Rumyantsev, M. Shur, World Scientific, 1996
#! HISTORY:
#! Created on 2008/06/30 by Sameer Shah

namespace eval InP::Scharfetter {
    proc init {} {
    	variable Nref_n 1.0e15      ;# from Ioffe   
	variable Nref_p 1.0e14
    	variable gamma_n 1.0
	variable gamma_p 1.0
    	variable Talpha_n 0.0
	variable Talpha_p 0.0
    	variable Tcoeff_n 0.0
	variable Tcoeff_p 0.0
    	variable Etrap 0.0	
	variable taumin_n 0.0
	variable taumin_p 0.0

# Parameters from Levinshtein        
    	variable taumax_n 2.0e-9    ;# low level injection  
	variable taumax_p 3.0e-6	
   }
    proc print {} {printPar::ScharfetterSection}    
}
InP::Scharfetter::init
