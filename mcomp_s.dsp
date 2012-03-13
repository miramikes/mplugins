declare name 		"mcomp_s";
declare version 	"0.0.1";
declare author 		"mira";
declare license 	"GPL-2";
declare copyright 	"(c)mira 2012";

//---------------------------------------------------------------------------------------------
// 			stereo compressor
//---------------------------------------------------------------------------------------------

import("oscillator.lib");
import("effect.lib");
import("filter.lib");
import("math.lib");
import("music.lib");

mcomp_s = bypass2(cbp,comp_stereo_d);

   comp_g(x) = hgroup("COMPRESSOR STEREO [tooltip: Reference: http://en.wikipedia.org/wiki/Dynamic_range_compression]", x);

   byp_g(x)         = comp_g(vgroup("[0]", x));
   v_in(x)          = comp_g(hgroup("[1]", x));
   thresh_g(x)      = comp_g(hgroup("[2]", x));
   knob_g(x)        = comp_g(vgroup("[3]", x));
   meter_g(x)       = comp_g(hgroup("[4]", x));
   v_out(x)         = comp_g(hgroup("[6]", x));

    cbp = byp_g(checkbox("[0] Bypass  [tooltip: When this is checked, the compressor has no effect]"));

   gainview =
     compression_gain_mono(ratio,threshold,attack,release) : linear2db :
      meter_g(vbargraph("[1] Compression[unit:dB] [tooltip: Current gain of the compressor in dB]", -50,+10));

   displaygain = _,_ <: _,_,(abs,abs:+) : _,_,gainview : _,attach;

   comp_stereo_d =
     displaygain(compressor_stereo(ratio,threshold,attack,release)) : *(makeupgain), *(makeupgain);

   ctl_g(x)  = knob_g(vgroup("[3] Compression Control", x));

   ratio = ctl_g(hslider("[0] Ratio [style:knob]  [tooltip: A compression Ratio of N means that for each N dB increase in input signal level above Threshold, the output level goes up 1 dB]",
     5, 1, 20, 0.1));

   threshold = thresh_g(vslider("[1] Threshold [unit:dB]  [tooltip: When the signal level exceeds the Threshold (in dB), its level is compressed according to the Ratio]",
     -30, -100, 10, 0.1));


   attack = ctl_g(hslider("[1] Attack [unit:ms] [style:knob]  [tooltip: Time constant in ms (1/e smoothing time) for the compression gain to approach (exponentially) a new lower target level (the compression `kicking in')]",
     50, 0, 500, 0.1)) : *(0.001) : max(1/SR);

   release = ctl_g(hslider("[2] Release [unit:ms] [style: knob]  [tooltip: Time constant in ms (1/e smoothing time) for the compression gain to approach (exponentially) a new higher target level (the compression 'releasing')]",
     500, 0, 1000, 0.1)) : *(0.001) : max(1/SR);

   makeupgain = comp_g(vslider("[5] Makeup [unit:dB]  [tooltip: The compressed-signal output level is increased by this amount (in dB) to make up for the level lost due to compression]",
     40, -96, 96, 0.1)) : db2linear;


//---------------------------------------------------------------------------------------------
//                              vumeter
//---------------------------------------------------------------------------------------------


  vmeter_l(x)     = hgroup("L" , attach(x, envelop(x) : vbargraph("[2][unit:dB]", -70, +5)));
  vmeter_r(x)     = hgroup("R" , attach(x, envelop(x) : vbargraph("[2][unit:dB]", -70, +5)));

  envelop         = abs : max ~ -(1.0/SR) : max(db2linear(-70)) : linear2db;

  vmeter_s_in      = v_in(hgroup("input dB", (vmeter_l,vmeter_r)));
  vmeter_s_out     = v_out(hgroup("output dB", (vmeter_l,vmeter_r)));

process = vmeter_s_in : mcomp_s : vmeter_s_out ;
