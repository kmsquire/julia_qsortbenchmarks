motivation
=====================
I started looking at Julia's Quicksort after finding [issue #939](https://github.com/JuliaLang/julia/issues/939?source=cc). The issue concerns the performance of ```sort!()```. For primitive datatypes, Julia invokes Quicksort, so the general purpose here is to increase the performance of the standard library implementation of Quicksort. 

current implementation issues
=====================

While looking at Julia's current implementation of Quicksort, several issues became apparent:

- Each pivot element is not guaranteed to be placed in its proper position in the array after each pass
 - the algorithm may have to look at more elements than are necessary
- The algorithm fails to complete without the insertion sort optimization. The ```j``` scan runs out of bounds when scanning small arrays
 - this isn't necessarily a huge issue since insertion sort is invoked for these small arrays 

As a quick example, let's look at Julia's pure Quicksort on array ```[4, 10, 11, 24, 9]```, without the insertion sort optimization ```hi-lo <= SMALL_THRESHOLD && return isort(v, lo, hi)```, and without the ```@inbounds``` macro.

The value of the pivot index on the first pass is ```11```, determined by ```p = (lo+hi)>>>1```. However after the first pass, the array becomes ```[4, 10, 9, 24, 11]```. If we let the algorithm try to run to completion, the following error is raised ```ERROR: BoundsError()``` on the ```j``` index crawl ```while isless(pivot, v[j]); j -= 1; end```.

potential improvements
=====================

Improvements are proposed with four permutations of Quicksort, outlined in qsorts.jl. 

- The canonical Quicksort algorithm that places the pivot in its natural position after each pass. The pivot is chosen as the first element in each subarray
- Canonical, and performs a random shuffle (Fisher-Yates) of the array before the initial sort 
- Canonical, but uses a median of three sampled values (indexes lo, (hi+lo)>>>1, hi) as the pivot
- Canonical with both a median of three pivot, and the random shuffle

Some low-hanging fruit optimizations were made to the canonical example, specifically the ```@inbounds``` macro which speeds up array access (~2x boost in performance), and the lack of bounds checking on the ```j``` index scan. 

Naive benchmarking shows a speed and memory footprint improvement across the board over Julia's current Quicksort <strong>when all algorithms lack the ```@inbounds```</strong> macro. For each sample, we create an array of random integers, copy the array for each implementation, and time each implementation. The results are then normalized to the standard libary's sort time. This method on 10^4 samples of 10^5-element random integer arrays produces

<h5>All algorithms without ```@inbounds``` macro</h5>
<table>
    <thead>
        <tr>
	    <th></th>
	    <th>Mean Ratio</th>
	    <th>Median Ratio</th>
	</tr>
    </thead>
    <tbody>
        <tr>
	   <td>Canonical</td>
	   <td>0.9178107</td>
	   <td>0.9103574</td>
	</tr>
        <tr>
	   <td>Median-of-3 Pivot</td>
	   <td>0.9475761</td>
	   <td>0.9358107</td>
	</tr>
        <tr>
	   <td>Random Shuffle</td>
	   <td>0.9215353</td>
	   <td>0.9102481</td>
	</tr>
        <tr>
	   <td>Combo</td>
	   <td>0.9467139</td>
	   <td>0.9331511</td>
	</tr>
    </tbody>
</table>

<h5>Comparisons when including the ```@inbounds``` macro</h5>

When all algorithms have ```@inbounds```, there is not an apparent speed improvement over the current algorithm for large random integer arrays. The following are results for the median of three pivot quicksort benchmarked against the standard library implementation, with 10^4 simulations, when both have the ```@inbounds``` macro.

<table>
<tr>
<th>Array Size</th><th>Mean Ratio</th><th>Median Ratio</th>
</tr>
<tr><td>10^3</td><td>0.999</td><td>0.998</td></tr>
<tr><td>10^4</td><td>1.011</td><td>1.016</td></tr>
<tr><td>10^5</td><td>1.011</td><td>1.018</td></tr>
</table>

Any comments would be greatly appreciated. It would also be great to add different array permutations (sorted, semi-sorted) to the comparisons.