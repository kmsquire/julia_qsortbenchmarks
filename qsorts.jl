SMALL_THRESHOLD = 20
SMALL_THRESHOLD_STDLIB = 20

# insertion sort
function isort(v, lo=1, hi=length(v))
    for i = lo+1:hi
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
end

# returns median of three values in array v
function getmedpiv(v, a, b, c)
    if isless(v[a], v[b])
        if isless(v[b], v[c])
            return b
        elseif isless(v[a], v[c])
            return c
        else
            return a
        end
    else
        if isless(v[c], v[b])
            return b
        elseif isless(v[c], v[a])
            return c
        else
            return a
        end
    end
end

# fisher-yates random shuffle
function fyshuffle(v)
    N = length(v);
    for i = length(v):0
        j = rand(1:N-1);
        v[i], v[j] = v[j], v[i];
        N -= 1;
    end
end

# canonical quicksort + fisher-yates shuffle
function qsort_c_fy!(v, lo=1, hi=length(v))
    fyshuffle(v)
    qsort_c!(v)
end

# canonical quicksort + fisher-yates shuffle + median of 3 pivot
function qsort_c_fy_mp!(v, lo=1, hi=length(v))
    fyshuffle(v)
    qsort_c_mp!(v)
end

# canonical quicksort + median of 3 pivot
function qsort_c_mp!(v, lo=1, hi=length(v))
    hi <= lo && return;
    hi-lo <= SMALL_THRESHOLD && return isort(v, lo, hi)
    mi = (lo+hi)>>>1
    if v[lo] > v[mi]
        v[lo], v[mi] = v[mi], v[lo];
    end
    if v[lo] > v[hi] 
        v[lo], v[hi] = v[hi], v[lo];
    end
    if v[mi] > v[hi]
        v[mi], v[hi] = v[hi], v[mi];
    end
    v[mi], v[lo] = v[lo], v[mi]
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
        v[i], v[j] = v[j], v[i];
    end
    v[j], v[lo] = v[lo], v[j];
    qsort_c_mp!(v, lo, j-1);
    qsort_c_mp!(v, j+1, hi);
    return v;
end

# canonical quicksort
function qsort_c!(v, lo=1, hi=length(v))        
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
        v[j], v[i] = v[i], v[j];
    end
    v[j], v[lo] = v[lo], v[j];
    qsort_c_mp!(v, lo, j-1);
    qsort_c_mp!(v, j+1, hi);
    return v;
end

# quicksort as written for the standard library
function qsort_stdlib!(v, lo=1, hi=length(v))
    while lo < hi
        hi-lo <= SMALL_THRESHOLD_STDLIB && return isort(v, lo, hi)
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

# ------------------------------------------------------- #
# ------------------- Benchmarking ---------------------- #
# ------------------------------------------------------- #

bmark_algo = qsort_c!

a = 10^5
b = rand(Int64, 1, a)
c = copy(b)

# -------- Compile before running benchmarks ------------ #

qsort_stdlib!(c, 1, a)
bmark_algo(b, 1, a)

b = rand(Int64, 1, a)
c = copy(b)

tic()
toq()

# ------------------- Benchmarking --------------------- #

numsims = 10^4

# arrays to store the sorting times

qs_stdlib_times = Array(Float64, numsims)
qs_test_times = Array(Float64, numsims)

@inbounds for i = 1:numsims
    
    b = rand(Int64, 1, a)
    c = copy(b)

    tic()
    qsort_stdlib!(c, 1, a)
    qs_stdlib_times[i] = toq()

    tic()
    bmark_algo(b, 1, a)
    qs_test_times[i] = toq()

    @assert issorted(c)
    @assert issorted(b)

end
@show(median(qs_test_times))
@show(median(qs_test_times./qs_stdlib_times))
@show(mean(qs_test_times./qs_stdlib_times))
