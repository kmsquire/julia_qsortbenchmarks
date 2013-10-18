motivation
=====================

This is a cursory report regarding [issue #939](https://github.com/JuliaLang/julia/issues/939?source=cc). For primitive datatypes, Julia invokes Quicksort, so the general purpose here is to increase the performance of the standard library implementation of Quicksort. While looking at Julia's current implementation of Quicksort, several issues became apparent:

- Each pivot element is not guaranteed to be placed in its proper position in the array after each pass
 - the algorithm may have to look at more elements than are necessary
- The algorithm fails to complete without the insertion sort optimization, on an array out-of-bounds exception
 - this isn't necessarily a big issue since insertion sort is invoked for small arrays in the standard library implementation

As a quick example, let's look at Julia's pure Quicksort on array ```[4, 10, 11, 24, 9]```, without the insertion sort optimization ```hi-lo <= SMALL_THRESHOLD && return isort(v, lo, hi)```, and without the ```@inbounds``` macro.

The pivot on the first pass is ```11```, determined by ```p = (lo+hi)>>>1```. However after the first pass, the array becomes ```[4, 10, 9, 24, 11]```. If we let the algorithm try to run to completion, the following error is raised ```ERROR: BoundsError()``` on the ```j``` index crawl ```while isless(pivot, v[j]); j -= 1; end```.

potential improvements (?)
=====================

Improvements are proposed with four permutations of Quicksort, outlined in qsortbenchmarks.jl. 

- The canonical Quicksort algorithm that places the pivot in its natural position after each pass. The pivot is chosen as the first element in each subarray
- Canonical, and performs a random shuffle of the array before the initial sort (Fisher-Yates)
- Canonical, but uses a median of three sampled values (indexes lo, (hi+lo)>>>1, hi) as the pivot
- Canonical with both a median of three pivot, and a random shuffle

Some low-hanging fruit optimizations were made to the canonical example, specifically the ```@inbounds``` macro which speeds up array access (~2x boost in performance), and the lack of bounds checking on the ```j``` index scan. 

Naive benchmarking shows an improvement across the board over Julia's current Quicksort. For 10^4 samples of 10^5-element random integer arrays, we get

<h4>Canonical</h4>
median ratio:    0.9472264672429314
mean ratio:      0.9567886986692108

<h4>Canonical with a Median-of-3 Pivot</h4>
median ratio:    0.946288018554921
mean ratio:      0.946846763463826

<h4>Canonical with a Fisher-Yates Shuffle</h4>
median ratio:    0.9361481758190309
mean ratio:      0.9414140779695601

<h4>Canonical with a Median-of-3 Pivot & a Fisher-Yates Shuffle</h4>
median ratio:    0.9454136322577962
mean ratio:      0.9465552777308418