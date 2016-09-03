MIDIIn.connectAll;

s.sendMsg(\n_free,1010);
s.plotTree;
s.meter

////bypass

(
SynthDef(\test,{arg level = 1;
	var dry  = SinOsc.ar(4000);
	var wet = Decimator.ar(dry,1000,6);
	Out.ar(0,((1-level)*dry+(wet*level)));
}).add;

)


~test = Synth(\test);
~test.set(\level,0.8);


/////bypass


(
SynthDef(\mixer,{ arg aux11=0, aux21=0, aux31=0, aux41=0, aux12=0, aux22=0, aux32=0, aux42=0,aux13=0,aux23=0,aux33=0,aux43=0,
	aux14 = 0, aux24=0,aux34=0,aux44 = 0;
var in1 = (In.ar(0,1)*aux11) + (In.ar(1,1)*aux21) +(In.ar(2,1)*aux31) + (In.ar(3,1)*aux41)  ;
    var in2 = (In.ar(0,1)*aux12) + (In.ar(1,1)*aux22) +(In.ar(2,1)*aux32) + (In.ar(3,1)*aux42)  ;
	var in3 = (In.ar(0,1)*aux13) + (In.ar(1,1)*aux23) +(In.ar(2,1)*aux33) + (In.ar(3,1)*aux43)  ;
	var in4 = (In.ar(0,1)*aux14) + (In.ar(1,1)*aux24) +(In.ar(2,1)*aux34) + (In.ar(3,1)*aux44)  ;
	Out.ar(16,in1);
	Out.ar(17,in2);
	Out.ar(18,in3);
	Out.ar(19,in4);

}).add(s);



b = Buffer.alloc(s,44100 * 2, 2);
SynthDef("pingpong",{ arg out=0,bufnum=0,feedback=0.5,delayTime=0.2,amp=1;
	var left, right;
	left = InFeedback.ar(16,1);
	right = InFeedback.ar(26,1);
	Out.ar(6,
		PingPong.ar(bufnum, [left,right], delayTime, feedback, 1)*amp
	)
}).add(s);


SynthDef(\echo, { arg out=0, maxdtime=0.2, dtime=0.2, decay=2, gate=1,fader1=0, amp=1;
	var env, in,sig;
	env = Linen.kr(gate, 0.5, 0.4, 0.1, 2);
	in = InFeedback.ar(16,1);
	//in = LPF.ar(in,15000,1,0.01);
	//	in = HPF.ar(in,400,1,0.01)+in;
	sig = CombL.ar(in * env, maxdtime, dtime, decay, amp, in);
	Out.ar(6,[sig,DelayL.ar(sig*(-1),0.1,SinOsc.kr(0.1,0,0.05,0.1))]*amp);
	//XOut.ar(out, env, CombL.ar(in * env, maxdtime, dtime, decay, amp, in));
}, [\ir, \ir, 0.1, 0.1, 0]).add(s);



SynthDef(\daverb,{arg amp=1,pitch=1;
	var freqs;
	var sig = CrossoverDistortion.ar( InFeedback.ar(18,1),1,1);
	sig = FreeVerb.ar(sig,1,1);
	freqs = {exprand(1000, 20000)}.dup(100);
	sig   =Ringz.ar(sig , freqs).mean;
	sig  = PitchShift.ar(sig,0.2,pitch);
	sig = Limiter.ar(sig,0.4);
	sig =[sig,sig*(-1)];
	Out.ar(6,sig*amp);
}).add(s);

SynthDef(\daverb2,{arg amp=1,pitch=1,mix=1,room=1,damp=1;
	var freqs;
	var sig = ( InFeedback.ar(18,1));
	sig = FreeVerb.ar(sig,mix,room,damp);
	sig  = PitchShift.ar(sig,0.2,pitch);
	sig = Limiter.ar(sig,0.4);
	sig =[sig,sig*(-1)];
	Out.ar(23,sig*amp);
}).add(s);

SynthDef(\fx2,{arg delay = 0.02,amp=1,pitch=1;
	var in =  CrossoverDistortion.ar( InFeedback.ar(23,1),1,1);
	var sig = Disintegrator.ar(in,1,1,2000);
	sig = Decimator.ar(sig,20050,6)+sig;
	sig = CombC.ar(sig,0.1,delay)+sig;
	sig= sig.tanh.distort;
	sig = FreeVerb.ar(sig,0.5);
	sig  = PitchShift.ar(sig,0.2,pitch);
	sig = HPF.ar(sig,50)*amp*0.7;
	Out.ar(21,[sig,sig]);
}).add(s);

SynthDef(\dist,{arg amp =0.1,pitch=1;
	var freqs;
	var sig = CrossoverDistortion.ar( InFeedback.ar(21,1),1,1);
	sig = CombL.ar(sig,0.1,0.1,0.1)+sig;
	sig = CombL.ar(sig,0.1,0.04,0.1)+sig;
	sig = CombL.ar(sig,0.1,0.1,0.1)+sig;
	sig = CombL.ar(sig,0.1,0.1,0.1)+sig;
	sig = (sig*4).tanh;
	sig  = PitchShift.ar(sig,0.2,pitch);
	sig = Limiter.ar(sig,0.8);
	Out.ar(6,[sig,DelayL.ar(sig*(-1),0.1,SinOsc.kr(0.1,0,0.05,0.1))]*amp*0.5);
}).add(s);
)

