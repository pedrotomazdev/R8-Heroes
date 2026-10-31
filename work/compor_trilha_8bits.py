"""Composição original do R8 Heroes: síntese procedural e MIDI, sem samples externos.

Estética de quatro vozes de console: pulse lead, pulse arpeggio, triangle bass,
noise percussion. O arquivo WAV usa PCM 16-bit para preservar a qualidade;
"8 bits" aqui descreve a instrumentação e a linguagem musical.
"""
from pathlib import Path
import json
import struct
import wave
import numpy as np

OUT=Path('assets/audio/musica')
OUT.mkdir(parents=True,exist_ok=True)
SR=44100
BPM=128
BEAT=60/BPM
BARS=32
DURATION=BARS*4*BEAT
N=round(DURATION*SR)
rng=np.random.default_rng(808)
stems={name:np.zeros(N,dtype=np.float32) for name in ['melodia','arpejo','baixo','bateria']}
events={name:[] for name in stems}

def env(n,attack=.003,release=.018,decay=1.5):
    t=np.arange(n)/SR
    e=np.exp(-decay*t)
    a=min(round(attack*SR),n//2)
    r=min(round(release*SR),n//2)
    if a: e[:a]*=np.linspace(0,1,a)
    if r: e[-r:]*=np.linspace(1,0,r)
    return e

def synth(note,seconds,kind):
    n=max(8,round(seconds*SR)); t=np.arange(n)/SR
    f=440*2**((note-69)/12)
    vibrato=0.002*np.sin(2*np.pi*5.2*t)*np.minimum(1,t/.12) if kind=='lead' else 0
    phase=2*np.pi*np.cumsum(f*(1+vibrato))/SR if kind=='lead' else 2*np.pi*f*t
    sound=np.zeros(n)
    if kind=='bass':
        for k in range(1,16,2):
            if k*f>SR*.43: break
            sound+=(-1)**((k-1)//2)*np.sin(k*phase)/(k*k)
        sound*=env(n,.004,.023,.45)*1.05
    else:
        duty=.25 if kind=='arp' else .5
        for k in range(1,min(22,int(SR*.43/f))+1):
            sound+=2*np.sin(np.pi*k*duty)/(np.pi*k)*np.cos(k*phase-np.pi*k*duty)
        sound*=env(n,.002,.014,6.5 if kind=='arp' else 1.8)
    return sound.astype(np.float32)

def add(track,start,data):
    index=round(start*BEAT*SR)%N
    end=min(N,index+len(data))
    stems[track][index:end]+=data[:end-index]
    if index+len(data)>N:
        remaining=len(data)-(N-index)
        stems[track][:remaining]+=data[N-index:]

def note(track,beat,pitch,length,velocity=90,kind='lead'):
    events[track].append((beat,pitch,length,velocity))
    add(track,beat,synth(pitch,length*BEAT,kind)*(velocity/127))

def drum(beat,kind,velocity=80):
    secs={'kick':.20,'snare':.14,'hat':.045,'open':.13}[kind]
    n=round(secs*SR); t=np.arange(n)/SR
    # Sample-and-hold noise gives a crunchy old console percussion color.
    noise=np.repeat(rng.uniform(-1,1,(n+3)//4),4)[:n]
    if kind=='kick':
        frequency=45+105*np.exp(-t*45)
        signal=np.sin(2*np.pi*np.cumsum(frequency)/SR)*np.exp(-t*24)
        signal+=noise*np.exp(-t*150)*.13
        midi=36
    elif kind=='snare':
        signal=(noise*.60+np.sin(2*np.pi*185*t)*.17)*np.exp(-t*30)
        midi=38
    else:
        # Difference-filtered noise keeps the hi-hat out of the bass region.
        signal=(noise-np.roll(noise,1))*.22*np.exp(-t*(65 if kind=='hat' else 22))
        midi=42 if kind=='hat' else 46
    signal*=env(n,.001,.005,0)
    add('bateria',beat,signal.astype(np.float32)*(velocity/127))
    events['bateria'].append((beat,midi,.08,velocity))

# F# minor / D / A / E. As frases foram escritas para esta composição,
# sem transcrição, sample ou reconstrução da faixa de referência.
chords=[[66,69,73,76],[62,66,69,73],[61,64,69,73],[64,68,71,76]]
roots=[42,38,45,40]
arp_patterns=[[0,2,1,3,2,1,0,2],[0,1,2,3,1,3,2,1]]

# Melodias originais em graus de F# menor. Ritmo sincopado com espaço entre frases.
scale=[66,68,69,71,73,74,76,78,80,81,83,85]
phrases=[
 [(0,4,.45),(.75,2,.22),(1,1,.45),(1.75,2,.22),(2.25,6,.45),(3,4,.70)],
 [(.25,5,.45),(1,4,.22),(1.5,2,.45),(2.25,1,.45),(3,2,.22),(3.5,4,.35)],
 [(0,2,.70),(1,4,.22),(1.5,6,.45),(2.25,7,.45),(3,6,.70)],
 [(0,4,.45),(.75,3,.22),(1.25,1,.45),(2,3,.45),(2.75,4,.22),(3.25,1,.45)],
 [(0,7,.45),(.5,6,.22),(1.25,4,.45),(2,2,.45),(2.75,4,.22),(3.25,6,.45)],
 [(.25,5,.70),(1.25,4,.22),(1.75,2,.45),(2.5,4,.45),(3.25,5,.45)],
 [(0,6,.22),(.5,7,.22),(1,9,.45),(1.75,7,.22),(2.25,6,.45),(3,4,.70)],
 [(.25,3,.45),(1,4,.22),(1.5,6,.45),(2.25,4,.45),(3,1,.70)]
]
for bar in range(BARS):
    chord_id=bar%4; chord=chords[chord_id]; root=roots[chord_id]
    start=bar*4
    intro=bar<4
    breakdown=20<=bar<24
    # Duas vozes de pulso: lead e arpejo. Arpejo discreto deixa espaço à melodia.
    pattern=arp_patterns[(bar//4)%2]
    for step in range(16):
        if breakdown and step%2: continue
        pitch=chord[pattern[step%8]]+12
        if bar>=24 and step in (7,15): pitch+=12
        note('arpejo',start+step*.25,pitch,.19,55 if not breakdown else 43,'arp')
    bass_pattern=[(0,root,.40),(.5,root,.20),(1,root+12,.20),(1.5,root,.35),(2,root,.40),(2.75,root+7,.20),(3.25,root+12,.20),(3.5,root,.35)]
    if breakdown: bass_pattern=[(0,root,1.4),(2,root+7,1.4)]
    for pos,pitch,length in bass_pattern:
        note('baixo',start+pos,pitch,length,104,'bass')
    for pos in [0,2]: drum(start+pos,'kick',110)
    if not breakdown:
        for pos in [1,3]: drum(start+pos,'snare',92)
        for step in range(8): drum(start+step*.5,'hat',52 if step%2 else 67)
        if bar%4==3:
            drum(start+3.5,'snare',65); drum(start+3.75,'snare',78)
        if bar>=12: drum(start+2.75,'kick',78)
    elif bar%2==1:
        drum(start+3,'snare',65)
    if bar in [3,11,19,23,31]: drum(start+3.5,'open',80)
    if not intro and not breakdown:
        phrase=phrases[(bar-4)%8]
        if bar>=24:
            phrase=phrases[(bar-24+4)%8]
        for pos,degree,length in phrase:
            pitch=scale[degree]
            if 12<=bar<20 and pos>=2: pitch+=12 if degree<=4 else 0
            note('melodia',start+pos,pitch,length,91 if bar<24 else 99)
    elif breakdown:
        note('melodia',start+.5,chord[2],1.25,63)
        note('melodia',start+2.5,chord[1],.75,58)

# Mix estéreo com ecos curtos circulares: as caudas atravessam a emenda do loop.
gains={'melodia':.45,'arpejo':.26,'baixo':.40,'bateria':.48}
pans={'melodia':-.10,'arpejo':.28,'baixo':0,'bateria':-.04}
mix=np.zeros((N,2),dtype=np.float32)
for name,data in stems.items():
    gain=gains[name]; pan=pans[name]
    left=data*gain*np.sqrt((1-pan)/2)
    right=data*gain*np.sqrt((1+pan)/2)
    if name in ('melodia','arpejo'):
        delay=round(BEAT*.75*SR)
        left=left+np.roll(data,delay)*gain*.15
        right=right+np.roll(data,delay*2)*gain*.12
    mix[:,0]+=left; mix[:,1]+=right
mix=np.tanh(mix*1.3)
mix*=.88/max(float(np.max(np.abs(mix))),.001)

def write_wav(path,data):
    pcm=np.round(np.clip(data,-1,1)*32767).astype('<i2')
    with wave.open(str(path),'wb') as f:
        f.setnchannels(2 if data.ndim==2 else 1)
        f.setsampwidth(2); f.setframerate(SR); f.writeframes(pcm.tobytes())

write_wav(OUT/'deploy-de-oito-bits-loop.wav',mix)
# Prévia de 15 segundos para ouvir rapidamente antes de importar o loop inteiro.
preview=mix[round(8*BEAT*SR):round(40*BEAT*SR)].copy()
fade=min(round(.03*SR),len(preview)//2)
preview[:fade]*=np.linspace(0,1,fade)[:,None]
preview[-fade:]*=np.linspace(1,0,fade)[:,None]
write_wav(OUT/'deploy-de-oito-bits-previa.wav',preview)

# MIDI padrão, com pistas independentes para editar numa DAW.
PPQ=480
def vlq(value):
    result=[value&127]; value>>=7
    while value: result.insert(0,(value&127)|128); value>>=7
    return bytes(result)
def chunk(data): return b'MTrk'+struct.pack('>I',len(data))+data
tempo=round(60_000_000/BPM)
meta=b'\x00\xff\x51\x03'+tempo.to_bytes(3,'big')+b'\x00\xff\x58\x04\x04\x02\x18\x08\x00\xff\x2f\x00'
tracks=[chunk(meta)]
for index,(name,items) in enumerate(events.items()):
    channel=9 if name=='bateria' else index
    program={'melodia':80,'arpejo':80,'baixo':38,'bateria':0}[name]
    label=name.encode('ascii')
    data=b'\x00\xff\x03'+vlq(len(label))+label
    if channel!=9: data+=b'\x00'+bytes([0xC0|channel,program])
    sequence=[]
    for beat,pitch,length,velocity in items:
        sequence.append((round(beat*PPQ),1,bytes([0x90|channel,pitch,velocity])))
        sequence.append((round((beat+length)*PPQ),0,bytes([0x80|channel,pitch,0])))
    last=0
    for tick,_,message in sorted(sequence,key=lambda e:(e[0],e[1])):
        data+=vlq(tick-last)+message; last=tick
    data+=vlq(max(0,BARS*4*PPQ-last))+b'\xff\x2f\x00'
    tracks.append(chunk(data))
(OUT/'deploy-de-oito-bits.mid').write_bytes(b'MThd'+struct.pack('>IHHH',6,1,len(tracks),PPQ)+b''.join(tracks))

stats={'bpm':BPM,'duracao_segundos':DURATION,'compassos':BARS,'sample_rate':SR,'pico_dbfs':round(float(20*np.log10(np.max(np.abs(mix)))),2),'rms_dbfs':round(float(20*np.log10(np.sqrt(np.mean(mix**2)))),2),'eventos_midi':{k:len(v) for k,v in events.items()},'amostras_invalidas':int(np.count_nonzero(~np.isfinite(mix)))}
assert stats['amostras_invalidas']==0 and np.max(np.abs(mix))<1
(OUT/'deploy-de-oito-bits-notas.json').write_text(json.dumps(stats,indent=2),encoding='utf-8')
(OUT/'README.md').write_text('''# Deploy de Oito Bits — rascunho original

Trilha instrumental original criada proceduralmente para R8 Heroes, sem samples externos ou transcrição da música de referência.

- `deploy-de-oito-bits-previa.wav`: prévia curta.
- `deploy-de-oito-bits-loop.wav`: loop estéreo de 60 segundos, 128 BPM.
- `deploy-de-oito-bits.mid`: MIDI com melodia, arpejo, baixo e bateria em pistas separadas.
- `deploy-de-oito-bits-notas.json`: métricas e parâmetros da composição.

Instrumentação em estética de console: duas vozes de pulso, baixo triangular e percussão de ruído. O WAV é PCM 16-bit para não adicionar ruído de quantização desnecessário. O MIDI guarda as notas; timbres de uma DAW podem soar diferentes da prévia sintetizada.

Estrutura: 4 compassos de abertura, 8 de tema A, 8 de tema B, 4 de respiro e 8 de retorno. A música ainda não está ligada à fase: ouvir e ajustar primeiro.

Código-fonte reproduzível: `work/compor_trilha_8bits.py`.
''',encoding='utf-8')
print(json.dumps(stats,indent=2))

