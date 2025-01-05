#!/bin/bash

# Envanter Yonetim Sistemi - Tam Sistem
# Bu betik, Zenity kullanarak tam bir envanter yonetim sistemi sunar.
# Yonetici ve Kullanici rolleri icin islevler icermektedir.

WINDOW_WIDTH=800
WINDOW_HEIGHT=600
FORM_WIDTH=600
LIST_HEIGHT=500

# Gerekli dosyalari kontrol eder ve eger yoksa olusturur.
function init_files() {
    [[ ! -f envanter.csv ]] && echo "ID,Ad,Stok,Fiyat,Kategori" > envanter.csv  # Envanter dosyasi
    [[ ! -f kullanicilar.csv ]] && echo "KullaniciID,Ad,Soyad,Rol,Sifre,Kilitli" > kullanicilar.csv  # Kullanici dosyasi
    [[ ! -f log.csv ]] && echo "Tarih,Seviye,Mesaj" > log.csv  # Log dosyasi
    echo "Gerekli dosyalar kontrol edildi ve olusturuldu."
}

# Hata mesajlarini log.csv dosyasina kaydeder.
# $1: Hata mesaji
# $2: Hata ile iliskili kullanici
function log_error() {
    local hata_no=$(($(wc -l < log.csv) + 1))  # Hata numarasini belirler
    local mesaj="$1"  # Hata mesaji
    local kullanici="$2"  # Ilgili kullanici
    echo "$hata_no,$(date),HATA,$mesaj,$kullanici" >> log.csv
}

# Kullanici girisi icin islem yapar.
# Kullanici adi ve sifreyi kontrol eder, basariliysa kullanici rolunu dondurur.
function kullanici_girisi() {
    local deneme_hakki=3  # Giris icin toplam hak
    local kullanici_adi=""  # Kullanici adi
    local sifre=""  # Kullanici sifresi

    while [[ $deneme_hakki -gt 0 ]]; do
        # Kullanici adi ve sifresini Zenity arayuzunden al
        kullanici_adi=$(zenity --entry --title="Kullanici Girisi" --text="Kullanici adinizi girin:" --width=400)
        sifre=$(zenity --password --title="Kullanici Girisi" --text="Sifrenizi girin:" --width=400)

        # Kullanici bilgilerini kontrol et
        if grep -qE "^.*,${kullanici_adi}," kullanicilar.csv; then
            local rol=$(grep -E "^.*,${kullanici_adi}," kullanicilar.csv | cut -d ',' -f 4)
            local dogru_sifre=$(grep -E "^.*,${kullanici_adi}," kullanicilar.csv | cut -d ',' -f 5)
            local kilitli=$(grep -E "^.*,${kullanici_adi}," kullanicilar.csv | cut -d ',' -f 6)

            # Hesap kilitliyse cikis yap
            if [[ "$kilitli" == "yes" ]]; then
                zenity --error --text="Hesabiniz kilitlenmistir. Yonetici ile iletisime gecin."
                log_error "Kilitli hesap giris denemesi" "$kullanici_adi"
                exit 1
            fi

            # Sifre dogruysa giris basarili
            if [[ "$sifre" == "$dogru_sifre" ]]; then
                zenity --info --text="Giris basarili!"
                echo "$rol"
                return
            else
                deneme_hakki=$((deneme_hakki - 1))
                zenity --error --text="Hatali sifre! Kalan deneme hakkiniz: $deneme_hakki"

                # Hak biterse cikis yap
                if [[ $deneme_hakki -eq 0 ]]; then
                    zenity --error --text="3 kez hatali giris yaptiniz. Sistem kapanıyor."
                    log_error "3 hatali giris" "$kullanici_adi"
                    exit 1
                fi
            fi
        else
            deneme_hakki=$((deneme_hakki - 1))
            zenity --error --text="Kullanici bulunamadi! Kalan deneme hakkiniz: $deneme_hakki"

            if [[ $deneme_hakki -eq 0 ]]; then
                zenity --error --text="3 kez hatali giris yaptiniz. Sistem kapanıyor."
                log_error "Kullanici bulunamadi" "$kullanici_adi"
                exit 1
            fi
        fi
    done
}

