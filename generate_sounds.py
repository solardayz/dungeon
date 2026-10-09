import wave
import math
import struct
import random

SAMPLE_RATE = 44100

def write_wav(filename, samples):
    with wave.open(filename, 'w') as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)
        wf.setframerate(SAMPLE_RATE)
        packed = b''.join(struct.pack('<h', max(-32767, min(32767, int(s * 32767)))) for s in samples)
        wf.writeframes(packed)
    print(f"Generated {filename}")

# 1. SWING: 칼 휘두르기 (스윙 쉭-)
def make_swing():
    dur = 0.2
    n = int(SAMPLE_RATE * dur)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        env = math.sin(math.pi * (i / n)) ** 1.5
        # Pitch drop from 550Hz down to 100Hz
        freq = 550.0 * (1.0 - (i / n) * 0.8)
        sine = math.sin(2 * math.pi * freq * t)
        noise = (random.random() * 2.0 - 1.0) * 0.4
        val = (sine * 0.6 + noise * 0.4) * env * 0.85
        samples.append(val)
    return samples

# 2. HIT: 타격음 (퍽! 찰진 임팩트)
def make_hit():
    dur = 0.18
    n = int(SAMPLE_RATE * dur)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 28.0)
        # Low punch drop 260Hz -> 40Hz
        freq = 260.0 * math.exp(-t * 22.0) + 40.0
        punch = math.sin(2 * math.pi * freq * t)
        # Crunchy initial noise
        noise_env = math.exp(-t * 60.0)
        noise = (random.random() * 2.0 - 1.0) * noise_env
        val = (punch * 0.7 + noise * 0.5) * env
        # Subtle clipping for punchy crunch
        val = math.tanh(val * 1.6) * 0.95
        samples.append(val)
    return samples

# 3. DASH: 대쉬 바람 소리 (슝-)
def make_dash():
    dur = 0.22
    n = int(SAMPLE_RATE * dur)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        env = math.sin(math.pi * (i / n))
        # High-mid noise burst with sine sweep
        freq = 300.0 + 400.0 * math.sin(math.pi * (i / n))
        sine = math.sin(2 * math.pi * freq * t)
        noise = (random.random() * 2.0 - 1.0) * 0.6
        val = (sine * 0.35 + noise * 0.65) * env * 0.75
        samples.append(val)
    return samples

# 4. HURT: 피격음 (으억 / 쿵)
def make_hurt():
    dur = 0.25
    n = int(SAMPLE_RATE * dur)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 16.0)
        freq = 150.0 * math.exp(-t * 12.0) + 45.0
        sub = math.sin(2 * math.pi * freq * t)
        harm = math.sin(2 * math.pi * freq * 2.0 * t) * 0.3
        val = (sub + harm) * env * 0.9
        samples.append(val)
    return samples

# 5. ENEMY DIE: 고블린 처치 사운드 (뿅/처치 쾌감)
def make_enemy_die():
    dur = 0.32
    n = int(SAMPLE_RATE * dur)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 10.0)
        # Rising tone 300 -> 700 then falling
        freq = 350.0 + 350.0 * math.sin(math.pi * min(1.0, t * 5.0))
        sine = math.sin(2 * math.pi * freq * t)
        val = sine * env * 0.75
        samples.append(val)
    return samples

# 6. BOSS SPAWN: 보스 출현 웅장한 혼 (뿌우우웅)
def make_boss_spawn():
    dur = 1.0
    n = int(SAMPLE_RATE * dur)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        # Attack, sustain, decay
        if t < 0.1:
            env = t / 0.1
        else:
            env = math.exp(-(t - 0.1) * 3.0)
        f0 = 95.0
        # Rich brass harmonics
        horn = (math.sin(2 * math.pi * f0 * t) * 0.5 +
                math.sin(2 * math.pi * f0 * 2.0 * t) * 0.3 +
                math.sin(2 * math.pi * f0 * 3.0 * t) * 0.15 +
                math.sin(2 * math.pi * f0 * 4.0 * t) * 0.08)
        val = math.tanh(horn * 1.5) * env * 0.85
        samples.append(val)
    return samples

# 7. VICTORY: 승리 팡파르 (도-미-솔-도)
def make_victory():
    dur = 1.4
    n = int(SAMPLE_RATE * dur)
    notes = [523.25, 659.25, 783.99, 1046.50] # C5, E5, G5, C6
    note_times = [0.0, 0.18, 0.36, 0.54]
    samples = [0.0] * n
    for note_idx, f in enumerate(notes):
        start_t = note_times[note_idx]
        start_i = int(start_t * SAMPLE_RATE)
        note_dur = dur - start_t
        note_n = int(note_dur * SAMPLE_RATE)
        for j in range(note_n):
            idx = start_i + j
            if idx >= n: break
            t_rel = j / SAMPLE_RATE
            env = math.exp(-t_rel * (3.5 if note_idx < 3 else 2.0))
            chime = (math.sin(2 * math.pi * f * t_rel) * 0.6 +
                     math.sin(2 * math.pi * f * 2.0 * t_rel) * 0.25)
            samples[idx] += chime * env * 0.4
    return samples

