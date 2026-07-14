# Study Alarm (Sessiz Görsel Alarm)

Sessiz, tam ekran kırmızı bir görsel alarm. Kütüphane gibi ses çıkarılamayan ortamlarda, belirlenen saatte ekranı komple kırmızı yaparak uyarır. Slayt/ders çalışırken dalmamak için.

## File Structure

```
~/Desktop/çalışma alarmı/
├── alarm.py          # Main Python script (accepts time + management args)
├── alarm.html        # Fullscreen red page opened by Safari
├── study_alarm       # Shell wrapper — single entry point for everything
├── install.sh        # One-click install (symlinks to ~/bin)
└── README.md         # This file
```

Runtime files:
- `/tmp/study_alarm.pid` — PID of running alarm (auto-cleaned on completion)
- `/tmp/study_alarm.log` — Countdown output (persists for debugging, cleared on `--stop`)

## Install

```bash
cd ~/Desktop/çalışma\ alarmı
./install.sh
```

This creates `~/bin/study_alarm` symlink and adds `~/bin` to your PATH. Open a new terminal and run `study_alarm --help` to verify.

## Requirements

- macOS (uses Safari + AppleScript for fullscreen)
- Python 3
- Safari must have AppleScript/System Events permissions (macOS may prompt on first run)
- No external Python packages needed (stdlib only)

## Usage

```bash
study_alarm 16:25          # Set alarm for 16:25
study_alarm 16.25          # Same (dot or colon)
study_alarm --in 15        # Set alarm 15 minutes from now
study_alarm --in 70        # Set alarm 70 minutes (1h 10m) from now
study_alarm --test         # Fire a 5-second test alarm
study_alarm --stop         # Stop the currently running alarm
study_alarm --status       # Check alarm status / remaining time
study_alarm --help         # Show all commands
study_alarm 16:25 --force  # Override any existing alarm
```

The command **auto-backgrounds** — you can close the terminal immediately. `caffeinate` is applied automatically to prevent Mac from sleeping.

`--in N` mode accepts a minute value and automatically calculates the target time (e.g. `--in 70` → 1h 10m). The confirmation message shows both the target time and how many minutes remain.

When the alarm fires, press **ESC** to close the fullscreen Safari window.

## How It Works

1. Shell wrapper parses flags and manages the alarm lifecycle (start / stop / status)
2. Python script calculates remaining time, sleeps with a countdown
3. At target time, opens `alarm.html` in Safari — full red screen with alarm title,
   motivational message, and live clock
4. AppleScript sends `Cmd+Shift+F` to trigger Safari fullscreen
5. PID file cleaned up automatically; log file persists for debugging (`--stop` clears both)

No sound is produced at any point — purely visual.

## Error Handling

Both the shell wrapper and Python script validate input before launching:

| Input | Result |
|---|---|
| `study_alarm abc` | `HATA: Gecersiz saat formati` |
| `study_alarm 25:99` | `HATA: Saat 0-23 arasinda olmali` |
| `study_alarm 16:` | `HATA: Gecersiz saat formati` |
| `study_alarm 08:00` (past) | `HATA: gecmiste kaldi` |
| `study_alarm 16:25 16:30` | `HATA: Birden fazla saat` |
| `study_alarm --xyz` | `HATA: Bilinmeyen secenek` |
| `study_alarm --force` | `HATA: --force tek basina kullanilamaz` |
| `study_alarm --test 16:25` | `HATA: --test ile saat birlikte kullanilamaz` |
| `study_alarm --in` | `HATA: --in icin dakika degeri gerekli` |
| `study_alarm --in abc` | `HATA: --in icin gecerli bir sayi girin` |
| `study_alarm --in 0` | `HATA: --in icin pozitif bir sayi girin` |
| `study_alarm --in 15 16:25` | `HATA: --in ile saat birlikte kullanilamaz` |
| Missing `alarm.html` | `HATA: HTML dosyasi bulunamadi` |
| AppleScript fails | `UYARI: Tam ekran yapilamadi` (alarm still works) |

`--test` and `--in` modes skip the past-time check. `--in` also handles midnight wrap-around (e.g. `--in 15` at 23:50 sets alarm for 00:05).
