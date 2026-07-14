# study_alarm — Sessiz Görsel Alarm

Kütüphane, ofis gibi ses çıkarılamayan ortamlarda, belirlenen saatte Safari'de tam ekran kırmızı sayfa açarak görsel uyarı verir.

## Kurulum

```bash
curl -fsSL https://raw.githubusercontent.com/eren9677/study-alarm/master/install.sh | bash
```

Dosyalar `~/Library/Application Support/study_alarm/` altına kurulur, `~/bin/study_alarm` symlink'i oluşturulur. Yeni terminal açıp `study_alarm --help` ile test edin.

Kaldırmak için: `study_alarm --uninstall`

## Kullanım

```bash
study_alarm 16:25                      # Saat 16:25'te çal
study_alarm 16.25                      # Nokta veya iki nokta fark etmez
study_alarm --in 15                    # 15 dakika sonra çal
study_alarm --in 70                    # 1 saat 10 dakika sonra çal
study_alarm --message "Toplantı!" 16:30  # Özel mesajlı alarm
study_alarm --test                     # 5 saniye sonra test et
study_alarm --status                   # Durumu / kalan süreyi göster
study_alarm --stop                     # Çalışan alarmı durdur
study_alarm --uninstall                # Programı tamamen kaldır
study_alarm --help                     # Tüm komutları listele
study_alarm 16:25 --force              # Mevcut alarmı iptal edip yenisini kur
```

## Gereksinimler

- macOS (Safari + Python 3 yüklü gelir)
- Başka hiçbir şey — sıfır bağımlılık, sıfır pip paketi

## Nasıl Çalışır

1. `study_alarm` bash wrapper'ı argümanları ayrıştırır, zamanı hesaplar
2. `alarm.py` arka planda geri sayım yapar (`nohup` + `caffeinate`)
3. Hedef saatte `alarm.html` şablonuna mesaj yerleştirilir, geçici dosya Safari'de açılır
4. Alarm sayfası: kırmızı arka plan, çalışma saati, özel mesaj
5. Kapatmak için **Cmd+W** — ses yok, sadece görsel

Terminali hemen kapatabilirsiniz, alarm arka planda çalışmaya devam eder.

## Hata Durumları

| Girdi | Sonuç |
|---|---|
| `study_alarm abc` | Geçersiz saat formatı |
| `study_alarm 25:99` | Saat 0-23, dakika 0-59 arasında olmalı |
| `study_alarm 08:00` (geçmiş) | Geçmişte kaldı hatası |
| `study_alarm 16:25 16:30` | Birden fazla saat girilemez |
| `study_alarm --in abc` | Sayı girin, harf kabul edilmez |
| `study_alarm --in` | Dakika değeri gerekli |
| `study_alarm --in 0` | Pozitif sayı girin |
| `study_alarm --in 1500` | En fazla 1440 dakika (24 saat) |
| `study_alarm --in 15 16:25` | --in ile saat birlikte kullanılamaz |
| `study_alarm --in 15 --test` | --in ile --test birlikte kullanılamaz |
| `study_alarm --xyz` | Bilinmeyen seçenek |

## Dosya Yapısı

```
study-alarm/
├── study_alarm       # Bash wrapper (tek giriş noktası)
├── alarm.py          # Python: geri sayım + Safari'yi açma
├── alarm.html        # HTML: kırmızı tam ekran sayfası
├── install.sh        # Tek komutla kurulum
└── uninstall.sh      # Alternatif kaldırma (manuel kullanım için)
```

Çalışma zamanı dosyaları (`/tmp/`):
- `study_alarm.pid` — çalışan alarmın PID'i
- `study_alarm.log` — geri sayım çıktısı
- `study_alarm.lock` — eşzamanlı çalıştırmayı önleyen kilit
