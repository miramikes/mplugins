declare name 		"mlim_s";
declare version 	"0.0.1";
declare author 		"mira";
declare license 	"GPL-2";
declare copyright 	"(c)mira 2012";

//---------------------------------------------------------------------------------------------
// 			stereo lookahead limiter (makes delay 18 samples)
//---------------------------------------------------------------------------------------------

import("oscillator.lib");
import("effect.lib");
import("filter.lib");
import("math.lib");
import("music.lib");

mlim_s = bypass2(lbp,lim_stereo_d);

   
   lim_g(x) = hgroup("LIMITER STEREO [tooltip: Reference: http://en.wikipedia.org/wiki/1176_Peak_Limiter]", x);

   byp_g(x)         = lim_g(vgroup("[0]", x));
   v_in(x)          = lim_g(hgroup("[2]", x));
   meter_g(x)       = lim_g(hgroup("[5]", x));
   v_out(x)         = lim_g(hgroup("[7]", x));

    lbp = byp_g(checkbox("[0] Bypass  [tooltip: When this is checked, the limiter has no effect]"));


//6 samples per 1 stage of limitation

   compressor_la_stereo(ratio,thresh,att,rel,x,y) = cgm*x@6, cgm*y@6 with {
      cgm = compression_gain_mono(ratio,thresh,att,rel,max(abs(x),abs(y)));
      };

   gainview =
     compression_gain_mono(4,-6,0.0008,0.5) : linear2db :
      meter_g(vbargraph("[1] Reduction [unit:dB] [tooltip: Current reduction of the limiter in dB]", -50,+10));

   displaygain = _,_ <: _,_,(abs,abs:+) : _,_,gainview : _,attach;

// 3 stage limitation

   lim_stereo_d = *(inputgain),*(inputgain) : vmeter_s_in :
     displaygain  (compressor_la_stereo(4,-6,0.0008,0.5)) : (compressor_la_stereo(12,-2,0.0004,0.3)) : (compressor_la_stereo(100,-1,0.0001,0.1)) : *(makeupgain),*(makeupgain) ;


   makeupgain = lim_g(vslider("[6] Makeup [unit:dB]  [tooltip: The ceiling of signal output level (in dB) can be set here]",
     -0.2, -45, 0, 0.01)) : db2linear;

   inputgain = lim_g(vslider("[1] in_gain [unit:dB]  [tooltip: The input signal level is increased by this amount (in dB) to achieve desired effect.]",
     0, -45, 40, 0.01)) : db2linear;

//---------------------------------------------------------------------------------------------
//                              vumeter
//---------------------------------------------------------------------------------------------


  vmeter_l(x)     = hgroup("L" , attach(x, envelop(x) : vbargraph("[2][unit:dB]", -70, +5)));
  vmeter_r(x)     = hgroup("R" , attach(x, envelop(x) : vbargraph("[2][unit:dB]", -70, +5)));

  envelop         = abs : max ~ -(1.0/SR) : max(db2linear(-70)) : linear2db;

  vmeter_s_in      = v_in(hgroup("input dB", (vmeter_l,vmeter_r)));
  vmeter_s_out     = v_out(hgroup("output dB", (vmeter_l,vmeter_r)));

process =    mlim_s : vmeter_s_out ;
