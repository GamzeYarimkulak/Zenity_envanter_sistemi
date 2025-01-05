# Zenity ile Basit Envanter ve Kullanıcı Yönetim Sistemi

Bu proje, **Zenity** aracıyla grafiksel bir arayüz sunarak bir envanter ve kullanıcı yönetim sistemi geliştirme amacı taşımaktadır. Sistem, **yönetici** ve **kullanıcı** rollerine göre farklı yetkiler tanır ve çeşitli işlevler sunar. Aşağıda sistemin kurulumu, kullanımı ve fonksiyonları detaylı bir şekilde açıklanmıştır.

---

## 🔧 Kurulum

Bu projeyi çalıştırmak için aşağıdaki adımları takip edebilirsiniz:

### Gerekli Araçlar
- **Linux Dağıtımı** (Ubuntu önerilir)
- **Zenity**
- Bash Kabuk Ortamı

### Zenity Kurulumu
Zenity'nin yüklü olup olmadığını kontrol edin:
```bash
zenity --version
```
Eğer Zenity yüklü değilse, aşağıdaki komutla kurabilirsiniz:
```bash
sudo apt update && sudo apt install zenity -y
```

### Proje Dosyalarının Kopyalanması
1. Bu projeyi yerel bilgisayarınıza kopyalayın:
```bash
git clone https://github.com/kullaniciadi/proje-reposu.git
cd proje-reposu
```

2. Betiği çalıştırılabilir yapmak için izin verin:
```bash
chmod +x odev.sh
```

---

## ⚡ Çalıştırma

Projenin ana betiğini çalıştırmak için:
```bash
./odev.sh
```
---

## 🔄 Sistem Fonksiyonları

### **1. Kullanıcı Girişi**
- **Yönetici** veya **Kullanıcı** olarak giriş yapabilirsiniz.
- 3 hatalı girişten sonra hesap kilitlenir.
- Hesap kilitlenirse, sadece yönetici tarafından açılabilir.

### **2. Ana Menü**
Ana menü, kullanıcının rolüne göre farklı seçenekler sunar:

#### **Yönetici Menüsü**:
- 🌐 **Envanter Yönetimi:**
  - Ürün ekleme, güncelleme, silme ve listeleme.
  - Stok raporlarını alma.
- 🔧 **Kullanıcı Yönetimi:**
  - Yeni kullanıcı ekleme, bilgileri güncelleme ve silme.
- 🔋 **Program Yönetimi:**
  - Disk alanını kontrol etme, dosyaları yedekleme ve hata kayıtlarını inceleme.

#### **Kullanıcı Menüsü**:
- Ürün listeleme.
- Stok raporlarını alma.

---

## 🔖 Envanter Fonksiyonları

### **Ürün Ekleme**
- Zenity formuyla yeni bir ürün eklenir.
- **Kontroller:**
  - Stok ve fiyat pozitif sayı mı?
  - Ürün adı veya kategori boşluk içeriyor mu?
  - Aynı isimde başka bir ürün var mı?

### **Ürün Listeleme**
- Mevcut ürünler bir tablo halinde listelenir.
- CSV dosyasından bilgiler okunur ve Zenity aracıyla gösterilir.

### **Ürün Güncelleme**
- Kullanıcıdan güncellenmek istenen ürün bilgileri alınır.
- Eski bilgiler silinir ve yeni bilgiler dosyaya eklenir.

### **Ürün Silme**
- Ürün adı alınır ve dosyadan silinir.
- Silme işlemi onay penceresi ile kontrol edilir.

---

## 🕵️ Kullanıcı Yönetimi

### **Kullanıcı Listeleme**
- Sistemde kayıtlı tüm kullanıcılar Zenity aracıyla listelenir.

### **Kullanıcı Güncelleme**
- Kullanıcı ID'si alınır.
- Yeni bilgiler form aracılığıyla girilir ve kaydedilir.

### **Kullanıcı Silme**
- Kullanıcı ID'si alınır ve kullanıcı dosyasından silinir.

---

## 📊 Raporlama

### **Stokta Azalan Ürünler**
- Kullanıcıdan bir stok eşik değeri istenir.
- Bu değerin altında kalan ürünler listelenir ve CSV dosyası olarak kaydedilir.

### **En Yüksek Stok Miktarına Sahip Ürünler**
- Envanterdeki en yüksek stok miktarına sahip ürünler listelenir.

---

## 🔋 Program Yönetimi

### **Disk Alanı Kontrolü**
- Sistemdeki tüm dosyaların boyutları hesaplanır ve toplam alan bilgisi görülür.

### **Yedekleme**
- `envanter.csv` ve `kullanicilar.csv` dosyaları tarih etiketi ile yedeklenir.

### **Hata Kıtları**
- `log.csv` dosyası incelenerek hata mesajları listelenir.

---

## ✅ Değerlendirme Soruları

Proje videosunda yanıtlanması gereken sorular:
1. Proje sırasında karşılaştığınız en büyük teknik sorun neydi ve nasıl çözdünüz?
2. Zenity kullanırken sizi en çok zorlayan kısım hangisiydi?
3. Bir hatayla karşılaştığınızda bunu çözmek için hangi adımları izlediniz?
4. Ürün güncelleme fonksiyonunu geliştirirken, aynı adı tasıyan ancak farklı kategorilerde olan ürünlerle nasıl başa çıktınız?
5. Kullanıcı programı beklenmedik şekilde kapatırsa veri kaybını önlemek için ne yaptınız?

---

## ✍ Yazarlar
Bu proje, **[isim ekleyin]** tarafından geliştirilmiştir.

---

## 🔗 GitHub
Projeye GitHub üzerinden erişim sağlayabilirsiniz: [Proje Linki](https://github.com/kullaniciadi/proje-reposu)

