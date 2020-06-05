/* estmills
Estimates a probit model with the same arguments passed to estmills, then
generates a variable containing the inverse mills ratio evaluated at the
fitted values of the estimated probit model.
*/

program estmills
	syntax anything [if], GEN(string)

	marksample touse
	probit `anything' if `touse'

	tempvar phat
	predict `phat' if `touse', xb
	
	gen `gen' = exp(-.5*`phat'^2) / (sqrt(2*_pi) * normprob(`phat'))
end
