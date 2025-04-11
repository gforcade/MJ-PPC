
temp = 300
doping = 1e15

%Parameters from Palankovski
        muL300_n = 8500
        muL300_p = 800
        gamma0_n = -2.2
        gamma0_p = -0.9
         mumin300_n = 800
         mumin300_p = 40
         gamma1_n = -0.9
         gamma1_p = 0
         Cref300_n = 1.0e17
         Cref300_p = 1.0e17
         gamma3_n = 6.2
         gamma3_p = 0.5
         alpha300_n = 0.5
         alpha300_p = 1.0
         gamma4_n = 0
         gamma4_p = 0
        
         muL_n = muL300_n*(temp/300.0)^gamma0_n
         muL_p = muL300_p*(temp/300.0)^gamma0_p
         mumin_n = mumin300_n*(temp/300.0)^gamma1_n
         mumin_p = mumin300_p*(temp/300.0)^gamma1_p
                           
% sdevice parameters (for Arora model) calculated from Palankovski parameters
	 Ar_mumin_n = mumin300_n
	 Ar_mumin_p = mumin300_p
	 Ar_alm_n = gamma1_n
	 Ar_alm_p = gamma1_p

	 Ar_mud_n = muL_n-mumin_n
	 Ar_mud_p = muL_p-mumin_p
	 Ar_ald_n = 0.0
	 Ar_ald_p = 0.0

     Ar_N0_n = Cref300_n
	 Ar_N0_p = Cref300_p
	 Ar_alN_n = gamma3_n
	 Ar_alN_p = gamma3_p

	 Ar_a_n = alpha300_n
	 Ar_a_p = alpha300_p
	 Ar_ala_n = gamma4_n
	 Ar_ala_p = gamma4_p
	
% Mobility calculation using Arora model and sdevice parameters
	 muminA_n = Ar_mumin_n*(temp/300.0)^Ar_alm_n
	 muminA_p = Ar_mumin_p*(temp/300.0)^Ar_alm_p
	 mudA_n = Ar_mud_n*(temp/300.0)^Ar_ald_n
	 mudA_p = Ar_mud_p*(temp/300.0)^Ar_ald_p
	 N00_n = Ar_N0_n*(temp/300.0)^Ar_alN_n
	 N00_p = Ar_N0_p*(temp/300.0)^Ar_alN_p
	 AA_n = Ar_a_n*(temp/300.0)^Ar_ala_n
	 AA_p = Ar_a_p*(temp/300.0)^Ar_ala_p

	 mu_dop_n =muminA_n + mudA_n/(1.0 + (doping/N00_n)^AA_n)
	 mu_dop_p =muminA_p + mudA_p/(1.0 + (doping/N00_p)^AA_p)

     % Palankovksi calculation
     