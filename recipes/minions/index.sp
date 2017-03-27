##: # the minions are coming tho

##: This [sporthling](/sporthlings/003) leverages the ability to use 
##: tables as sequencers and patterns in Sporth. There are a two melodic
##: "themes" played layered along side some white noise bursts.

##: ## Variables and Tables

##: Before anything is started, the variables and tables are declared. 
##: 
##: - A variable called *clk* is used to store clock data. 
##: - A table called *seq* stores MIDI note numbers. for the main melodic 
##: sequence.  
##: - A variable called *nt* is used to store a midi note value. Here it is
##: being set to midi note number 55.

##---
_clk var
_seq "74 72 70 69 67" gen_vals
_bs "43 41 39 38 43 45 46 48" gen_vals
_nt 55 varset
##---

##: ## The Clock
##: The clock used for all the timing elements in the patch are set using
##: **metro**, whose rate is randomly warped using **randi** and **randh**.
##: I use this drifting clock approach in patches mainly to break any "groove" 
##: that would occur. In breaking the groove, the piece becomes more fluid and
##: organic.
##---
0.5 10 (1 3 5 randh) randi metro _clk set 
##---

##: ## Lead 
##: The main element in this patch is this lead sound. It is a surprisingly
##: complex element comprised of two sound sources blended together. 
##: Each component of the lead sound has been broken into into sections.


##: ### Envelope 1

##: At the time of making this patch, **tseg** was a newly added soundpipe
##: module and sporth ugen that I wanted to build an intuition about. For this 
##: reason, all the envelopes generated in this patch were created using 
##: **tseg**. It is worth examining one of envelopes in detail.
##:
##: **tseg** is a trigger-based line generator, capable of generating lines 
##: with various kinds of slopes. These can range from convex exponential shapes 
##: to concave exponential shapes. 
##:

##: The first argument is a trigger signal, which will make **tseg** jump
##: to a given value.
##:
##---
_clk get 
##---

##: The value it jumps to is the second argument. An envelope jumps to either
##: 1 or 0. To generate this, the clock signal is duplicated and fed into
##: **tog**. 
##: 
##---
dup tog 
##---

##: The duration of **tseg** is the third argument. It is being fed with 
##: the triggerable random number generator **trand** driven by the clock 
##: signal. The range of time is between 5 and 500 milliseconds. 
##: 
##---
_clk get 0.005 0.5 trand 
##---

##: The fourth argument determines the curve of the line segment. This value
##: is being set between -10 and 5. Negative values will produce convex envelope
##: attacks, while positive values will produce concave envelope attacks. 
##: The larger the value, the steeper the curve in either direction.
##:
##---
_clk get -10 5 trand 
##---

##: Finally, tseg is called. The last and final parameter is the initial 
##: value for the line segment, which has been to 0. **tseg** produces a value
##: and pushes it onto the stack for later use.
##: 
##---
0 tseg 
##---


##: ### Square 
##: One of the timbres used is a bandlimited square wave. For starters,
##: it has a pitch of an 'E' above middle C (midi note number 74) and
##: an amplitude of 0.3
##---
74 mtof 0.3 
##---
##: The pulse width of the square wave is modulated with another envelope 
##: generator via **tseg**. As it turns out, this envelope generator is
##: identical to the envelope described above.
##---
_clk get 0.5 maytrig dup tog 
_clk get 0.005 0.5 trand 
_clk get -10 5 trand 
0 tseg 
##---
##: The output of **tseg** is in the range 0-1, and since 0 and 1 exactly
##: are out of range for **square**, it is rescaled to be between 0.1 and 0.5.
##---
0.1 0.5 scale
##---

##: **square** is called, and the value produced is pushed onto the stack. At
##: this point the stack contents are the envelope and the square.
##---
square
##---

##: ### FM
##: The second timbral contribution to the lead sound is a FM oscillator pair.
##: The frequency of this oscillator is set using a sequence built using
##: the *seq* table from before and **tseq**. Instead of using the clock signal
##: from before, the FM using a new clock signal generated using **metro**.
##---
4 metro 0.5 maytrig 0 _seq tseq 
##---

##: Oftentimes the jumps caused by the sequencer lead to undesirable clicks. 
##: the steps between the notes are smoothed via a portamento filter **port**, 
##: then fed into **mtof** to be converted into a frequency. 
##---
0.01 port mtof 
##---
##: The rest of the FM oscillator pair **fm** is fairly vanilla. It has an
##: amplitude of 0.4, with a 2:7 C:M ratio, and a modulation index of 5. This
##: particular C:M ratio is particularly bright with spread out harmonics. The
##: higher-than-usual modulation index adds to the brightness of the FM sound.
##---
0.4 2 7 5 fm 
##---
##: **fm** computes a sample and pushes that value onto the stack. Now there
##: is an envelope signal, a square signal, and an FM signal. 
##:
##: ### Blending
##: The square signal and FM signal generated in the previous two subsections
##: are to be blended together via a linear crossfade called **cf**. 
##: The position of the crossfade is determined via **randi**.
##---
0 0.8 1 randi cf
##---
##: To mellow things out, the lead is fed through a butterworth lowpass filter.
##: The cutoff frequency of the lowpass filter is determined via a **randi**
##: ugen in the range 700 to 1000, whose rate is 13 times a second.
##---
700 1000 (13 bpm2rate) randi butlp
##---

