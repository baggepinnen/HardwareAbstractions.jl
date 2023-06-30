using HardwareAbstractions, ControlSystemsBase, DSP
using Test

# Reference generators
r = PRBSGenerator(Int(4))
seq = [r() for i = 1:10]
@test all(seq .==  [1,0,1,0,0,0,0,0,0,0])
foreach(r,1:10_000)

function test_sysfilter()
	N     = 10
	u     = randn(N)
	b     = [1, 1]
	a     = [1, 0.1, 1]
	sys   = ss(tf(b,a,1))
	state = init_sysfilter(sys)
	yf    = filt(b,a,u)
	yff   = similar(yf)
	for i in eachindex(u)
		yff[i] = sysfilter!(state, sys, u[i])[1]
	end
	@test sum(abs,yf - yff) < √(eps())
	sysfilt = SysFilter(sys)
	for i in eachindex(u)
		yff[i] = sysfilter!(sysfilt, u[i])[1]
	end
	@test sum(abs,yf - yff) < √(eps())
	sysfilt = SysFilter(sys)
	for i in eachindex(u)
		yff[i] = sysfilt(u[i])[1]
	end
	@test sum(abs,yf - yff) < √(eps())
end

test_sysfilter()
