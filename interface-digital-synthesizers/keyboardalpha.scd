~sawphase= Bus.control(s,1);
~pw= Bus.control(s,1);
~square= Bus.control(s,1);
~tri= Bus.control(s,1);
~metal= Bus.control(s,1);
~atk= Bus.control(s,1);
~dec= Bus.control(s,1);
~sus= Bus.control(s,1);
~rel= Bus.control(s,1);

~sawphase.set(1);
~pw.set(1);
~square.set(1);
~tri.set(1);
~metal.set(1);
~atk.set(1);
~dec.set(1);
~sus.set(1);
~rel.set(1);

MIDIdef.cc(\knb1,{arg val;~sawphase.set(val.linlin(0,127,0,1).postln;)},74,1);
MIDIdef.cc(\knb2,{arg val;~pw.set(val.linlin(0,127,0,1).postln)},71,1);
MIDIdef.cc(\knb3,{arg val;~square.set(val.linlin(0,127,0,1).postln)},2,1);
MIDIdef.cc(\knb4,{arg val;~tri.set(val.linlin(0,127,0,1).postln)},3,1);
MIDIdef.cc(\knb5,{arg val;~metal.set(val.linlin(0,127,0,1).postln)},82,1);
MIDIdef.cc(\knb6,{arg val;~atk.set(val.linlin(0,127,0,1).postln)},83,1);
MIDIdef.cc(\knb7,{arg val;~dec.set(val.linlin(0,127,0,1).postln)},28,1);
MIDIdef.cc(\knb8,{arg val;~sus.set(val.linlin(0,127,0,1).postln)},29,1);


//bass


SynthDef(\micro,{arg amp=1,pitch=432, sawphase=1,pw=1,square=1,tri=1,metal=1,atk=1,dec=1,sus=1,rel=1,gate=1;
var env,sig;
	sig =
	(	LFSaw.ar(pitch * (1+[0, sawphase/10, 0-sawphase/10])).mean)	+
	LFPulse.ar(pitch,pw,mul:square)
	 + 	LFTri.ar(pitch,mul:tri).fold(0,metal);
	env = EnvGen.kr(Env.adsr(atk, dec, sus, rel), gate, doneAction:2);
	sig = HPF.ar(sig,20) * env;
	sig = Limiter.ar(sig,0.3);
	Out.ar(0, sig*amp);
}).add;

//nappe


//melody


//noisy


256.do{arg i;
MIDIdef.noteOn((\key++i).asSymbol,{arg vel,note;vel.postln;
		currentEnvironment[(\synth++i).asSymbol] = Synth(\micro,[
			\pitch,(i + (432.cpsmidi - 69)).midicps,
			\sawphase,~sawphase.asMap,
			\pw,~pw.asMap,
			\square,~square.asMap,
			\tri,~tri.asMap,
			\metal,~metal.asMap,
			\atk,~atk.asMap,
			\dec,~dec.asMap,
			\sus,~sus.asMap,
			\rel,~rel.asMap,
			\amp,vel.linlin(0,127,0,1),
			\gate,1
	])},i);
};


256.do{arg i;
MIDIdef.noteOff((\keyoff++i).asSymbol,{arg ...args;args.postln;
currentEnvironment[(\synth++i).asSymbol].set(\gate,0)},i);
};

//arpegiator
