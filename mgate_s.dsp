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
import("math.lib");
import("music.lib");

mgate_s = bypass2(gbp,gate_stereo_d);

   
   gate_g(x)  = hgroup("GATE STEREO [tooltip: Reference: http://en.wikipedia.org/wiki/Noise_gate]", x);

   byp_g(x)         = gate_g(vgroup("[0]", x));
   v_in(x)          = gate_g(hgroup("[1]", x));
   thresh_g(x)      = gate_g(hgroup("[2]", x));
   knob_g(x)        = gate_g(vgroup("[3]", x));
   v_out(x)         = gate_g(hgroup("[4]", x));

   gbp = byp_g(checkbox("[0] Bypass  [tooltip: When this is checked, the gate has no effect]"));

   gateview = gate_gain_mono(gatethr,gateatt,gatehold,gaterel) ;

   gate_stereo_d(x,y) = attach(x,gateview(abs(x)+abs(y))),y :
     gate_stereo(gatethr,gateatt,gatehold,gaterel);

   gatethr = thresh_g(vslider("[0] Threshold [unit:dB]  [tooltip: When the signal level falls below the Threshold (expressed in dB), the signal is muted]",
     -30, -120, 0, 0.1));

   gateatt = knob_g(hslider("[0] Attack [unit:us] [style:knob]  [tooltip: Time constant in MICROseconds (1/e smoothing time) for the gate gain to go (exponentially) from 0 (muted) to 1 (unmuted)]",
     10, 10, 10000, 1)) : *(0.000001) : max(1/SR);

   gatehold = knob_g(hslider("[1] Hold [unit:ms] [style:knob]  [tooltip: Time in ms to keep the gate open (no muting) after the signal level falls below the Threshold]",
     200, 0, 1000, 1)) : *(0.001) : max(1/SR);

   gaterel = knob_g(hslider("[2] Release [unit:ms] [style:knob]  [tooltip: Time constant in ms (1/e smoothing time) for the gain to go (exponentially) from 1 (unmuted) to 0 (muted)]",
     100, 0, 1000, 1)) : *(0.001) : max(1/SR);


  vmeter_l(x)     = hgroup("L" , attach(x, envelop(x) : vbargraph("[2][unit:dB]", -70, +5)));
  vmeter_r(x)     = hgroup("R" , attach(x, envelop(x) : vbargraph("[2][unit:dB]", -70, +5)));

  envelop         = abs : max ~ -(1.0/SR) : max(db2linear(-70)) : linear2db;

  vmeter_s_in      = v_in(hgroup("input dB meter", (vmeter_l,vmeter_r)));
  vmeter_s_out     = v_out(hgroup("output dB meter", (vmeter_l,vmeter_r)));

//  v_in                     = hgroup("",vmeter_s_in);
//  v_out                  = hgroup("",vmeter_s_out);

process = 

  vmeter_s_in: 
  mgate_s : 
  vmeter_s_out:

    _,_;