# Kullanici yetkisini kontrol eder.
# $1: Kullanici rolu
# $2: Yapilmak istenen islem
function yetki_kontrol() {
    local rol="$1"
    local islem="$2"
    if [[ "$rol" != "Yonetici" ]]; then
        zenity --error --text="Bu islem icin yetkiniz yok: $islem"
        log_error "Yetkisiz islem denemesi" "$islem"
        return 1
    fi
    return 0
}

# Otomatik yedekleme islemi
function otomatik_yedekleme() {
    local tarih=$(date +%Y%m%d_%H%M%S)
    local yedek_klasor="yedekler/backup_$tarih"
    mkdir -p "$yedek_klasor"
    cp envanter.csv "$yedek_klasor/envanter.csv"
    cp kullanicilar.csv "$yedek_klasor/kullanicilar.csv"
    cp log.csv "$yedek_klasor/log.csv"
    echo "Otomatik yedekleme tamamlandi: $yedek_klasor" >> log.csv
}

# Urun arama islemi
function gelismis_arama() {
    local urun_adi=$(zenity --entry --title="🔍 Urun Arama" --text="Aramak istediginiz urunun adini girin:" --width=400)

    if [[ -z "$urun_adi" ]]; then
        zenity --info --text="Arama islemi iptal edildi." --width=300
        return
    fi

    local arama_sonuclari=$(awk -F',' -v ad="$urun_adi" 'NR>1 && tolower($2) ~ tolower(ad) {print $0}' envanter.csv)

    if [[ -z "$arama_sonuclari" ]]; then
        zenity --info --text="Arama kriterlerine uygun urun bulunamadi." --width=300
    else
        echo -e "ID,Ad,Stok,Fiyat,Kategori\n$arama_sonuclari" | zenity --text-info --title="🔍 Urun Arama Sonuclari" --width=600 --height=400
    fi
}

# Ana menu fonksiyonu
# Kullanici rolune gore farkli islem secenekleri sunar ve kullanici secimine gore ilgili islevi cagirir.
function ana_menu() {
    local rol=$1  # Kullanici rolu

    while true; do
        # Yonetici icin tum islemler
        if [[ "$rol" == "Yonetici" ]]; then
            secim=$(zenity --list --title="Envanter Yonetim Sistemi" \
                --column="Islem" \
                "Urun_Ekle" "Urun_Listele" "Urun_Guncelle" "Urun_Sil" \
                "Rapor_Al" "Gelismis_Arama" "Kullanici_Yonetimi" "Program_Yonetimi" "Cikis" \
                --width=$WINDOW_WIDTH --height=$WINDOW_HEIGHT)
        # Diger kullanicilar icin sinirli islemler
        else
            secim=$(zenity --list --title="Envanter Yonetim Sistemi" \
                --column="Islem" \
                "Urun_Listele" "Rapor_Al" "Gelismis_Arama" "Cikis" \
                --width=$WINDOW_WIDTH --height=$WINDOW_HEIGHT)
        fi

        # Kullanici secimine gore ilgili islevi cagirma
        case "$secim" in
            "Urun_Ekle") urun_ekle ;;  # Yeni urun ekleme
            "Urun_Listele") urun_listele ;;  # Mevcut urunleri listeleme
            "Urun_Guncelle") urun_guncelle ;;  # Urun bilgilerini guncelleme
            "Urun_Sil") urun_sil ;;  # Urun silme
            "Rapor_Al") rapor_al ;;  # Rapor olusturma
            "Gelismis_Arama") gelismis_arama ;;  # Urun arama
            "Kullanici_Yonetimi") kullanici_yonetimi ;;  # Kullanici yonetimi
            "Program_Yonetimi") program_yonetimi ;;  # Program yonetimi
            "Cikis")
                # Kullanici cikis yapmadan once onay alinir
                zenity --question --text="Cikmak istediginizden emin misiniz?" && exit 0
                ;;
            *) 
                # Hatali bir secim yapilirsa kullaniciya hata mesaji gosterilir
                zenity --error --text="Gecersiz secim!" 
                ;;
        esac
    done
}

