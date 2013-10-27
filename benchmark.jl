require("qsorts.jl")

# -------- Compile before running benchmarks ------------ #

a = 10^3
b = rand(Int64, 1, a)
c = copy(b)

qsort_stdlib!(b, 1, a)
qsort_c_mp!(c, 1, a)

tic()
toq()

# ------------------------------------------------------- #
# ------------------- Benchmarking ---------------------- #
# ------------------------------------------------------- #

numsims = 10^4
qs_stdlib_times = Array(Float64, numsims)
qs_c_times = Array(Float64, numsims)

for i = 1:numsims

    b = rand(Int64, 1, a)
    c = copy(b)

    tic()
    qsort_stdlib!(b)
    qs_stdlib_times[i] = toq()

    tic()
    qsort_c_mp!(c)
    qs_c_times[i] = toq()
    
    @assert issorted(b)
    @assert issorted(c)

end

@show(median(qs_c_times./qs_stdlib_times))
@show(mean(qs_c_times./qs_stdlib_times))
