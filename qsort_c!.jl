require("isort.jl")

function qsort_c!(v, lo=1, hi=length(v))        
    @inbounds begin
        hi <= lo && return;
        hi-lo <= 20 && return isort(v, lo, hi)
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
        qsort_c!(v, lo, j-1);
        qsort_c!(v, j+1, hi);
        return v;
    end
end