# Sifre sifirlama fonksiyonu
# Kullanici adina gore sifreyi sifirlar.
function sifre_sifirla() {
    local kullanici_adi=$(zenity --entry --title="Sifre Sifirla" --text="Sifre sifirlamak istediginiz kullanici adini girin:" --width=400)
    local yeni_sifre=$(zenity --entry --title="Yeni Sifre" --text="Yeni sifrenizi girin:" --width=400)

    # Kullanici var mi kontrol edilir
    if grep -qE "^.*,${kullanici_adi}," kullanicilar.csv; then
        # Yeni sifreyi kullanicilar.csv dosyasina kaydet
        sed -i "s/^.*,${kullanici_adi},.*$/${kullanici_adi},${yeni_sifre}/" kullanicilar.csv
        zenity --info --text="Sifre basariyla sifirlandi!"
    else
        # Kullanici bulunamazsa hata mesaji gosterilir
        zenity --error --text="Kullanici bulunamadi!"
        log_error "Sifre sifirlama hatasi: Kullanici bulunamadi: $kullanici_adi"
    fi
}

# Kilitli hesap acma fonksiyonu
# Kullanici adina gore kilitli hesabi acmak icin kullanilir.
function kilitli_hesap_ac() {
    local kullanici_adi=$(zenity --entry --title="Kilitli Hesap Acma" --text="Kilitli hesabi acmak istediginiz kullanici adini girin:" --width=400)

    # Kullanici var mi kontrol edilir
    if grep -qE "^.*,${kullanici_adi}," kullanicilar.csv; then
        # Hesap kilidi kaldirilir
        sed -i "s/^.*,${kullanici_adi},.*$/&,no/" kullanicilar.csv
        zenity --info --text="Hesap basariyla acildi!"
    else
        # Kullanici bulunamazsa hata mesaji gosterilir
        zenity --error --text="Kullanici bulunamadi!"
        log_error "Kilitli hesap acma hatasi: Kullanici bulunamadi: $kullanici_adi"
    fi
}

