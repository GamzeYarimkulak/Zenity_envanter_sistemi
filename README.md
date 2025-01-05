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

  
  ![WhatsApp Image 2025-01-05 at 20 51 12](https://github.com/user-attachments/assets/3eba262e-dbc9-4f1f-a71f-55dbaf8989de)



### **2. Ana Menü**
Ana menü, kullanıcının rolüne göre farklı seçenekler sunar:


![WhatsApp Image 2025-01-05 at 20 51 13](https://github.com/user-attachments/assets/af837ee6-31ae-48e5-909b-b6721eac87cf)

 

#### **Yönetici Menüsü**:
- 🌐 **Envanter Yönetimi:**
  - Ürün ekleme, güncelleme, silme ve listeleme.
  - Gelişmiş arama.
  - Stok raporlarını alma.
 
    
 ![WhatsApp Image 2025-01-05 at 20 51 13 (1)](https://github.com/user-attachments/assets/615ed73c-53aa-4ccc-b406-5550477b36d0)
 

![WhatsApp Image 2025-01-05 at 20 51 14 (1)](https://github.com/user-attachments/assets/e7460a1b-aab0-4241-97ae-5df8aebae266)



- 🔧 **Kullanıcı Yönetimi:**
  - Yeni kullanıcı ekleme, bilgileri güncelleme ve silme.
    
 
  ![WhatsApp Image 2025-01-05 at 20 51 14 (3)](https://github.com/user-attachments/assets/405980e3-d820-4b3c-acf8-40eb8d19fc59)

  
- 🔋 **Program Yönetimi:**
  - Disk alanını kontrol etme, dosyaları yedekleme ve hata kayıtlarını inceleme.
 
 
![WhatsApp Image 2025-01-05 at 20 51 14 (4)](https://github.com/user-attachments/assets/71523f8d-287d-4407-b89b-39f37fffffaf)



#### **Kullanıcı Menüsü**:
- Ürün listeleme.
- Gelişmiş arama.
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
-  Karşılaştığım en büyük teknik sorun csv dosyalarının doğru yönetilmesi konusuydu. Dosyalara yazma/okuma kısımlarında dosyay erişilme kısmında hatalar meydana geliyordu. Bunlar için her kritik işlem öncesi dosya varlığı ve erişim kontroller yaptım.
2. Zenity kullanırken sizi en çok zorlayan kısım hangisiydi?
-  Form bilgilerinin | (pipe) karakteri ile ayrılması ve cut komutu ile parse edilmesi kısmında zorlandım.
3. Bir hatayla karşılaştığınızda bunu çözmek için hangi adımları izlediniz?
-  Öncelikle hatalar log.error() fonksiyonu ile log.csv dosyasına kaydediliyor. Dosyayı kontrol edip hatanın ne olduğunu tespit ettikten sonra çözüm aşamalarına geçtim.
4. Ürün güncelleme fonksiyonunu geliştirirken, aynı adı tasıyan ancak farklı kategorilerde olan ürünlerle nasıl başa çıktınız?
-  Ürün güncellenirken sadece ad değil kategori bilgisi de alınıyor ve güncelleme sırasında eski kayıt tamamen siliniyor ardından yeni bilgilerle tekrar ekleniyor.
5. Kullanıcı programı beklenmedik şekilde kapatırsa veri kaybını önlemek için ne yaptınız?
-  Otomatik yedekleme fonksiyonu ile düzenli yedekleme yapılıyor. Her kritik işlem sonrası dosyalara flush yapılıyor.

---
### **Youtube linki**
Proje anlatımına youtube üzerinden erişim sağlayabilirsiniz: (

---

## 🔗 GitHub
Projeye GitHub üzerinden erişim sağlayabilirsiniz: (https://github.com/GamzeYarimkulak/Zenity_envanter_sistemi.git)

