Bu scripti, powershell ile EXE ye çevirebilirsiniz.
Gerekli komutlar aşağıdadır.

Invoke-PS2EXE .\TXT Görüntüleyici-Kopyalayıcı.ps1 .\TXT Görüntüleyici-Kopyalayıcı.exe `
  -console `
  -noOutput `
  -requireAdmin:$false `
  -title "Hazır Metin Seçici"

EXE halide mevcuttur.

Ek olarak seçilen dizini Belgeler altında "HazirMetinSecici" adında gizli klasörün içindeki config text dosyasından çekmektedir.
