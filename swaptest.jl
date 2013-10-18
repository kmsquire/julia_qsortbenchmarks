function canswap(a)

    for i = 1:arraylength - 1
        temp = a[i];
        a[i] = a[i+1];
        a[i+1] = temp;
    end

end

function jswap(v)
    for i = 1:arraylength - 1
        v[i], v[i+1] = v[i+1], v[i];
    end
end

arraylength = 10^4
a = rand(Int8, 1, arraylength)
b = rand(Int8, 1, arraylength)

canswap(a)
jswap(b)

numsims = 10^6

ctimes = Array(Float64, numsims)
jtimes = Array(Float64, numsims)

for i = 1:numsims

    tic()
    canswap(a)
    ctimes[i] = toq()

    tic()
    jswap(b)
    jtimes[i] = toq()

end

@show(median(ctimes./jtimes))
@show(mean(ctimes./jtimes))
