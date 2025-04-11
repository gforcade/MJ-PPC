import numpy as np
from scipy.interpolate import interp1d
from scipy.interpolate import UnivariateSpline

# test if a list is strictly ascending
def ordertest(A):
    return all(A[k] <= A[k+1] for k in range(len(A)-1))


class iv_params:
    def __init__(self, i, v):
        self.i = np.array(i)
        self.v = np.array(v)
        assert len(i) == len(v), 'Unequal length arrays'
        if ordertest(v) == False:
           self.i = self.i[::-1]
           self.v = self.v[::-1]
        assert ordertest(self.v), 'Voltage array out of order'
        assert max(i) > 0. and min(i) < 0., 'Current array does not cross zero'

        interp_i = interp1d(self.v,self.i, kind ='linear')
        self.isc = float(interp_i(0.))

        interp_v = interp1d(self.i[::-1],self.v[::-1], kind='linear', bounds_error=False)
        self.voc = float(interp_v(0.))

        spline_P = UnivariateSpline(self.v, self.i*self.v, k=4, s=0)
        dPdV = spline_P.derivative()
        roots = dPdV.roots()
        Pmax = -1e10
        for k in range(len(roots)):
            P = spline_P(roots[k])
            if P > Pmax:
                Pmax = P
                self.mppv = roots[k]
        self.mppi = interp_i(self.mppv)

        self.pmax = self.mppi*self.mppv
        self.ff = self.pmax/(self.voc*self.isc)
