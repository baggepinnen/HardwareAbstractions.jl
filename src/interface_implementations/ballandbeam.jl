# Interface implementation Ball And Beam ====================================================

# The ball and beam can be used in two modes, either just the Beam, in which case there is a
# single output (measurement signal) or the BallAndBeam, in which case there are two.
# There are a few union types defined for convenience, these are
# AbstractBeam = Union{Beam, BeamSimulator}
# AbstractBallAndBeam   = Union{BallAndBeam, BallAndBeamSimulator}
# AbstractBeamOrBallAndBeam = All types
# Although not Abstract per se, the names AbstractBeam etc. were chosen since this reflects
# their usage in dispatch.

export Beam, BeamSimulator, AbstractBeam, BallAndBeam, BallAndBeamSimulator, AbstractBeamOrBallAndBeam

# @with_kw allows specification of default values for fields. If none is given, this value must be supplied by the user. replaces many constructors that would otherwise only supply default values.
# Call constructor like Beam(bias=1.0) if you want a non-default value for bias
"""
    Beam(;kwargs...)
Physical beam process

#Arguments (fields)
- `h::Float64 = 0.01`
- `bias::Float64 = 0.0`
- `stream::LabStream = ComediStream()`
- `measure::AnalogInput10V = AnalogInput10V(0)`
- `control::AnalogOutput10V = AnalogOutput10V(1)`
"""
struct Beam <: PhysicalProcess
    h::Float64
    bias::Float64
    stream::LabStream
    measure::AnalogInput10V
    control::AnalogOutput10V
end
function Beam(;
    h::Float64               = 0.01,
    bias::Float64            = 0.,
    stream::LabStream        = ComediStream(),
    measure::AnalogInput10V  = AnalogInput10V(0),
    control::AnalogOutput10V = AnalogOutput10V(1))
    p = Beam(Float64(h),Float64(bias),stream,measure,control)
    init_devices!(p.stream, p.measure, p.control)
    p
end

include("define_beam_system.jl")
const beam_system, nice_beam_controller = define_beam_system()
# nice_beam_controller gives ϕₘ=56°, Aₘ=4, Mₛ = 1.6. Don't forget to discretize it before use
struct BeamSimulator <: SimulatedProcess
    h::Float64
    s::SysFilter
    BeamSimulator(;h::Real = 0.01, bias=0) = new(Float64(h), SysFilter(beam_system, h))
end

struct BallAndBeam <: PhysicalProcess
    h::Float64
    bias::Float64
    stream::LabStream
    measure1::AnalogInput10V
    measure2::AnalogInput10V
    control::AnalogOutput10V
end
function BallAndBeam(;
    h                        = 0.01,
    bias                     = 0.,
    stream                   = ComediStream(),
    measure1::AnalogInput10V = AnalogInput10V(0),
    measure2::AnalogInput10V = AnalogInput10V(1),
    control::AnalogOutput10V = AnalogOutput10V(1))
    p = BallAndBeam(h,bias,stream,measure1,measure2,control)
    init_devices!(p.stream, p.measure1, p.measure2, p.control)
    p
end

struct BallAndBeamSimulator <: SimulatedProcess
    h::Float64
    s::SysFilter
end

const AbstractBeam              = Union{Beam, BeamSimulator}
const AbstractBallAndBeam       = Union{BallAndBeam, BallAndBeamSimulator}
const AbstractBeamOrBallAndBeam = Union{AbstractBeam, AbstractBallAndBeam}

num_outputs(p::AbstractBeam)             = 1
num_outputs(p::AbstractBallAndBeam)      = 2
num_inputs(p::AbstractBeamOrBallAndBeam) = 1
outputrange(p::AbstractBeam)             = [(-10,10)]
outputrange(p::AbstractBallAndBeam)      = [(-10,10),(-1,1)] # Beam angle, Ball position
inputrange(p::AbstractBeamOrBallAndBeam) = [(-10,10)]
isstable(p::AbstractBeam)                = true
isstable(p::AbstractBallAndBeam)         = false
isasstable(p::AbstractBeamOrBallAndBeam) = false
sampletime(p::AbstractBeamOrBallAndBeam) = p.h
bias(p::AbstractBeamOrBallAndBeam)       = p.bias
bias(p::BeamSimulator)                   = 0
bias(p::BallAndBeamSimulator)            = 0

function control(p::AbstractBeamOrBallAndBeam, u::AbstractArray)
    length(u) == 1 || error("Process $(typeof(p)) only accepts one control signal, tried to send u=$u.")
    control(p,u[1])
end
control(p::AbstractBeamOrBallAndBeam, u::Number) = send(p.control,u)
control(p::BeamSimulator, u::Number)             = p.s(u)
control(p::BallAndBeamSimulator, u::Number)      = error("Not yet implemented")

measure(p::Beam)                         = read(p.measure)
measure(p::BallAndBeam)                  = [read(p.measure1), read(p.measure2)]
measure(p::BeamSimulator)                = dot(p.s.sys.C,p.s.state)
measure(p::BallAndBeamSimulator)         = error("Not yet implemented")


initialize(p::Beam)                    = nothing
initialize(p::BallAndBeam)             = nothing
finalize(p::AbstractBeamOrBallAndBeam) = foreach(close, p.stream.devices)
initialize(p::BallAndBeamSimulator)    = nothing
finalize(p::BallAndBeamSimulator)      = nothing
initialize(p::BeamSimulator)           = p.s.state .*= 0
finalize(p::BeamSimulator)             = nothing
