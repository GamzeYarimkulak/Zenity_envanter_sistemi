Envanter Yönetim Sistemi

Bu proje, Zenity kütüphanesini kullanarak kullanıcı dostu bir arayüz üzerinden çalışan bir Bash betiği olarak tasarlanmıştır. Sistem, kullanıcıların envanter bilgilerini yönetmesine, raporlar almasına ve kullanıcı hesaplarını kontrol etmesine olanak tanır.
Özellikler

    Kullanıcı Rolleri
        Yönetici ve Kullanıcı rolleri bulunur.
        Her rol için farklı yetkilendirme seviyeleri uygulanır.
    Envanter Yönetimi
        Ürün ekleme, güncelleme, silme ve listeleme işlemleri.
        Detaylı arama fonksiyonu.
    Kullanıcı Yönetimi
        Yeni kullanıcı ekleme, mevcut kullanıcıları listeleme, güncelleme ve silme.
        Kilitli hesapların açılması ve şifre sıfırlama.
    Raporlama
        Stokta azalan ürünler.
        En yüksek stok miktarına sahip ürünler.
    Yedekleme
        Otomatik ve manuel yedekleme fonksiyonları.
    Hata Loglama
        Sistem içerisindeki hatalar log.csv dosyasına kaydedilir.

Gereksinimler

    İşletim Sistemi: Linux
    Zenity: Arayüz desteği için gereklidir.
    Zenity’i aşağıdaki komutla yükleyebilirsiniz:

    sudo apt install zenity

Nasıl Kullanılır?

    Betiği çalıştırmadan önce gerekli dosyaları oluşturun:

    chmod +x odev.sh
    ./odev.sh

    Kullanıcı Girişi
        Sistem, kullanıcı adı ve şifre sorar.
        Yanlış bilgiler 3 kez girilirse sistemden çıkılır.

    Ana Menü
        Rollere bağlı olarak farklı işlem seçenekleri sunulur.

    Yedekleme
        Sistem, her çalıştırıldığında otomatik yedekleme yapar.

    Loglama
        Tüm hatalar log.csv dosyasında saklanır.

Fonksiyonlar
Kullanıcı Girişi

Kullanıcı adı ve şifre kontrol edilir. Kilitli hesaplar sistem tarafından engellenir.
Envanter Yönetimi

    Ekleme: Yeni ürün bilgileri girilir.
    Listeleme: Tüm envanter CSV formatında görüntülenir.
    Güncelleme: Belirli bir ürün bilgisi güncellenir.
    Silme: Ürün kalıcı olarak silinir.

Raporlama

    Stok Azaltma: Stok eşik değerine göre filtreleme yapılır.
    Yüksek Stok: En yüksek stoklu ürünler listelenir.

Kullanıcı Yönetimi

    Kullanıcı ekleme, güncelleme, silme ve listeleme.
    Kilitli hesapları açma ve şifre sıfırlama.

Dosya Yapısı

    envanter.csv: Envanter bilgilerini saklar.
        Format: ID,Ad,Stok,Fiyat,Kategori
    kullanicilar.csv: Kullanıcı bilgilerini saklar.
        Format: KullaniciID,Ad,Soyad,Rol,Sifre,Kilitli
    log.csv: Hata kayıtlarını saklar.
        Format: Tarih,Seviye,Mesaj

Ekran Görüntüleri

    Ana Menü: Kullanıcının rolüne göre farklı seçenekler sunar.
    Detaylı Arama: Ürünleri özelleştirilmiş kriterlere göre filtreleme.
    Raporlama: Detaylı raporlar Zenity arayüzünde görüntülenir.

Geliştirme Fikirleri

    API Entegrasyonu: Sistemi REST API ile daha genişletilebilir hale getirin.
    GUI Alternatifleri: YAD veya KDialog gibi alternatiflerle daha modern bir arayüz eklenebilir.
    Planlama: Zamanlanmış işler için crontab entegrasyonu.
