~lfo_pitch = Bus.control(s,1);
~lfo_metal = Bus.control(s,1);
~lfo_saw = Bus.control(s,1);
//~lfo_sub = Bus.control(s,1);
~lfo_filter = Bus.control(s,1);
~lfo_pwm = Bus.control(s,1);
~pitch = Bus.control(s,1);
//~sub= Bus.control(s,1);
~pw= Bus.control(s,1);
~metal = Bus.control(s,1);
~overtone = Bus.control(s,1);
~saw = Bus.control(s,1);
~square = Bus.control(s,1);
~tri = Bus.control(s,1);
~cutoff = Bus.control(s,1);
~res = Bus.control(s,1);
~dist = Bus.control(s,1);
~filtermode = Bus.control(s,1);
~envamt = Bus.control(s,1);
~lfo = Bus.control(s,1);
~rate = Bus.control(s,1);
~atk = Bus.control(s,1);
~dec = Bus.control(s,1);
~sus = Bus.control(s,1);
~rel = Bus.control(s,1);
~mod = Bus.control(s,1);
~lfowave= Bus.control(s,1);
~amp= Bus.control(s,1);

FreqScope.new;

(
SynthDef(\microbrute,{
arg
	lfo_pitch=0,
	lfo_metal=0,
	lfo_saw=0,
	lfo_sub=0,
	lfo_filter=0,
	lfo_pwm=0,
	pitch=432,
	sub =1,
	pw=0.1,
	metal=1,
	overtone=1,
	saw=1,
	square=1,
	tri=1,
	cutoff=100,
	res=2,
	dist=1,
	filtermode=0,
	envamt=0,
	key=1,
	glide=1,
	lfo=1,
	rate=0,
	envamt2=1,
	vca=1,
	atk=1,
	dec=1,
	sus=1,
	rel=1,
	mod,
	lfowave=0,
	amp=1,
	doneAction=2,
	gate=1,
	out=0,
	sawphase = 1;
	var sig, hpf, lpf, bpf;
	var env;
	var lfosig;
	var makefilter = { arg type;
		type.ar(sig, cutoff * SelectX.kr(envamt, [1, env+0.0001]), 1/res)
	};
	pitch = pitch * ( 1 + lfo_pitch );
	metal = metal * ( 1 + lfo_metal );
	sawphase = sawphase * (1 + lfo_saw );
	sub = sub * (1 + lfo_sub);
	cutoff = cutoff * (1 + lfo_filter);
	pw = pw * (1 + lfo_pwm );
	sig = (
		LFSaw.ar(pitch * (1+[0, sawphase/10, 0-sawphase/10])).mean
	)
	+
	LFPulse.ar(pitch,pw,mul:square)+ LFTri.ar(pitch,mul:tri).fold(0,metal);
	env = EnvGen.kr(Env.adsr(atk, dec, sus, rel), gate, doneAction:doneAction);
	sig = SelectX.ar(filtermode, [
		makefilter.(RLPF),
		makefilter.(BPF),
		makefilter.(RHPF),
	]);
	sig = sig * env;
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
);


MIDIIn.connectAll;

s.plotTree;
~test = Synth(\microbrute);
~test.free;
(127 + (432.cpsmidi - 69)).midicps

s.meter;
// clear node

s.sendMsg(\n_free, id_number)


MIDIdef.cc(\fil,{arg ...args;args.postln})
MIDIdef.cc(\fil).remove
//
MIDIIn.connectAll;

s.meter;

(
MIDIdef.cc(\knb1,{arg val;~lfo_pitch.set(val.linlin(0,127,0,1).postln;)},74);
MIDIdef.cc(\knb2,{arg val;~lfo_metal.set(val.linlin(0,127,0,1).postln)},71);
MIDIdef.cc(\knb3,{arg val;~lfo_saw.set(val.linlin(0,127,0,1).postln)},2);
MIDIdef.cc(\knb4,{arg val;~lfo_pwm.set(val.linlin(0,127,0,1).postln)},3);
MIDIdef.cc(\knb5,{arg val;~pw.set(val.linlin(0,127,0,1).postln)},82);
MIDIdef.cc(\knb6,{arg val;~metal.set(val.linlin(0,127,0,1).postln)},83);
//MIDIdef.cc(\knb7,{arg val;~pw.set(val.linlin(0,127,0,1).postln)},28);
//MIDIdef.cc(\knb8,{arg val;~metal.set(val.linlin(0,127,0,1).postln)},29);




256.do{arg i;
MIDIdef.noteOn((\key++i).asSymbol,{arg vel,note;vel.postln;
		currentEnvironment[(\synth++i).asSymbol] = Synth(\microbrute,[
			\lfo_pitch,~lfo_pitch.asMap,
			\lfo_metal,~lfo_metal.asMap,
			\lfo_saw,~lfo_saw.asMap,
			\lfo_pwm,~lfo_pwm.asMap,
			\pw,~pw.asMap,
			\metal,~metal.asMap,
			\amp,vel.linlin(0,127,0,1),
			\pitch,(i + (432.cpsmidi - 69)).midicps,
			\gate,1
	])},i);
};


256.do{arg i;
MIDIdef.noteOff((\keyoff++i).asSymbol,{arg ...args;args.postln;
currentEnvironment[(\synth++i).asSymbol].set(\gate,0)},i);
};
)
/*

MIDIdef.cc(\pad0,{
MIDIdef.cc(\knb1,{arg val;~lfo_pitch.set(val.linlin(0,127,0,1).postln;)},74);
MIDIdef.cc(\knb2,{arg val;~lfo_metal.set(val.linlin(0,127,0,1).postln)},71);
MIDIdef.cc(\knb3,{arg val;~lfo_saw.set(val.linlin(0,127,0,1).postln)},2);
MIDIdef.cc(\knb4,{arg val;~lfo_sub.set(val.linlin(0,127,0,1).postln)},3);
MIDIdef.cc(\knb5,{arg val;~lfo_pwm.set(val.linlin(0,127,0,1).postln)},82);
MIDIdef.cc(\knb6,{arg val;~sub.set(val.linlin(0,127,0,1).postln)},83);
MIDIdef.cc(\knb7,{arg val;~pw.set(val.linlin(0,127,0,1).postln)},28);
MIDIdef.cc(\knb8,{arg val;~metal.set(val.linlin(0,127,0,1).postln)},29);
},20);

MIDIdef.noteOn(\pad1,{
MIDIdef.cc(\knb1,{arg val;~overtone.set(val.linlin(0,127,0,1).postln)},74);
MIDIdef.cc(\knb2,{arg val;~saw.set(val.linlin(0,127,0,1).postln)},71);
MIDIdef.cc(\knb3,{arg val;~square.set(val.linlin(0,127,0,1).postln)},2);
MIDIdef.cc(\knb4,{arg val;~tri.set(val.linlin(0,127,0,1).postln)},3);
MIDIdef.cc(\knb5,{arg val;~cutoff.set(val.linlin(0,127,0,1).postln)},82);
MIDIdef.cc(\knb6,{arg val;~res.set(val.linlin(0,127,0,1).postln)},83);
MIDIdef.cc(\knb7,{arg val;~dist.set(val.linlin(0,127,0,1).postln)},28);
MIDIdef.cc(\knb8,{arg val;~filtermode.set(val.linlin(0,127,0,1).postln)},29);
},21);



~synth = Synth(\piano,[\gate,1]);

/*
256.do{arg i;
MIDIdef.noteOn((\key++i).asSymbol,{arg vel,note;
currentEnvironment[(\synth++i).asSymbol] = Synth(\piano,[\freq,	(note + (432.cpsmidi - 69)).midicps,\gate,1])},i);
};


256.do{arg i;
MIDIdef.noteOff((\keyoff++i).asSymbol,{arg ...args;args.postln;
currentEnvironment[(\synth++i).asSymbol].set(\gate,0)},i);
};


SynthDef(\piano,{arg gate = 0,freq=432,sustain=1;
	var env = EnvGen.ar(Env.adsr(2,0.5,sustain,2),gate,doneAction:2);
	var sig = LFPulse.ar( LFPulse.ar(freq/8,0,freq,freq/2));
	sig = FreeVerb.ar(sig,1,[0.5,0.6]);
	Out.ar(0, [AllpassL.ar(sig*env,0.1,0.09),AllpassL.ar(sig*env,0.1,0.1)]);
}).add;