# Urun ekleme fonksiyonu
# Yeni bir urun bilgisi alir ve envanter.csv dosyasina ekler.
function urun_ekle() {
    # Islemin durumunu gosteren progress bar
    (
        echo "0"; sleep 1
        echo "# Urun bilgileri kontrol ediliyor..."; sleep 1
        echo "50"; sleep 1
        echo "# Urun ekleniyor..."; sleep 1
        echo "100"; sleep 1
    ) | zenity --progress --title="Urun Ekleme" --text="Lutfen bekleyiniz..." --percentage=0
    
    # Kullaniciya urun bilgilerini girmesi icin form gosterilir
    urun_bilgisi=$(zenity --forms --title="Urun Ekle" \
        --text="Yeni urun bilgilerini girin" \
        --add-entry="Urun Adi" \
        --add-entry="Stok Miktari" \
        --add-entry="Birim Fiyati" \
        --add-entry="Kategori" \
        --width=400)

    # Urun bilgileri ayiklanir
    urun_adi=$(echo "$urun_bilgisi" | cut -d '|' -f 1)
    stok=$(echo "$urun_bilgisi" | cut -d '|' -f 2)
    fiyat=$(echo "$urun_bilgisi" | cut -d '|' -f 3)
    kategori=$(echo "$urun_bilgisi" | cut -d '|' -f 4)

    # Stok ve fiyat sayisal mi kontrol edilir
    if [[ ! "$stok" =~ ^[0-9]+(\.[0-9]+)?$ ]] || [[ ! "$fiyat" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        zenity --error --text="Stok ve fiyat pozitif sayi olmalidir."
        log_error "Gecersiz stok veya fiyat girisi: Stok=$stok, Fiyat=$fiyat"
        return
    fi

    # Urun adi ve kategori bosluk iceriyor mu kontrol edilir
    if [[ "$urun_adi" =~ \  ]] || [[ "$kategori" =~ \  ]]; then
        zenity --error --text="Urun adi ve kategori bosluk iceremez."
        log_error "Bosluklu urun adi veya kategori girildi: Ad=$urun_adi, Kategori=$kategori"
        return
    fi

    # Ayni isimde bir urun var mi kontrol edilir
    if grep -q "^.*,${urun_adi}," envanter.csv; then
        zenity --error --text="Bu urun adi ile baska bir kayit bulunmaktadir. Lutfen farkli bir ad giriniz."
        log_error "Ayni isimde urun ekleme denemesi: $urun_adi"
        return
    fi

    # Yeni urun numarasi hesaplanir ve envanter dosyasina eklenir
    urun_no=$(($(tail -n +2 envanter.csv | wc -l) + 1))
    echo "$urun_no,$urun_adi,$stok,$fiyat,$kategori" >> envanter.csv
    zenity --info --text="Urun basariyla eklendi!"
}

# Urun listeleme fonksiyonu
# Envanterdeki mevcut urunleri listeler
function urun_listele() {
    # Envanter dosyasinda veri olup olmadigini kontrol eder
    if [[ ! -s envanter.csv ]]; then
        # Envanter bos ise bilgi mesaji gosterilir
        zenity --info --text="Envanterde urun bulunmamaktadir." --width=300
    else
        # Envanteri goruntulemek icin bir metin bilgi penceresi acar
        zenity --text-info --title="Envanter Goruntuleme" \
            --filename=envanter.csv \
            --width=800 --height=400
    fi
}

# Urun guncelleme fonksiyonu
# Kullanici tarafindan belirtilen urunun bilgilerini gunceller
function urun_guncelle() {
    # Kullanici guncellemek istedigi urunun adini girer
    urun_adi=$(zenity --entry --title="Urun Guncelle" --text="Guncellemek istediginiz urunun adini girin:" --width=400)

    # Girdigi urun adi envanterde mevcut mu kontrol edilir
    if ! grep -q "^.*,${urun_adi}," envanter.csv; then
        # Urun bulunamadiysa hata mesaji gosterilir
        zenity --error --text="Bu urun adiyla kayit bulunamadi."
        log_error "Urun guncelleme hatasi: Urun bulunamadi: $urun_adi"
        return
    fi

    # Yeni bilgiler alinir
    yeni_stok=$(zenity --entry --title="Yeni Stok Miktari" --text="Yeni stok miktarini girin:" --width=400)
    yeni_fiyat=$(zenity --entry --title="Yeni Fiyat" --text="Yeni fiyati girin:" --width=400)
    kategori=$(zenity --entry --title="Kategori" --text="Yeni kategori bilgisini girin:" --width=400)

    # Stok ve fiyat degerlerinin sayisal oldugu kontrol edilir
    if [[ ! "$yeni_stok" =~ ^[0-9]+$ ]] || [[ ! "$yeni_fiyat" =~ ^[0-9]+$ ]]; then
        zenity --error --text="Stok ve fiyat pozitif sayi olmalidir."
        log_error "Gecersiz stok veya fiyat girisi: Stok=$yeni_stok, Fiyat=$yeni_fiyat"
        return
    fi

    # Eski urun bilgisi silinir ve yeni bilgi eklenir
    sed -i "/^.*,${urun_adi},/d" envanter.csv
    urun_no=$(($(tail -n +2 envanter.csv | wc -l) + 1))  # Yeni urun numarasi
    echo "$urun_no,$urun_adi,$yeni_stok,$yeni_fiyat,$kategori" >> envanter.csv

    # Basarili guncelleme mesaji
    zenity --info --text="Urun basariyla guncellendi!"
}

# Urun silme fonksiyonu
# Kullanici tarafindan belirtilen urunu envanterden siler
 
function urun_sil() {
    # Kullanici silmek istedigi urunun adini girer
    local Ad=$(zenity --entry --title="Urun Sil" --text="Silmek istediginiz urun adini girin:" --width=400)
    
    # Kullanici iptal ettiyse veya bos girdi yaptiysa
    if [[ -z "$Ad" ]]; then
        zenity --error --text="Urun adi bos olamaz!"
        return
    fi
    
    # Urunun varligi kontrol edilir (ikinci sütunda arama yapar)
    if ! grep -i ",[[:space:]]*$Ad," envanter.csv > /dev/null; then
        zenity --error --text="Urun bulunamadi: $Ad"
        return
    fi
    
    # Silinecek urunun detaylari gosterilir ve onay istenir
    local urun_detay=$(grep -i ",[[:space:]]*$Ad," envanter.csv)
    zenity --question --text="Bu urunu silmek istediginizden emin misiniz?\n\n$urun_detay" --width=400
    if [[ $? -eq 0 ]]; then
        # Kullanici onaylarsa urun silinir
        sed -i "/$Ad,/Id" envanter.csv
        zenity --info --text="Urun basariyla silindi."
    else
        # Kullanici iptal ederse islem sonlandirilir
        zenity --info --text="Urun silme islemi iptal edildi."
    fi
}
# Rapor alma fonksiyonu
# Kullaniciya farkli rapor turleri sunar
function rapor_al() {
    # Kullaniciya rapor turleri listelenir
    secim=$(zenity --list --title="Rapor Al" \
        --column="Rapor Turu" \
        "Stokta_Azalan_Urunler" "En_Yuksek_Stok_Miktarina_Sahip_Urunler" \
        --width=500 --height=300)

    # Kullanici secimine gore ilgili fonksiyon cagrilir
    case "$secim" in
        "Stokta_Azalan_Urunler") stokta_azalan_urunler ;;
        "En_Yuksek_Stok_Miktarina_Sahip_Urunler") en_yuksek_stok_urunler ;;
        *) 
            # Hatali secim yapilirsa hata mesaji gosterilir
            zenity --error --text="Gecersiz secim!" 
            ;;
    esac
}

