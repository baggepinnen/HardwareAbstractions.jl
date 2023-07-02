export @periodically, @periodically_yielding, init_sysfilter, sysfilter!, SysFilter

"""
	@periodically(h, body)
Ensures that the body is run with an interval of `h >= 0.001` seconds.
"""
macro periodically(h, body)
	quote
		local start_time = time()
		$(esc(body))
		local execution_time = time()-start_time
		Libc.systemsleep(max(0,$(esc(h))-execution_time))
	end
end

macro periodically_yielding(h, body)
	quote
		local start_time = time()
		$(esc(body))
		local execution_time = time()-start_time
		sleep(max(0,$(esc(h))-execution_time))
	end
end

"""
	@periodically(h, simulation::Bool, body)
Ensures that the body is run with an interval of `h >= 0.001` seconds.
If `simulation == false`, no sleep is done
"""
macro periodically(h, simulation, body)
	quote
		local start_time = time()
		$(esc(body))
		local execution_time = time()-start_time
		$(esc(simulation)) || Libc.systemsleep(max(0,$(esc(h))-execution_time))
	end
end


"""
	Csf = SysFilter(sys_discrete::StateSpace)
	Csf = SysFilter(sys_continuous::StateSpace, sampletime)
	Csf = SysFilter(sys::StateSpace, state::AbstractVector)
Returns an object used for filtering signals through LTI systems.
Create a SysFilter object that can be used to implement control loops and simulators
with LTI systems, i.e., `U(z) = C(z)E(z)`. To filter a signal `u` through the filter,
call like `y = Csf(u)`. Calculates the filtered output `y` in `y = Cx+Du, x'=Ax+Bu`
"""
struct SysFilter{T<:StateSpace}
	sys::T
	state::Vector{Float64}
	function SysFilter(sys::StateSpace, state::AbstractVector)
		@assert !ControlSystems.iscontinuous(sys) "Can not filter using continuous time model."
		@assert length(state) == sys.nx "length(state) != sys.nx"
		new{typeof(sys)}(sys, state)
	end
	function SysFilter(sys::StateSpace)
		@assert !ControlSystems.iscontinuous(sys) "Can not filter using continuous time model. Supply sample time."
		new{typeof(sys)}(sys, init_sysfilter(sys))
	end
	function SysFilter(sys::StateSpace, h::Real)
		@assert ControlSystems.iscontinuous(sys) "Sample time supplied byt system model is already in discrete time."
		sysd = c2d(sys, h)[1]
		new{typeof(sysd)}(sysd, init_sysfilter(sysd))
	end
end
(s::SysFilter)(input) = sysfilter!(s.state, s.sys, input)

"""
	state = init_sysfilter(sys::StateSpace)
Use together with [`sysfilter!`](@ref)
"""
function init_sysfilter(sys::StateSpace)
 	zeros(sys.nx)
end

"""
	output = sysfilter!(s::SysFilter, input)
	output = sysfilter!(state, sys::StateSpace, input)
Returns the filtered output `y` in `y = Cx+Du, x'=Ax+Bu`

This function is used to implement control loops where a signal is filtered through a
dynamical system, i.e., `U(z) = C(z)E(z)`. Initialize `state` using [`init_sysfilter`](@ref).
"""
function sysfilter!(state::AbstractVector, sys::StateSpace, input)
	state .= vec(sys.A*state + sys.B*input)
	output = vec(sys.C*state + sys.D*input)
end

sysfilter!(s::SysFilter, input) = sysfilter!(s.state, s.sys, input)