Ndef(\fx2).clear;
FreqScope.new;

s.meter;

~echo.free;
~mixer.free;
~dist.free;
~daverb.free;
~pingpong.free;
~feedist.free;

~mixer = Synth(\mixer);
~pingpong = Synth(\pingpong,[\bufnum, b.bufnum,\feedback,0.5,\delayTime,t.tempo/4]);
~dist = Synth(\dist);
~daverb = Synth(\daverb2);
~feedist = Synth(\fx2);

~daverb.free;
~daverb = Synth(\daverb);

~pingpong.free;
~echo = Synth(\echo);




s.plotTree;


~feedist.set(\delay,0.02);

~feedist.set(\pitch,1);
~dist.set(\pitch,1);

~pingpong.free;

~pingpong.set(\feedback,0.2)
~pingpong.set(\delayTime,0.2)

////
Ndef(\fx2).clear;
~feedist = Synth(\fx2);
Ndef(\playbuf2).clear;


(
~feedist.free;
Ndef(\fx2).unset(\delay);
Ndef(\fx2).unset(\amp);
Ndef(\fx2,{arg delay = 0.02,amp=1,pitch=1;
	var in = InFeedback.ar(19,1);
	var sig = Disintegrator.ar(in,1,1,2000);
	sig = Decimator.ar(sig,22050,6)+sig;
	sig = CombC.ar(sig,0.1,delay)+sig;
	sig= sig.tanh.distort;
	sig = FreeVerb.ar(sig,0.5);
	sig  = PitchShift.ar(sig,0.2,pitch);
	sig = HPF.ar(sig,50)*amp;
	Out.ar(6,[sig,sig]);
});

);
(
Ndef(\fx2).unset(\delay);
Ndef(\fx2)[1]= \set-> Pbind(\delay,Pseq([0.01,0.002,0.1,0.09],inf),\amp,1,\pitch,1);
);

Ndef(\fx2)[1]= \set-> Pbind(\delay,Pseq([0.1,0.002,0.001,0.009],inf),\amp,1,\pitch,Pseq([1,1.1,0.9,1.2],inf));

Ndef(\fx2).clear;

Ndef(\fx2).set(\delay,0.01);
Ndef(\fx2).set(\delay,0.02);
Ndef(\fx2).set(\delay,0.1);
Ndef(\fx2).set(\delay,0.09);



	Ndef(\fx2).free;

