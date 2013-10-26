const SMALL_THRESHOLD = 20

# insertion sort
function isort(v, lo=1, hi=length(v))
    @inbounds for i = lo+1:hi
        j = i
        x = v[i]
        while j > lo
            if isless(x, v[j-1])
                v[j] = v[j-1]
                j -= 1
                continue
            end
            break
        end
        v[j] = x
    end
    return v;
end

# julia's current implementation as of v0.2
function qsort_stdlib!(v, lo=1, hi=length(v))    
    @inbounds while lo < hi
        hi-lo <= SMALL_THRESHOLD && return isort(v, lo, hi)
        pivot = v[(lo+hi)>>>1]
        i, j = lo, hi
        while true;
            while isless(v[i], pivot); i += 1; end
            while isless(pivot, v[j]); j -= 1; end
            i <= j || break;
            v[i], v[j] = v[j], v[i]
            i += 1; j -= 1;
        end
        lo < j && qsort_stdlib!(v, lo, j)
        lo = i
    end
    return v;
end

# julia's current implementation as of v0.2, checks the bounds
function qsort_stdlib_CHECKBOUNDS!(v, lo=1, hi=length(v))    
    while lo < hi
        hi-lo <= SMALL_THRESHOLD && return isort(v, lo, hi)
        pivot = v[(lo+hi)>>>1]
        i, j = lo, hi
        while true;
            while isless(v[i], pivot); i += 1; end
            while isless(pivot, v[j]); j -= 1; end
            i <= j || break;
            v[i], v[j] = v[j], v[i]
            i += 1; j -= 1;
        end
        lo < j && qsort_stdlib!(v, lo, j)
        lo = i
    end
    return v;
end


# canonical
function qsort_c!(v, lo=1, hi=length(v))
    @inbounds begin
        hi <= lo && return;
        hi-lo <= SMALL_THRESHOLD && return isort(v, lo, hi)
        i, j = lo, hi+1;
        pivot = v[lo]
        while true;
            i += 1;
            while isless(v[i], pivot);
                i == hi && break;
                i += 1;
            end
            j -= 1;
            while isless(pivot, v[j]);
                j -= 1;                
            end 
            i >= j && break;
            v[i], v[j] = v[j], v[i]
        end
        v[lo], v[j] = v[j], v[lo]
        qsort_c!(v, lo, j-1);
        qsort_c!(v, j+1, hi);
    end
    return v;
end

# canonical, checks the bounds
function qsort_c_CHECKBOUNDS!(v, lo=1, hi=length(v))
    hi <= lo && return;
    hi-lo <= SMALL_THRESHOLD && return isort(v, lo, hi)
    i, j = lo, hi+1;
    pivot = v[lo]
    while true;
        i += 1;
        while isless(v[i], pivot);
            i == hi && break;
            i += 1;
        end
        j -= 1;
        while isless(pivot, v[j]);
            j -= 1;                
        end 
        i >= j && break;
        v[i], v[j] = v[j], v[i]
    end
    v[lo], v[j] = v[j], v[lo]
    qsort_c!(v, lo, j-1);
    qsort_c!(v, j+1, hi);
    return v;
end

# -------- Compile before running benchmarks ------------ #

a = 10^4
b = rand(Int64, 1, a)
c = copy(b)
d = copy(b)
e = copy(b)

qsort_stdlib!(b, 1, a)
qsort_stdlib_CHECKBOUNDS!(c, 1, a)
qsort_c!(d, 1, a)
qsort_c_CHECKBOUNDS!(e, 1, a)

tic()
toq()

# ------------------------------------------------------- #
# ------------------- Benchmarking ---------------------- #
# ------------------------------------------------------- #

numsims = 10^5
qs_stdlib_times = Array(Float64, numsims)
qs_stdlib_CHECKBOUNDS_times = Array(Float64, numsims)
qs_c_times = Array(Float64, numsims)
qs_c_CHECKBOUNDS_times = Array(Float64, numsims)

for i = 1:numsims

    b = rand(Int64, 1, a)
    c = copy(b)
    d = copy(b)
    e = copy(b)

    tic()
    qsort_stdlib!(b)
    qs_stdlib_times[i] = toq()

    tic()
    qsort_stdlib_CHECKBOUNDS!(c)
    qs_stdlib_CHECKBOUNDS_times[i] = toq()


    tic()
    qsort_c!(d)
    qs_c_times[i] = toq()

    tic()
    qsort_c_CHECKBOUNDS!(e)
    qs_c_CHECKBOUNDS_times[i] = toq()
    
    @assert issorted(b)
    @assert issorted(c)
    @assert issorted(d)
    @assert issorted(e)
    
end

@show(median(qs_c_times./qs_stdlib_times))
@show(mean(qs_c_times./qs_stdlib_times))

@show(median(qs_c_CHECKBOUNDS_times./qs_stdlib_CHECKBOUNDS_times))
@show(mean(qs_c_CHECKBOUNDS_times./qs_stdlib_CHECKBOUNDS_times))

@show(median(qs_c_CHECKBOUNDS_times./qs_c_times))
@show(mean(qs_c_CHECKBOUNDS_times./qs_c_times))

@show(median(qs_stdlib_CHECKBOUNDS_times./qs_stdlib_times))
@show(mean(qs_stdlib_CHECKBOUNDS_times./qs_stdlib_times))
