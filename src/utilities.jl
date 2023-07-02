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
		@assert !ControlSystemsBase.iscontinuous(sys) "Can not filter using continuous time model."
		@assert length(state) == sys.nx "length(state) != sys.nx"
		new{typeof(sys)}(sys, state)
	end
	function SysFilter(sys::StateSpace)
		@assert !ControlSystemsBase.iscontinuous(sys) "Can not filter using continuous time model. Supply sample time."
		new{typeof(sys)}(sys, init_sysfilter(sys))
	end
	function SysFilter(sys::StateSpace, h::Real)
		@assert ControlSystemsBase.iscontinuous(sys) "Sample time supplied byt system model is already in discrete time."
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


"""
    f_discrete = rk4(f, Ts; supersample = 1)

Discretize `f` using RK4 with sample time `Ts`. See also [`MPCIntegrator`](@ref) for more advanced integration possibilities. More details are available at https://help.juliahub.com/juliasimcontrol/stable/mpc_details/#Discretization
"""
function rk4(f::F, Ts0; supersample::Integer = 1) where {F}
    supersample ≥ 1 || throw(ArgumentError("supersample must be positive."))
    # Runge-Kutta 4 method
    Ts = Ts0 / supersample # to preserve type stability in case Ts0 is an integer
    let Ts = Ts
        function (x, u, p, t)
            T = typeof(x)
            f1 = f(x, u, p, t)
            f2 = f(x + Ts / 2 * f1, u, p, t + Ts / 2)
            f3 = f(x + Ts / 2 * f2, u, p, t + Ts / 2)
            f4 = f(x + Ts * f3, u, p, t + Ts)
            add = Ts / 6 * (f1 + 2 * f2 + 2 * f3 + f4)
            # This gymnastics with changing the name to y is to ensure type stability when x + add is not the same type as x. The compiler is smart enough to figure out the type of y
            y = x + add
            for i in 2:supersample
                f1 = f(y, u, p, t)
                f2 = f(y + Ts / 2 * f1, u, p, t + Ts / 2)
                f3 = f(y + Ts / 2 * f2, u, p, t + Ts / 2)
                f4 = f(y + Ts * f3, u, p, t + Ts)
                add = Ts / 6 * (f1 + 2 * f2 + 2 * f3 + f4)
                y += add
            end
            return y
        end
    end
end


function show_measurements(fun, p; Tf = 3600)
    data = Vector{Float64}[]
    Ts = sampletime(p)
    N = round(Int, Tf/Ts)
    try
        for i = 1:N
            @periodically_yielding Ts begin
                y = measure(p)
                push!(data, y)
                fun(data)
            end
        end
	catch e
		@info e
    finally
        @info "Going to the pub"
    end
    data
end


function collect_data(p; Tf = 10)
    data = Vector{Float64}[]
    Ts = sampletime(p)
    N = round(Int, Tf/Ts)
	sizehint!(data, N)
	GC.enable(false); GC.gc()
	t_start = time()
    try
        for i = 1:N
            @periodically Ts begin
                y = measure(p)
				t = time() - t_start
                push!(data, [t; y])
            end
        end
	catch e
		@info e
    finally
		GC.enable(true); GC.gc()
        @info "Going to the pub"
    end
    data
end