# Stokta azalan urunler raporu
# Stokta azalan urunler raporu
function stokta_azalan_urunler() {
    esik_degeri=$(zenity --entry --title="Esik Degeri Belirle" --text="Lutfen stok esigini girin:" --width=400)
    
    if [[ ! "$esik_degeri" =~ ^[0-9]+$ ]]; then
        zenity --error --text="Esik degeri gecerli bir pozitif sayi olmalidir."
        return
    fi

    filtered=$(awk -v esik="$esik_degeri" -F',' 'NR>1 && $3 < esik {print}' envanter.csv)
    
    if [[ -z "$filtered" ]]; then
        zenity --info --text="Esik degerinin altinda urun bulunmamaktadir."
        return
    fi

    # Geçici bir dosya oluştur ve başlığı ekle
    temp_file=$(mktemp)
    echo "ID    Ad    Stok    Fiyat    Kategori" > "$temp_file"
    echo "-----------------------------------------" >> "$temp_file"
    echo "$filtered" | column -t -s',' >> "$temp_file"

    # Sonuçları text-info ile göster
    zenity --text-info \
        --title="Stokta Azalan Urunler (Esik: $esik_degeri)" \
        --filename="$temp_file" \
        --width=800 --height=400

    # Geçici dosyayı sil
    rm "$temp_file"

    # Raporu CSV olarak kaydet
    echo "ID,Ad,Stok,Fiyat,Kategori" > stokta_azalanlar.csv
    echo "$filtered" >> stokta_azalanlar.csv
}

# En yüksek stok miktarına sahip ürünleri listeleme fonksiyonu
function en_yuksek_stok_urunler() {
    max_stok=$(awk -F',' 'NR>1 {if($3 > max) max=$3} END {print max}' envanter.csv)
    filtered=$(awk -F',' -v max="$max_stok" 'NR>1 && $3 == max {print}' envanter.csv)
    
    if [[ -z "$filtered" ]]; then
        zenity --info --text="En yuksek stok miktarina sahip urun bulunamadi!"
        return
    fi

    # Geçici bir dosya oluştur ve başlığı ekle
    temp_file=$(mktemp)
    echo "ID    Ad    Stok    Fiyat    Kategori" > "$temp_file"
    echo "-----------------------------------------" >> "$temp_file"
    echo "$filtered" | column -t -s',' >> "$temp_file"

    # Sonuçları text-info ile göster
    zenity --text-info \
        --title="En Yuksek Stoklu Urunler (Stok: $max_stok)" \
        --filename="$temp_file" \
        --width=800 --height=400

    # Geçici dosyayı sil
    rm "$temp_file"

    # Raporu CSV olarak kaydet
    echo "ID,Ad,Stok,Fiyat,Kategori" > en_yuksek_stok.csv
    echo "$filtered" >> en_yuksek_stok.csv
}
# Kullanıcı yönetimi başlangıcı
# Eğer kullanıcı dosyası yoksa bir başlık satırı ekleyerek oluşturulur
if [ ! -f kullanicilar.csv ]; then
    echo "ID,Ad,Soyad,Rol,Sifre" > kullanicilar.csv