##: The envelope generated from before is multiplied with the lead signal.
##---
*
##---

##: ### Envelope 2
##: The signal generated above works, but there are now spaces or pauses. This
##: gets fatiguing to the ears very quickly. To add space, the signal is hit
##: with another envelope buit to add space. The amount influence this envelope 
##: has is modulated as well via another crossfade **cf**, crossing between
##: a steady signal of 1 and the signal itself. The crossfade first begins
##: with such a steady signal. It is just a value of 1.
##---
1 
##---
##: The second signal in the crossfade is the second envelope. A new metronome
##: **metro**, whose rate is randomly determined via **randh**, is fed into
##: a toggle signal **tog**. To smooth the transitions generated by **tog**,
##: it is fed into a portamento filter. 
##---
(30 50 1 randh metro tog 0.001 port) 

##---
##: The position randomly switches between the steady state signal and the
##: envelope with a signal created from a **metro**, a **maygate**, and 
##: a **portamento** to smooth things out.
##---
10 metro 0.4 maygate 0.003 port
##---

##: The crossfaded signal is produced and multiplied with the current signal.
##---
cf * 
##---

##: ### Feedback Delay 
##: Some feedback delay is added to the lead sound. The feedback amount is
##: set to 900 milliseconds, and the delay time is 1.1 seconds. It is attenuated
##: and added to the dry signal. This summed signal is also attenuated as well
##: to make room for the bass.
##---
dup 0.9 1.1 delay -6 ampdb *  + -6 ampdb * 
##---

##: ## Bass
##: The bass sound used is your run-of-the-mill supersaw subtractive bass. 
##: Nothing too unusual is happening here, but it still sounds great.

##: ### Sequencer
##: Yet another independent clock signal is generated for the bass sequencer,
##: this time using **dmetro** set to 90 beats per minute via **bpm2dur**
##---
90 bpm2dur dmetro 
##---
##: The trigger signal is fed into a trigger divider **tdiv**, which takes
##: the clock signal and only spits out a trigger every 4 ticks. 
##: This effectively turns a quarter note signal into a signal that ticks
##: once per measure in 4/4 time. 
##---
4 0 tdiv 
##---
##: This clock signal is made even more sparse when it is fed into a maytrig
##: with a 40% probability. **tick** is added onto this signal to ensure that
##: there is a starting note when the patch begins.
##---
0.8 maytrig tick + 
##---
##: The rest of tseq is outlined below. Tseq is set to mode 0, which means
##: move in sequential order.
##---
0 _bs tseq 
##---
##: To smooth the jumps between notes, a portamento filter **port** is used.
##---
0.01 port 
##---
##: The signal generated is to be used multiple times, so to save on stack 
##: operations, it is stored into the variable *nt*.
##---
_nt set
##---

##: ### Sawtooths
##: Using the sequencer signal generated above, three sawtooth oscillators 
##: are summed together. The two detuned oscillators are shifted one octave
##: below.
##---
_nt get mtof 0.1 saw 
_nt get 12.1 - mtof 0.2 saw 
_nt get 11.9 - mtof 0.1 saw + + 
##---

##: ### Filters
##: The output signal the bass is fed into a butterworth lowpass filter, whose
##: cutoff is being modulated via **rand**.

##---
300 900 0.2 randi butlp +
##---

##: ## White Noise
##: The final signal in this patch is a enveloped white noise burst. 
##: It is not too shocking that one of the elements is white noise.
##---
0.4 noise 
##---

##: The envelope signal has a clock signal generated via **metro**.
##---
15 metro 
##---
##: This clock signal is duplicated and fed into **tdiv** to output a tick 
##: every 4 ticks on the input. This signal is fed into a maygate, which is
##: used to effectively shut the noise on and off. 
##---
dup 4 0 tdiv 0.2 maygate * 
##---
##: **swap** is utilized to get the copy of the clock signal created. It is 
##: fed into a maytrig to make it more sparse. 
##---
swap 0.9 maytrig 
##---
##: This trigger signal is then fed into **tgate**. When triggered, **tgate**
##: will produce a gate signal for .5 millseconds. This tiny gate is then
##: smoothed out using **port** and multiplied with the white noise signal to
##: get a rhythmic clackity click.
##---
0.0005 tgate 0.001 port *  
##---
##: Finally, this white noise signal is added into everything that has occured
##: before it.
##---
+
##---

##: ## Effects
##: The effect chain consists of a reverb module and a peak limiter. Before
##: any signals are processed, a copy of the signal is made.
##--
dup
##--
##: The signal is then fed into **zrev**, the simplified zita reverb module 
##: ugen. Before it is fed in, it is sent through a high pass filter. This is
##: to give the dry bass sound more clarity and to make things less muddy.
##---
200 buthp dup 20 10 4000 zrev drop -3 ampdb * +
##---

##: Before being sent to the speakers, the final mix is sent through a peak 
##: limiter and bumped up 3db.
##---
0.1 0.001 -3 peaklim 3 ampdb * 
##---
