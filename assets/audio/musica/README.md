# Deploy de Oito Bits — rascunho original

Trilha instrumental original criada proceduralmente para R8 Heroes, sem samples externos ou transcrição da música de referência.

- `deploy-de-oito-bits-previa.wav`: prévia curta.
- `deploy-de-oito-bits-loop.wav`: loop estéreo de 60 segundos, 128 BPM.
- `deploy-de-oito-bits.mid`: MIDI com melodia, arpejo, baixo e bateria em pistas separadas.
- `deploy-de-oito-bits-notas.json`: métricas e parâmetros da composição.

Instrumentação em estética de console: duas vozes de pulso, baixo triangular e percussão de ruído. O WAV é PCM 16-bit para não adicionar ruído de quantização desnecessário. O MIDI guarda as notas; timbres de uma DAW podem soar diferentes da prévia sintetizada.

Estrutura: 4 compassos de abertura, 8 de tema A, 8 de tema B, 4 de respiro e 8 de retorno. A música ainda não está ligada à fase: ouvir e ajustar primeiro.

Código-fonte reproduzível: `work/compor_trilha_8bits.py`.