# 8. DEFEAT: 패배 효과음 (낮은 하강음)
def make_defeat():
    dur = 1.2
    n = int(SAMPLE_RATE * dur)
    notes = [440.0, 392.0, 349.23, 293.66] # A4, G4, F4, D4
    note_times = [0.0, 0.22, 0.44, 0.66]
    samples = [0.0] * n
    for note_idx, f in enumerate(notes):
        start_t = note_times[note_idx]
        start_i = int(start_t * SAMPLE_RATE)
        note_dur = dur - start_t
        note_n = int(note_dur * SAMPLE_RATE)
        for j in range(note_n):
            idx = start_i + j
            if idx >= n: break
            t_rel = j / SAMPLE_RATE
            env = math.exp(-t_rel * 2.8)
            tone = (math.sin(2 * math.pi * f * t_rel) * 0.5 +
                    math.sin(2 * math.pi * f * 0.5 * t_rel) * 0.3)
            samples[idx] += tone * env * 0.45
    return samples

# 9. BUTTON CLICK: UI 클릭음
def make_btn_click():
    dur = 0.08
    n = int(SAMPLE_RATE * dur)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 50.0)
        freq = 900.0 * math.exp(-t * 20.0)
        sine = math.sin(2 * math.pi * freq * t)
        samples.append(sine * env * 0.6)
    return samples

# 10. GOLD PICKUP: 코인 획득 사운드 (짤랑~ 청아한 금속음)
def make_gold():
    dur = 0.25
    n = int(SAMPLE_RATE * dur)
    samples = [0.0] * n
    # Two quick high bells: 1400Hz, 2100Hz
    chimes = [(0.0, 1480.0), (0.07, 2217.0)]
    for start_t, freq in chimes:
        start_i = int(start_t * SAMPLE_RATE)
        for i in range(start_i, n):
            t_rel = (i - start_i) / SAMPLE_RATE
            env = math.exp(-t_rel * 22.0)
            tone = (math.sin(2 * math.pi * freq * t_rel) * 0.7 +
                    math.sin(2 * math.pi * freq * 2.75 * t_rel) * 0.3)
            samples[i] += tone * env * 0.4
    return samples

# 11. POTION: 포션 회복 사운드 (마법 치유 효과음 촤르르~)
def make_potion():
    dur = 0.4
    n = int(SAMPLE_RATE * dur)
    samples = [0.0] * n
    # Ascending arpeggio notes (F5, A5, C6, F6)
    notes = [698.46, 880.0, 1046.50, 1396.91]
    for idx, f in enumerate(notes):
        start_t = idx * 0.06
        start_i = int(start_t * SAMPLE_RATE)
        for i in range(start_i, n):
            t_rel = (i - start_i) / SAMPLE_RATE
            env = math.exp(-t_rel * 14.0)
            tone = math.sin(2 * math.pi * f * t_rel)
            samples[i] += tone * env * 0.3
    return samples

# 12. WHIRLWIND: 휠윈드 회전 베기 사운드 (회오리 바람 + 검 파열음)
def make_whirlwind():
    dur = 0.55
    n = int(SAMPLE_RATE * dur)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        env = math.sin(math.pi * (i / n)) ** 1.2
        # Rotating pitch modulation (spinning blades)
        rot_freq = 6.0 # 6 rotations per second
        mod = math.sin(2 * math.pi * rot_freq * t)
        base_freq = 320.0 + mod * 140.0
        blade = math.sin(2 * math.pi * base_freq * t)
        noise = (random.random() * 2.0 - 1.0) * (0.6 + 0.3 * mod)
        val = (blade * 0.4 + noise * 0.6) * env * 0.85
        samples.append(val)
    return samples

# 13. FIREBALL: 화염 마법탄 발사 및 폭발 (화염 슛 + 쾅)
def make_fireball():
    dur = 0.45
    n = int(SAMPLE_RATE * dur)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 8.0)
        # Low boom sweep
        boom_freq = 180.0 * math.exp(-t * 12.0) + 40.0
        boom = math.sin(2 * math.pi * boom_freq * t)
        # Sizzling fire noise
        noise_env = math.sin(math.pi * min(1.0, t * 4.0)) * math.exp(-t * 6.0)
        noise = (random.random() * 2.0 - 1.0) * noise_env
        val = math.tanh((boom * 0.7 + noise * 0.8) * 1.5) * env * 0.9
        samples.append(val)
    return samples

