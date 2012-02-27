import("maxmsp.lib");
import("effect.lib");

//---------------------------------------------------------------------------------------------
//                              sidechain
//---------------------------------------------------------------------------------------------


sc_s = bypass2(scbp,sc_stereo) with {

      sc_group(x) = vgroup("SideChain  [tooltip: SideChain allow you decide which frequency range will gate follow]", x);
      byp_sc(x) = sc_group(hgroup("[0]", x));
      scf_group(x) = sc_group(hgroup("[1]", x));

        scbp = byp_sc(checkbox("[0] SC Bypass  [tooltip: When this is checked, the SideChain has no effect]"));


                 highG = 0;
                 highF = hslider("HPF [unit:Hz] [style:knob]", 20, 20, 20000, 1);
                 highQ = 1;

                 lowG = 0;
                 lowF = hslider("LPF [unit:Hz] [style:knob]", 20000, 20, 20000, 1);
                 lowQ = 1;

                 lpf(x) = LPF(x,lowF,lowG,lowQ);
                 hpf(x) = HPF(x,highF,highG,highQ);

         sc_m = lpf : hpf;

      sc_stereo = scf_group(vgroup("", (sc_m,sc_m)));

} ;

process = vgroup("[0]", sc_s);
