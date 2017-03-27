{{TITLE}}

Variables in Sporth are a wonderful solution to mitigate 
hard to follow stack operations. 

Consider this Sporth patch, where the metronome signal is being split
and fed into a trand and tenvx:

    10 metro dup
    300 1000 trand 
    swap 0.001 0.005 0.001 tenvx 
    swap 0.3 sine *

It's not terribly complicated yet, but if this patch were to grow, and the clock
source were needed by more ugens, things could become harder to follow.

With variables, the same patch could be realized in the following way:

    _clk var
    10 metro _clk set
    _clk get 300 1000 trand 
    _clk get 0.001 0.005 0.001 tenvx 
    swap 0.3 sine * 

In this patch, the variable called "clk" is declared in the first line with:

    _clk var

The metronome signal is set to the variable using "set" in the following line:
    
    10 metro _clk set

With the variable set, the value inside the variable accessed using "get",
as seen in the two lines following:

    _clk get 300 1000 trand 
    _clk get 0.001 0.005 0.001 tenvx 

With this patch, it is much clearer to see what is being fed into trand and
tenvx. 

{{FOOTER}}