(

MIDIdef.cc(\aux11,{arg val;~mixer.set(\aux11,val.linlin(0,127,0,1).postln)},36);
MIDIdef.cc(\aux21,{arg val;~mixer.set(\aux21,val.linlin(0,127,0,1).postln)},37);
MIDIdef.cc(\aux31,{arg val;~mixer.set(\aux31,val.linlin(0,127,0,1).postln)},38);
MIDIdef.cc(\aux41,{arg val;~mixer.set(\aux41,val.linlin(0,127,0,1).postln)},39);

MIDIdef.cc(\aux12,{arg val;~mixer.set(\aux12,val.linlin(0,127,0,1).postln)},28);
MIDIdef.cc(\aux22,{arg val;~mixer.set(\aux22,val.linlin(0,127,0,1).postln)},29);
MIDIdef.cc(\aux32,{arg val;~mixer.set(\aux32,val.linlin(0,127,0,1).postln)},30);
MIDIdef.cc(\aux42,{arg val;~mixer.set(\aux42,val.linlin(0,127,0,1).postln)},31);


MIDIdef.cc(\aux13,{arg val;~mixer.set(\aux13,val.linlin(0,127,0,1).postln)},20);
MIDIdef.cc(\aux23,{arg val;~mixer.set(\aux23,val.linlin(0,127,0,1).postln)},21);
MIDIdef.cc(\aux33,{arg val;~mixer.set(\aux33,val.linlin(0,127,0,1).postln)},22);
MIDIdef.cc(\aux43,{arg val;~mixer.set(\aux43,val.linlin(0,127,0,1).postln)},23);



MIDIdef.cc(\aux14,{arg val;~mixer.set(\aux14,val.linlin(0,127,0,1).postln)},11);
MIDIdef.cc(\aux24,{arg val;~mixer.set(\aux24,val.linlin(0,127,0,1).postln)},12);
MIDIdef.cc(\aux34,{arg val;~mixer.set(\aux34,val.linlin(0,127,0,1).postln)},13);
MIDIdef.cc(\aux44,{arg val;~mixer.set(\aux44,val.linlin(0,127,0,1).postln)},14);




////////params

//pingpong
MIDIdef.cc(\ping1,{arg val;~pingpong.set(\feedback,val.linlin(0,127,0.1,1).postln);"feedback".postln;},40);
MIDIdef.cc(\ping2,{arg val;~pingpong.set(\delayTime,t.tempo/(val.linlin(0,127,1,16)).asInteger.postln);"delay".postln;},41);
MIDIdef.cc(\ping3,{arg val;~pingpong.set(\amp,val.linlin(0,127,0,1).postln);},42);
MIDIdef.cc(\ping4,{arg val;~pingpong.set(\amp,val.linlin(0,127,0,1).postln);"amp".postln;},43);

//distortion
MIDIdef.cc(\dist1,{arg val;~dist.set(\pitch,val.linlin(0,127,0.8,1.5).postln);"pitch".postln;},32);
MIDIdef.cc(\dist4,{arg val;~dist.set(\amp,val.linlin(0,127,0,1).postln);"amp".postln;},35);

//reverb
MIDIdef.cc(\verb4,{arg val;~daverb.set(\pitch,val.linlin(0,127,0.1,2).postln);"pitch".postln;},24);
MIDIdef.cc(\verb4,{arg val;~daverb.set(\amp,val.linlin(0,127,0,1).postln);"amp".postln;},27);

//fx2
MIDIdef.cc(\feedist1,{arg val;~feedist.set(\pitch,val.linlin(0,127,0.8,1.5).postln)},15);
MIDIdef.cc(\feedist2,{arg val;~feedist.set(\delay,val.linlin(0,127,0.01,0.2).postln)},16);
MIDIdef.cc(\feedist3,{arg val;~feedist.set(\dis,val.linlin(0,127,0,5).postln)},17);
MIDIdef.cc(\feedist4,{arg val;~feedist.set(\amp,val.linlin(0,127,0,1).postln)},18);

)

s.plotTree;

//mix all levels perfectly

//set all fx knobs