fi

# Kullanıcı yönetimi ana fonksiyonu
# Kullanıcılar üzerinde ekleme, listeleme, güncelleme ve silme işlemlerini gerçekleştirir
function kullanici_yonetimi() {
    while true; do
        # Kullanıcıdan yapılacak işlemi seçmesi istenir
        secim=$(zenity --list \
            --title="Kullanici Yonetimi" \
            --text="Lutfen bir islem secin" \
            --column="Islem" \
            "Yeni_Kullanici_Ekle" \
            "Kullanicilari_Listele" \
            "Kullanici_Guncelle" \
            "Kullanici_Sil" \
            "Cikis" \
            --width=400 --height=300)

        # Kullanıcı pencereyi kapatırsa veya çıkışı seçerse döngüden çıkılır
        if [ $? -ne 0 ]; then
            break
        fi

        # Seçime göre ilgili işlev çağrılır
        case "$secim" in
            "Yeni_Kullanici_Ekle")
                yeni_kullanici_ekle
                ;;
            "Kullanicilari_Listele")
                kullanicilari_listele
                ;;
            "Kullanici_Guncelle")
                kullanici_guncelle
                ;;
            "Kullanici_Sil")
                kullanici_sil
                ;;
            "Cikis")
                break
                ;;
            *)
                # Geçersiz bir seçim yapılırsa hata mesajı gösterilir
                zenity --error --text="Gecersiz secim! Lutfen tekrar deneyin."
                ;;
        esac
    done
}

# Yeni kullanıcı ekleme fonksiyonu
# Kullanıcıdan gerekli bilgileri alarak kullanıcı dosyasına ekler
function yeni_kullanici_ekle() {
    # Kullanıcıdan bilgiler istenir
    kullanici_bilgisi=$(zenity --forms --title="Yeni Kullanici Ekle" \
        --text="Yeni kullanici bilgilerini girin" \
        --add-entry="Ad" \
        --add-entry="Soyad" \
        --add-entry="Rol (Yonetici/Kullanici)" \
        --add-password="Sifre" \
        --width=400)

    # Bilgiler ayrıştırılır
    ad=$(echo "$kullanici_bilgisi" | cut -d '|' -f 1)
    soyad=$(echo "$kullanici_bilgisi" | cut -d '|' -f 2)
    rol=$(echo "$kullanici_bilgisi" | cut -d '|' -f 3)
    sifre=$(echo "$kullanici_bilgisi" | cut -d '|' -f 4)

    # Boş alanların kontrolü yapılır
    if [[ -z "$ad" || -z "$soyad" || -z "$rol" || -z "$sifre" ]]; then
        zenity --error --text="Tum alanlar doldurulmalidir!"
        return
    fi

    # Geçerli roller kontrol edilir
    if [[ "$rol" != "Yonetici" && "$rol" != "Kullanici" ]]; then
        zenity --error --text="Rol sadece 'Yonetici' veya 'Kullanici' olabilir!"
        return
    fi

    # Kullanıcı ID'si hesaplanır ve kullanıcı dosyasına eklenir
    kullanici_id=$(($(tail -n +2 kullanicilar.csv | wc -l) + 1))
    echo "$kullanici_id,$ad,$soyad,$rol,$sifre" >> kullanicilar.csv
    zenity --info --text="Kullanici basariyla eklendi!"
}