# 14. BGM: 던전 배경음악 (16초 루프, 124BPM, 강력한 비트 & 신스 베이스 & 멜로디)
def make_bgm():
    dur = 16.0
    n = int(SAMPLE_RATE * dur)
    samples = [0.0] * n
    bpm = 124.0
    beat_dur = 60.0 / bpm
    total_beats = int(dur / beat_dur)

    # Chord roots (8 bars, each bar = 4 beats)
    roots = [146.83, 146.83, 174.61, 196.00, 146.83, 146.83, 220.00, 196.00] # Dm, Dm, F, G, Dm, Dm, Am, G

    for beat in range(total_beats):
        t_start = beat * beat_dur
        bar = (beat // 4) % len(roots)
        root = roots[bar] / 2.0 # ~73.4Hz D2
        
        # 1. Four-on-the-floor Punchy Kick
        k_start = int(t_start * SAMPLE_RATE)
        k_len = int(0.22 * SAMPLE_RATE)
        for j in range(k_len):
            idx = (k_start + j) % n
            t = j / SAMPLE_RATE
            k_env = math.exp(-t * 22.0)
            k_freq = 140.0 * math.exp(-t * 32.0) + 45.0
            samples[idx] += math.sin(2 * math.pi * k_freq * t) * k_env * 0.75
            
        # 2. Snare / Clap on beats 1 and 3
        if beat % 2 == 1:
            s_start = int(t_start * SAMPLE_RATE)
            s_len = int(0.18 * SAMPLE_RATE)
            for j in range(s_len):
                idx = (s_start + j) % n
                t = j / SAMPLE_RATE
                s_env = math.exp(-t * 20.0)
                noise = (random.random() * 2.0 - 1.0)
                tone = math.sin(2 * math.pi * 210.0 * t) * math.exp(-t * 30.0)
                samples[idx] += (noise * 0.6 + tone * 0.4) * s_env * 0.55
                
        # 3. Offbeat Hi-hat
        h_start = int((t_start + beat_dur * 0.5) * SAMPLE_RATE)
        h_len = int(0.08 * SAMPLE_RATE)
        for j in range(h_len):
            idx = (h_start + j) % n
            t = j / SAMPLE_RATE
            h_env = math.exp(-t * 55.0)
            samples[idx] += (random.random() * 2.0 - 1.0) * h_env * 0.28
            
        # 4. Driving Bass Synth (8th note pulse)
        for sub in [0.0, 0.5]:
            b_start = int((t_start + sub * beat_dur) * SAMPLE_RATE)
            b_len = int(beat_dur * 0.45 * SAMPLE_RATE)
            pitch = root * (1.5 if sub > 0 and beat % 2 == 1 else 1.0)
            for j in range(b_len):
                idx = (b_start + j) % n
                t = j / SAMPLE_RATE
                b_env = math.exp(-t * 8.0)
                saw = (math.sin(2 * math.pi * pitch * t) * 0.6 + 
                       math.sin(4 * math.pi * pitch * t) * 0.3 + 
                       math.sin(6 * math.pi * pitch * t) * 0.15)
                samples[idx] += saw * b_env * 0.45

    # 5. Lead Synth Melody (16th note arpeggios + theme)
    scale = [293.66, 349.23, 392.00, 440.00, 523.25, 587.33, 698.46]
    theme = [0, 2, 3, 5,  4, 3, 2, 0,  2, 3, 5, 6,  5, 4, 3, 2]

    steps = int(dur / (beat_dur / 4.0))
    for s in range(steps):
        step_t = s * (beat_dur / 4.0)
        note_f = scale[theme[s % len(theme)] % len(scale)]
        m_start = int(step_t * SAMPLE_RATE)
        m_len = int(0.18 * SAMPLE_RATE)
        for j in range(m_len):
            idx = (m_start + j) % n
            t = j / SAMPLE_RATE
            m_env = math.exp(-t * 12.0)
            lead = math.sin(2 * math.pi * note_f * t) + math.sin(4 * math.pi * note_f * t) * 0.25
            samples[idx] += lead * m_env * 0.32

    # Soft saturation compression for full punchy RMS
    comp_samples = [math.tanh(s * 1.35) * 0.92 for s in samples]
    return comp_samples

def main():
    write_wav("sounds/swing.wav", make_swing())
    write_wav("sounds/hit.wav", make_hit())
    write_wav("sounds/dash.wav", make_dash())
    write_wav("sounds/hurt.wav", make_hurt())
    write_wav("sounds/enemy_die.wav", make_enemy_die())
    write_wav("sounds/boss_spawn.wav", make_boss_spawn())
    write_wav("sounds/victory.wav", make_victory())
    write_wav("sounds/defeat.wav", make_defeat())
    write_wav("sounds/click.wav", make_btn_click())
    write_wav("sounds/gold.wav", make_gold())
    write_wav("sounds/potion.wav", make_potion())
    write_wav("sounds/whirlwind.wav", make_whirlwind())
    write_wav("sounds/fireball.wav", make_fireball())
    write_wav("sounds/dungeon_bgm.wav", make_bgm())
    print("All sounds & BGM generated successfully!")

if __name__ == "__main__":
    main()


