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
    print("All sounds generated successfully!")

if __name__ == "__main__":
    main()

