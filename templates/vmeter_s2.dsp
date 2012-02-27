import("math.lib");
import("music.lib");


vmeter_l(x)	= hgroup("L" , attach(x, envelop(x) : vbargraph("[2][unit:dB]", -70, +5)));
vmeter_r(x)	= hgroup("R" , attach(x, envelop(x) : vbargraph("[2][unit:dB]", -70, +5)));

envelop         = abs : max ~ -(1.0/SR) : max(db2linear(-70)) : linear2db;

vmeter_s        = hgroup("input dB meter", (vmeter_l,vmeter_r));

process 	= vmeter_s;
