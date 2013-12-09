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

# fisher-yates shuffle
function fyshuffle(v)
    @inbounds begin
        N = length(v);
        for i = length(v):0
            j = rand(1:N-1);
            v[i], v[j] = v[j], v[i];
            N -= 1;
        end
    end
    return v;
end

# canonical quicksort + fisher-yates shuffle
function qsort_c_fy!(v, lo=1, hi=length(v))
    fyshuffle(v)
    qsort_c!(v)
end

# ibid + median of 3 pivot
function qsort_c_fy_mp!(v, lo=1, hi=length(v))
    fyshuffle(v)
    qsort_c_mp!(v)
end

# median of 3 pivot
function qsort_c_mp!(v, lo=1, hi=length(v))
    @inbounds while lo < hi
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
        lo = j+1
    end
    return v;
end

# random pivot
function qsort_c_rp!(v, lo=1, hi=length(v))
    @inbounds while lo < hi
        hi-lo <= SMALL_THRESHOLD && return isort(v, lo, hi)
        i, j = lo, hi+1;
        rp = rand(lo:hi)
        v[lo], v[rp] = v[rp], v[lo]
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
        lo = j+1
    end
    return v;
end

# canonical, @inbounds macro
function qsort_c!(v, lo=1, hi=length(v))        
    @inbounds while lo < hi
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
        lo = j+1
    end
    return v;
end

# 3way quicksort
function qsort_3way!(v, lo=1, hi=length(v))
    @inbounds while lo < hi
        hi-lo <= SMALL_THRESHOLD && return isort(v, lo, hi)
        lt = lo; gt = hi; i = lo;
        piv = v[lo];
        while i <= gt
            elem = v[i];
            if isless(elem, piv)
                v[i], v[lt] = v[lt], v[i];
                lt+=1; i+=1;
            elseif isless(piv, elem)
                v[i], v[gt] = v[gt], v[i];
                gt-=1;
            else i+=1; end
        end
        qsort_3way!(v, lo, lt-1)
        lo = gt+1
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
