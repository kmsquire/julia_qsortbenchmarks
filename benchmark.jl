require("qsorts.jl")

# ------------------------------------------------------- #
# ------------------- Benchmarking ---------------------- #
# ------------------------------------------------------- #

a = 10^3
b = rand(Int64, 1, a)
c = copy(b)
d = copy(b)
e = copy(b)

# -------- Compile before running benchmarks ------------ #

qsort_stdlib!(c, 1, a)
qsort_c!(b, 1, a)
qsort_c_bc!(d, 1, a)

tic()
toq()

# ------------------- Benchmarking --------------------- #

function getarray(arraytype, length)
    a = rand(Int64, 1, length)
    arraytype == "random" && return a;
    arraytype == "sorted" && return qsort_c!(a)
    sample = log(length) - 2
    for i=1:length 
        if i % 4*10^sample == 0 && (i + 10^sample) < length
            a = qsort_c!(a, i, i + 10^sample)
        end
    end
    return a;
end

# eventually to change around the pivot
for pivsize = [20]

    for arraysize in [10^2, 10^3, 10^4, 10^5]

        numsims = 10^4
        qs_stdlib_times = Array(Float64, numsims)
        qs_c_times = Array(Float64, numsims)
        qs_c_bc_times = Array(Float64, numsims)

        for i = 1:numsims

            b = getarray("random", arraysize)
            c = copy(b)
            d = copy(b)

            tic()
            qsort_c!(b)
            qs_c_times[i] = toq()

            tic()
            qsort_c_bc!(d)
            qs_c_bc_times[i] = toq()
            
            tic()
            qsort_stdlib!(c)
            qs_stdlib_times[i] = toq()

            @assert issorted(c)
            @assert issorted(b)
            @assert issorted(d)

        end

        print("-------------")
        print(arraysize)
        println("-------------")

        @show(median(qs_c_bc_times./qs_c_times))
        @show(mean(qs_c_bc_times./qs_c_times))

        @show(median(qs_c_times./qs_stdlib_times))
        @show(mean(qs_c_times./qs_stdlib_times))

        @show(median(qs_c_bc_times./qs_stdlib_times))
        @show(mean(qs_c_bc_times./qs_stdlib_times))

    end
end