# Kullanıcıları listeleme fonksiyonu
# Kullanıcı dosyasındaki mevcut tüm kullanıcıları listeler
# Kullanicilar.csv dosyasındaki tüm kullanıcıları listeler
# Tüm kullanicilari listeler
function kullanicilari_listele() {
   # Önce dosyanın varlığını kontrol edelim
   if [[ ! -f kullanicilar.csv ]]; then
       zenity --error --text="Kullanicilar dosyasi bulunamadi!"
       return
   fi

   # Dosya içeriğini değişkene atalım
   KULLANICILAR=$(cat kullanicilar.csv)

   # İçerik boş değilse gösterelim
   if [[ ! -z "$KULLANICILAR" ]]; then
       echo "$KULLANICILAR" | column -t -s ',' | zenity --text-info \
           --title="Kullanici Listesi" \
           --width=600 \
           --height=400
   else
       zenity --info --text="Kayitli kullanici bulunmamaktadir."
   fi
}
# Kullanici Guncelle fonksiyonu
# Bu fonksiyon, mevcut bir kullanıcının bilgilerini güncellemek için kullanılır.
function kullanici_guncelle() {
    # Kullanıcı ID'sini al
    kullanici_id=$(zenity --entry --title="Kullanici Guncelle" --text="Guncellemek istediginiz kullanicinin ID'sini girin:" --width=400)

    # Kullanıcı ID'sinin geçerli olup olmadığını kontrol et
    if ! grep -q "^$kullanici_id," kullanicilar.csv; then
        zenity --error --text="Bu ID ile kayitli kullanici bulunamadi!"
        return
    fi

    # Yeni kullanıcı bilgilerini al
    yeni_bilgiler=$(zenity --forms --title="Kullanici Guncelle" \
        --text="Yeni kullanici bilgilerini girin" \
        --add-entry="Yeni Ad" \
        --add-entry="Yeni Soyad" \
        --add-entry="Yeni Rol (Yonetici/Kullanici)" \
        --add-password="Yeni Sifre" \
        --width=400)

    # Girilen bilgileri parçalara ayır
    yeni_ad=$(echo "$yeni_bilgiler" | cut -d '|' -f 1)
    yeni_soyad=$(echo "$yeni_bilgiler" | cut -d '|' -f 2)
    yeni_rol=$(echo "$yeni_bilgiler" | cut -d '|' -f 3)
    yeni_sifre=$(echo "$yeni_bilgiler" | cut -d '|' -f 4)

    # Alanların boş olup olmadığını kontrol et
    if [[ -z "$yeni_ad" || -z "$yeni_soyad" || -z "$yeni_rol" || -z "$yeni_sifre" ]]; then
        zenity --error --text="Tum alanlar doldurulmalidir!"
        return
    fi

    # Rolün geçerli olup olmadığını kontrol et
    if [[ "$yeni_rol" != "Yonetici" && "$yeni_rol" != "Kullanici" ]]; then
        zenity --error --text="Rol sadece 'Yonetici' veya 'Kullanici' olabilir!"
        return
    fi

    # Kullanıcı bilgilerini dosyaya güncelle
    sed -i "/^$kullanici_id,/c\\$kullanici_id,$yeni_ad,$yeni_soyad,$yeni_rol,$yeni_sifre" kullanicilar.csv
    zenity --info --text="Kullanici basariyla guncellendi!"
}

# Kullanici Sil fonksiyonu
# Bu fonksiyon, belirtilen ID'ye sahip kullanıcıyı siler.
function kullanici_sil() {
    # Silinecek kullanıcı ID'sini al
    kullanici_id=$(zenity --entry --title="Kullanici Sil" --text="Silmek istediginiz kullanicinin ID'sini girin:" --width=400)

    # Kullanıcı ID'sinin geçerli olup olmadığını kontrol et
    if ! grep -q "^$kullanici_id," kullanicilar.csv; then
        zenity --error --text="Bu ID ile kayitli kullanici bulunamadi!"
        return
    fi

    # Kullanıcıyı silmek için onay al
    zenity --question --text="Bu kullaniciyi silmek istediginizden emin misiniz?" && \
    sed -i "/^$kullanici_id,/d" kullanicilar.csv && \
    zenity --info --text="Kullanici basariyla silindi!" || \
    zenity --info --text="Silme islemi iptal edildi."
}

# Program yönetimi ana fonksiyonu
# Kullanıcıya seçim yapması için bir menü sunar.
function program_yonetimi() {
    while true; do
        # Ana menüde işlem seçimi yap
        secim=$(zenity --list \
            --title="Program Yonetimi" \
            --text="Lutfen bir islem secin" \
            --column="Islem" \
            "Diskteki_Alani_Goster" \
            "Diske_Yedekle" \
            "Hata_Kayitlarini_Goster" \
            "Cikis" \
            --width=400 --height=300)
            
        # Kullanıcı pencereyi kapattığında menüden çık
        if [ $? -ne 0 ]; then
            break
        fi

        # Seçilen işleme göre fonksiyon çağır
        case "$secim" in
            "Diskteki_Alani_Goster")
                disk_alani_goster
                ;;
            "Diske_Yedekle")
                diske_yedekle
                ;;
            "Hata_Kayitlarini_Goster")
                hata_kayitlari_goster
                ;;
            "Cikis")
                break
                ;;
            *)
                zenity --error --text="Gecersiz secim! Lutfen tekrar deneyin."
                ;;
        esac
    done
}

