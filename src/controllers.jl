export run_control_2DOF

"""
	y,u,r = run_control_2DOF(process, sysFB[, sysFF]; duration = 10, reference(t) = sign(sin(2π*t)))
Perform control experiemnt on process where the feedback and feedforward controllers are given by
`sysFB` and `sysFF`, both of type `StateSpace`.

`reference` is a reference generating function that accepts a scalar `t` (time in seconds) and outputs a scalar `r`, default is `reference(t) = sign(sin(2π*t))`.

The outputs `y,u,r` are the beam angle, control signal and reference respectively.
![block diagram](feedback4.png)
"""
function run_control_2DOF(P::AbstractProcess,sysFB, sysFF=nothing; duration = 10, reference = t->sign(sin(2π*t)))
	nu = num_inputs(P)
	ny = num_outputs(P)
	h  = sampletime(P)
	y  = zeros(ny, length(0:h:duration))
	u  = zeros(nu, length(0:h:duration))
	r  = zeros(ny, length(0:h:duration))

	Gfb = SysFilter(sysFB)
	if sysFF != nothing
		Gff = SysFilter(sysFF)
	end

	function calc_control(i)
		rf = sysFF == nothing ? r[:,i] : Gff(r[:,i])
		e  = rf-y[:,i]
		ui = Gfb(e)
		ui .+ bias(P)
	end

	simulation = isa(P, SimulatedProcess)
	initialize(P)
	for (i,t) = enumerate(0:h:duration)
		@periodically h simulation begin
			y[:,i]    .= measure(P)
			r[:,i]    .= reference(t)
			u[:,i]    .= calc_control(i) # y,r must be updated before u
			control(P, [clamp.(u[j,i], inputrange(P)[j]...) for j=1:nu])
		end
	end
	finalize(P)
	y',u',r'
end
