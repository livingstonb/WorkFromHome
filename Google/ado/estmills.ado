program estmills
	syntax anything [if], GEN(string)

	marksample touse

	probit `anything' if `touse'

	tempvar phat
	predict `phat', xb
	
	gen `gen' = exp(-.5*`phat'^2) / (sqrt(2*_pi) * normprob(`phat'))
end
