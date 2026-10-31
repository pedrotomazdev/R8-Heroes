from pathlib import Path
import wave
import numpy as np
p=Path('assets/audio/musica')
ratios=[]
for name in ['deploy-de-oito-bits-loop.wav','deploy-de-oito-bits-v2-loop.wav']:
    with wave.open(str(p/name),'rb') as f:
        assert f.getnframes()/f.getframerate()==60
        x=np.frombuffer(f.readframes(f.getnframes()),dtype='<i2').reshape(-1,2).astype(float).mean(axis=1)/32768
    power=np.abs(np.fft.rfft(x))**2
    freq=np.fft.rfftfreq(len(x),1/44100)
    bass=power[(freq>=30)&(freq<90)].sum()/power.sum()
    print(name, 'energia entre 30-90Hz:',round(float(bass)*100,1),'%')
    ratios.append(bass)
assert ratios[1]>ratios[0]