# Diskteki alanı gösteren fonksiyon
# Dosyaların boyutlarını gösterir ve toplam disk kullanımını hesaplar.
function disk_alani_goster() {
    # Dosyaların boyutlarını al
    odev_boyut=$(ls -lh odev.sh 2>/dev/null | awk '{print $5}')
    envanter_boyut=$(ls -lh envanter.csv 2>/dev/null | awk '{print $5}')
    kullanicilar_boyut=$(ls -lh kullanicilar.csv 2>/dev/null | awk '{print $5}')
    log_boyut=$(ls -lh log.csv 2>/dev/null | awk '{print $5}')
    
    # Toplam boyutu hesapla (KB cinsinden)
    toplam_boyut=$(ls -l odev.sh envanter.csv kullanicilar.csv log.csv 2>/dev/null | awk '{sum += $5} END {print sum/1024 "KB"}')
    
    # Sonuçları göster
    zenity --info --title="Disk Kullanimı" \
        --text="Dosya Boyutlari:\n\n\
odev.sh: ${odev_boyut:-'Dosya bulunamadi'}\n\
envanter.csv: ${envanter_boyut:-'Dosya bulunamadi'}\n\
kullanicilar.csv: ${kullanicilar_boyut:-'Dosya bulunamadi'}\n\
log.csv: ${log_boyut:-'Dosya bulunamadi'}\n\n\
Toplam Boyut: $toplam_boyut" \
        --width=300
}

# Yedekleme fonksiyonu
# Belirtilen dosyaları yedekler.
function diske_yedekle() {
    # Yedekleme klasörünü oluştur
    tarih=$(date +%Y%m%d_%H%M%S)
    yedek_klasor="yedek_$tarih"
    mkdir -p "$yedek_klasor"
    
    # Basarili yedekleme sayaci
    basarili=0
    
    # envanter.csv yedekle
    if [ -f envanter.csv ]; then
        cp envanter.csv "$yedek_klasor/envanter_$tarih.csv" && ((basarili++))
    fi
    
    # kullanicilar.csv yedekle
    if [ -f kullanicilar.csv ]; then
        cp kullanicilar.csv "$yedek_klasor/kullanicilar_$tarih.csv" && ((basarili++))
    fi
    
    # Sonuçları göster
    if [ $basarili -gt 0 ]; then
        zenity --info --title="Yedekleme Basarili" \
            --text="Dosyalar basariyla yedeklendi:\n\
$yedek_klasor/envanter_$tarih.csv\n\
$yedek_klasor/kullanicilar_$tarih.csv"
    else
        zenity --error --title="Yedekleme Hatasi" \
            --text="Yedeklenecek dosya bulunamadi!"
    fi
}

# Hata kayıtlarını gösteren fonksiyon
# log.csv dosyasındaki hata kayıtlarını kullanıcıya gösterir.
function hata_kayitlari_goster() {
    if [ -f log.csv ]; then
        # log.csv dosyasının içeriğini oku ve formatla
        log_icerik=$(awk -F',' 'NR>1 {print "Tarih: " $1 "\nSeviye: " $2 "\nMesaj: " $3 "\n---"}' log.csv)
        
        # Hata kaydı varsa göster
        if [ -z "$log_icerik" ]; then
            zenity --info --title="Hata Kayitlari" \
                --text="Henüz hic hata kaydi bulunmamaktadir."
        else
            echo "$log_icerik" | zenity --text-info \
                --title="Hata Kayitlari" \
                --width=500 --height=400
        fi
    else
        zenity --error --title="Dosya Bulunamadi" \
            --text="log.csv dosyasi bulunamadi!"
    fi
}

# Betiği başlat
init_files
rol=$(kullanici_girisi)
ana_menu "$rol"

