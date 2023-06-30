# Interface implementation Ball And Beam ====================================================

# There is a union type defined for convenience:
# AbstractETHHelicopter = Union{ETHHelicopter, ETHHelicopterSimulator}
# Although not Abstract per se, the names AbstractETHHelicopter etc. were chosen since this
# reflects the usage in dispatch.

export ETHHelicopter, ETHHelicopterSimulator, AbstractETHHelicopter

# @with_kw allows specification of default values for fields. If none is given, this value must be supplied by the user. replaces many constructors that would otherwise only supply default values.
# Call constructor like ETHHelicopter(bias=1.0) if you want a non-default value for bias
"""
    ETHHelicopter(;kwargs...)
    Physical ETH helicopter process
# Arguments (fields)
- `h::Float64 = 0.05`
- `bias::Float64 = 0.0`
- `stream::LabStream = ComediStream()`
- `measure1::AnalogInput10V = AnalogInput10V(0)`
- `measure2::AnalogInput10V = AnalogInput10V(1)`
- `control1::AnalogOutput10V = AnalogOutput10V(0)`
- `control2::AnalogOutput10V = AnalogOutput10V(1)`
"""
@with_kw struct ETHHelicopter <: PhysicalProcess
    h::Float64
    bias::Float64
    stream::LabStream
    measure1::AnalogInput10V
    measure2::AnalogInput10V
    control1::AnalogOutput10V
    control2::AnalogOutput10V
end
function ETHHelicopter(;
    h                         = 0.05,
    bias                      = 0.,
    stream                    = ComediStream(),
    measure1::AnalogInput10V  = AnalogInput10V(0),
    measure2::AnalogInput10V  = AnalogInput10V(1),
    control1::AnalogOutput10V = AnalogOutput10V(0),
    control2::AnalogOutput10V = AnalogOutput10V(1))
    p = ETHHelicopter(h,bias,stream,measure1,measure2,control1,control2)
    init_devices!(p.stream, p.measure1, p.measure2, p.control1, p.control2)
    p
end


struct ETHHelicopterSimulator <: SimulatedProcess
    h::Float64
    bias::Float64
    state::Vector{Float64}
end
ETHHelicopterSimulator() = ETHHelicopterSimulator(0.01, zeros(4))

const AbstractETHHelicopter = Union{ETHHelicopter, ETHHelicopterSimulator}
num_outputs(p::AbstractETHHelicopter) = 2
num_inputs(p::AbstractETHHelicopter)  = 2
outputrange(p::AbstractETHHelicopter) = [(-10,10),(-10,10)]
inputrange(p::AbstractETHHelicopter)  = [(-10,10),(-10,10)]
isstable(p::AbstractETHHelicopter)    = false
isasstable(p::AbstractETHHelicopter)  = false
sampletime(p::AbstractETHHelicopter)  = p.h
bias(p::AbstractETHHelicopter)        = p.bias


function control(p::ETHHelicopter, u)
    send(p.control1,u[1])
    send(p.control2,u[2])
end

measure(p::ETHHelicopter) = [read(p.measure1), read(p.measure2)]
control(p::ETHHelicopterSimulator, u)  = error("Not yet implemented")
measure(p::ETHHelicopterSimulator)     = error("Not yet implemented")


initialize(p::ETHHelicopter)          = nothing
finalize(p::ETHHelicopter)            = foreach(close, p.stream.devices)
initialize(p::ETHHelicopterSimulator) = nothing
finalize(p::ETHHelicopterSimulator)   = nothing
