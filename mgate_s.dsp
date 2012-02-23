declare name 		"mgate_s";
declare version 	"0.0.1";
declare author 		"mira";
declare license 	"GPL-2";
declare copyright 	"(c)mira 2012";

//-----------------------------------------------
// 			stereo gate
//-----------------------------------------------

import("oscillator.lib");
import("effect.lib");
import("filter.lib");

process = mgate_s ;

mgate_s = bypass2(gbp,gate_stereo_d) with {

   gate_g(x)  = vgroup("GATE  [tooltip: Reference: http://en.wikipedia.org/wiki/Noise_gate]", x);
   meter_g(x) = gate_g(hgroup("[0]", x));
   knob_g(x)  = gate_g(hgroup("[1]", x));

   gbp = meter_g(checkbox("[0] Bypass  [tooltip: When this is checked, the gate has no effect]"));

   gateview = gate_gain_mono(gatethr,gateatt,gatehold,gaterel) : linear2db :
     meter_g(hbargraph("[1] Gate Gain [unit:dB]  [tooltip: Current gain of the gate in dB]",
      -50,+10)); // [style:led]

   gate_stereo_d(x,y) = attach(x,gateview(abs(x)+abs(y))),y :
     gate_stereo(gatethr,gateatt,gatehold,gaterel);

   gatethr = knob_g(hslider("[1] Threshold [unit:dB] [style:knob]  [tooltip: When the signal level falls below the Threshold (expressed in dB), the signal is muted]",
     -30, -120, 0, 0.1));

   gateatt = knob_g(hslider("[2] Attack [unit:us] [style:knob]  [tooltip: Time constant in MICROseconds (1/e smoothing time) for the gate gain to go (exponentially) from 0 (muted) to 1 (unmuted)]",
     10, 10, 10000, 1)) : *(0.000001) : max(1/SR);

   gatehold = knob_g(hslider("[3] Hold [unit:ms] [style:knob]  [tooltip: Time in ms to keep the gate open (no muting) after the signal level falls below the Threshold]",
     200, 0, 1000, 1)) : *(0.001) : max(1/SR);

   gaterel = knob_g(hslider("[4] Release [unit:ms] [style:knob]  [tooltip: Time constant in ms (1/e smoothing time) for the gain to go (exponentially) from 1 (unmuted) to 0 (muted)]",
     100, 0, 1000, 1)) : *(0.001) : max(1/SR);

} ;
