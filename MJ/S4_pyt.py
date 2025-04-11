#!/usr/bin/python
#setdep @node|sde@

import S4


S =  S4.New(Lattice=(1.0), NumBasis=100) #lattice in um

S.SetMaterial(Name='InGaAs', Epsilon=12.0+0.01j)
S.SetMaterial(Name='Vacuum',Epsilon=1.0+0.0j)


#S.AddLayerCopy(Name='slab2',Thickness=0.5, Layer='slab') ## code runs faster when copying layers than creating new ones every time
S.AddLayer(Name='top',Thickness=0.0,Material='Vacuum')
S.AddLayer(Name='slab',Thickness=0.6, Material='Silicon')
S.AddLayerCopy(Name='bottom',Thickness=0.0,Layer='top')




S.SetExcitationPlanewave( 
	IncidenceAngles=( 
		0, 	#polar angle in [0,180)
		0 	# azimuthal angle in [0,360)
	),
	sAmplitude = 1.0+0.0j,
	pAmplitude = 0.0+0.0j,
	Order = 0
)

S.SetFrequency(1.0/1.55) #1/wavelength in um



T = S.GetPowerFlux('bottom')

#I = S.GetLayerVolumeIntegral(Layer='slab',Quantity='U')

#print(I)
