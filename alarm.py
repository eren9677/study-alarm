#!/usr/bin/env python3
import argparse
import os
import re
import subprocess
import sys
import tempfile
import time
from datetime import datetime, timedelta

def fail(msg):
    print(f"HATA: {msg}")
    sys.exit(1)

def cleanup_pid(pid_file):
    if pid_file and os.path.exists(pid_file):
        try:
            os.remove(pid_file)
        except OSError:
            pass

parser = argparse.ArgumentParser(add_help=False)
parser.add_argument("time_str", nargs="?", help="Target time in HH:MM format")
parser.add_argument("--pid-file", help="PID file for process management")
parser.add_argument("--test", action="store_true", help="Test mode: skip past-time check")
parser.add_argument("--in", dest="in_mode", action="store_true", help="In mode: time from --in flag")
parser.add_argument("--message", default=None, help="Custom message to display on alarm screen")
args = parser.parse_args()

if not args.time_str:
    cleanup_pid(args.pid_file)
    fail("Saat belirtilmedi. Ornek: 16:25")

cleaned = args.time_str.strip()
if not re.match(r'^\d{1,2}[.:]\d{2}$', cleaned):
    cleanup_pid(args.pid_file)
    fail(f"Gecersiz format: '{args.time_str}'. Dogru kullanim: 16:25 veya 9:05")

try:
    h, m = map(int, cleaned.replace(".", ":").split(":"))
except ValueError:
    cleanup_pid(args.pid_file)
    fail(f"Saat okunamadi: '{args.time_str}'. Ornek: 16:25")

if h < 0 or h > 23:
    cleanup_pid(args.pid_file)
    fail(f"Saat 0-23 arasinda olmali, girilen: {h}")
if m < 0 or m > 59:
    cleanup_pid(args.pid_file)
    fail(f"Dakika 0-59 arasinda olmali, girilen: {m}")

try:
    target = datetime.now().replace(hour=h, minute=m, second=0, microsecond=0)
except ValueError as e:
    cleanup_pid(args.pid_file)
    fail(f"Gecersiz zaman: {e}")

now = datetime.now()
if not args.test and not args.in_mode and now >= target:
    cleanup_pid(args.pid_file)
    fail(f"{target.strftime('%H:%M')} gecmiste kaldi. Ileri bir saat girin.")

if args.in_mode and now >= target:
    target += timedelta(days=1)
    now = datetime.now()

if now >= target:
    target = now
    print("Test modu: hemen calistiriliyor...")
else:
    print(f"Alarm kuruldu. Saat {target.strftime('%H:%M')}'te ekran kirmizi olacak.")
    print(f"Kalan sure: {str(target - now).split('.')[0]}")

    while datetime.now() < target:
        remaining = target - datetime.now()
        if remaining.seconds % 10 == 0 and remaining.seconds > 0:
            m = remaining.seconds // 60
            s = remaining.seconds % 60
            print(f"Kalan: {m}dk {s}sn", flush=True)
        time.sleep(1)

html_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "alarm.html")
if not os.path.isfile(html_path):
    cleanup_pid(args.pid_file)
    fail(f"HTML dosyasi bulunamadi: {html_path}")

message = args.message if args.message else "Belirlenen saat geldi — mola ver, kalk, hareket et."

with open(html_path, "r", encoding="utf-8") as f:
    html_content = f.read()

html_content = html_content.replace("__MESSAGE__", message)

tmp = tempfile.NamedTemporaryFile(mode="w", suffix=".html", delete=False, encoding="utf-8")
tmp.write(html_content)
tmp_path = tmp.name
tmp.close()

print("Safari aciliyor...", flush=True)
result = subprocess.run(["open", "-a", "Safari", tmp_path], capture_output=True, text=True)
if result.returncode != 0:
    os.unlink(tmp_path)
    cleanup_pid(args.pid_file)
    fail(f"Safari acilamadi: {result.stderr.strip()}")

print("ALARM! Ekran kirmizi. Kapatmak icin Cmd+W.")

cleanup_pid(args.pid_file)
time.sleep(2)
os.unlink(tmp_path)
sys.stdout.flush()
