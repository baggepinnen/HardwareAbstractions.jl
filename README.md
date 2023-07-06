# HardwareAbstractions

**Work in progress**

An interface to communicate with hardware devices for the purposes of automatic control. This package does not do much itself other than defining the interface for other packages to implement.

The interface is defined by [`interface.jl`](https://github.com/baggepinnen/HardwareAbstractions.jl/blob/main/src/interface.jl)


## Utilities
The package also contains some utilities for working with hardware devices and control loops, such as 
- `@periodically`: Ensures that the body is run with an interval of `h >= 0.001` seconds.
- `SysFilter`: Returns an object used for filtering signals through LTI systems.
- `rk4`: A Runge-Kutta 4 integrator.
