Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Globalization

$ti = (Get-Culture).TextInfo

function Format-Hitap($text) {
    return $ti.ToTitleCase($text.ToLower())
}

# =====================
# AYAR
# =====================
# $DefaultPath = "BAŞLANGIÇTA GÖRÜNTÜLEYEBİLMEK İÇİN DİZİN GİRİN"

# =====================
# FORM
# =====================
$form = New-Object System.Windows.Forms.Form
$form.Text = "Hazır Metinler"
$form.Size = New-Object System.Drawing.Size(650,420)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.MinimizeBox = $true

# =====================
# ÜST KLASÖR LABEL
# =====================
$lblFolder = New-Object System.Windows.Forms.Label
$lblFolder.Location = New-Object System.Drawing.Point(10,12)
$lblFolder.Size = New-Object System.Drawing.Size(620,20)
$lblFolder.Font = New-Object System.Drawing.Font("Segoe UI",9,[System.Drawing.FontStyle]::Bold)
$form.Controls.Add($lblFolder)

# =====================
# KLASÖR SEÇ BUTONU
# =====================
$btnSelectFolder = New-Object System.Windows.Forms.Button
$btnSelectFolder.Text = "Klasör Seç"
$btnSelectFolder.Location = New-Object System.Drawing.Point(10,35)
$btnSelectFolder.Size = New-Object System.Drawing.Size(100,28)
$form.Controls.Add($btnSelectFolder)

# =====================
# MANUEL DİZİN
# =====================
$txtPath = New-Object System.Windows.Forms.TextBox
$txtPath.Location = New-Object System.Drawing.Point(120,36)
$txtPath.Size = New-Object System.Drawing.Size(510,26)
$form.Controls.Add($txtPath)

# =====================
# HİTAP LABEL
# =====================
$lblHitap = New-Object System.Windows.Forms.Label
$lblHitap.Location = New-Object System.Drawing.Point(270,70)
$lblHitap.Size = New-Object System.Drawing.Size(250,20)
$lblHitap.Font = New-Object System.Drawing.Font("Segoe UI",8,[System.Drawing.FontStyle]::Italic)
$lblHitap.ForeColor = [System.Drawing.Color]::DimGray
$lblHitap.Text = "Hitap Edilecek Kişiyi Girin."
$form.Controls.Add($lblHitap)

# =====================
# HİTAP TEXTBOX (Placeholderlı)
# =====================
$txtHitap = New-Object System.Windows.Forms.TextBox
$txtHitap.Location = New-Object System.Drawing.Point(10,65)
$txtHitap.Size = New-Object System.Drawing.Size(250,26)
$txtHitap.Font = New-Object System.Drawing.Font("Segoe UI",9)

$placeholderText = "Örn: Ahmet Bey / Ayşe Hanım"
$txtHitap.Text = $placeholderText
$txtHitap.ForeColor = [System.Drawing.Color]::Gray

$form.Controls.Add($txtHitap)

# =====================
# TXT LİSTESİ
# =====================
$listBox = New-Object System.Windows.Forms.ListBox
$listBox.Location = New-Object System.Drawing.Point(10,100)
$listBox.Size = New-Object System.Drawing.Size(250,250)
$form.Controls.Add($listBox)

# =====================
# SAĞ İÇERİK
# =====================
$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Location = New-Object System.Drawing.Point(270,100)
$textBox.Size = New-Object System.Drawing.Size(360,210)
$textBox.Multiline = $true
$textBox.ScrollBars = "Both"
$textBox.ReadOnly = $true
$textBox.Font = New-Object System.Drawing.Font("Consolas",9)
$form.Controls.Add($textBox)

# =====================
# KOPYALA
# =====================
$btnCopy = New-Object System.Windows.Forms.Button
$btnCopy.Text = "Kopyala"
$btnCopy.Location = New-Object System.Drawing.Point(270,330)
$btnCopy.Size = New-Object System.Drawing.Size(120,28)
$form.Controls.Add($btnCopy)

# =====================
# BİLDİRİM
# =====================
$lblStatus = New-Object System.Windows.Forms.Label
$lblStatus.Location = New-Object System.Drawing.Point(410,335)
$lblStatus.Size = New-Object System.Drawing.Size(180,20)
$lblStatus.Font = New-Object System.Drawing.Font("Segoe UI",9,[System.Drawing.FontStyle]::Bold)
$lblStatus.ForeColor = [System.Drawing.Color]::Green
$lblStatus.Text = "Kopyalandı ✔"
$lblStatus.Visible = $false
$form.Controls.Add($lblStatus)

$statusTimer = New-Object System.Windows.Forms.Timer
$statusTimer.Interval = 2000
$statusTimer.Add_Tick({
    $lblStatus.Visible = $false
    $statusTimer.Stop()
})

$minimizeTimer = New-Object System.Windows.Forms.Timer
$minimizeTimer.Interval = 500
$minimizeTimer.Add_Tick({
    $form.WindowState = "Minimized"
    $minimizeTimer.Stop()
})

$fileMap = @{}

function Show-Content {
    if ($listBox.SelectedItem -ne $null) {
        $key = $listBox.SelectedItem
        if ($fileMap.ContainsKey($key)) {

            $content = Get-Content $fileMap[$key] -Raw -Encoding UTF8

            if ($txtHitap.Text.Trim() -ne "" -and $txtHitap.Text -ne $placeholderText) {
                $prefix = "Merhaba $($txtHitap.Text)`r`n`r`n"
                $textBox.Text = $prefix + $content
            }
            else {
                $textBox.Text = $content
            }
        }
    }
}

function Load-TxtFiles($basePath) {

    if (-not (Test-Path $basePath)) { return }

    $lblFolder.Text = "Klasör: " + (Split-Path $basePath -Leaf)
    $listBox.Items.Clear()
    $fileMap.Clear()
    $textBox.Clear()

    $files = Get-ChildItem $basePath -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object { $_.Extension -in ".txt",".lnk" }

    foreach ($file in $files) {

        if ($file.Extension -eq ".txt") {
            $listBox.Items.Add($file.Name)
            $fileMap[$file.Name] = $file.FullName
        }
        elseif ($file.Extension -eq ".lnk") {
            $wsh = New-Object -ComObject WScript.Shell
            $sc = $wsh.CreateShortcut($file.FullName)
            if ($sc.TargetPath -and $sc.TargetPath.EndsWith(".txt")) {
                $listBox.Items.Add($file.Name)
                $fileMap[$file.Name] = $sc.TargetPath
            }
        }
    }
}

# =====================
# EVENTLER
# =====================

$listBox.Add_SelectedIndexChanged({ Show-Content })

$txtHitap.Add_Enter({
    if ($txtHitap.Text -eq $placeholderText) {
        $txtHitap.Text = ""
        $txtHitap.ForeColor = [System.Drawing.Color]::Black
    }
})

$txtHitap.Add_Leave({
    if ([string]::IsNullOrWhiteSpace($txtHitap.Text)) {
        $txtHitap.Text = $placeholderText
        $txtHitap.ForeColor = [System.Drawing.Color]::Gray
    }
    else {
        $txtHitap.Text = Format-Hitap $txtHitap.Text
        Show-Content
    }
})

$txtHitap.Add_KeyDown({
    if ($_.KeyCode -eq "Enter") {
        $txtHitap.Text = Format-Hitap $txtHitap.Text
        Show-Content
    }
})

$btnCopy.Add_Click({
    if ($textBox.Text) {
        [System.Windows.Forms.Clipboard]::SetText($textBox.Text)
        $lblStatus.Visible = $true
        $statusTimer.Start()
        $minimizeTimer.Start()
    }
})

$txtPath.Add_KeyDown({
    if ($_.KeyCode -eq "Enter") {
        if (Test-Path $txtPath.Text) {
            Load-TxtFiles $txtPath.Text
        }
        else {
            [System.Windows.Forms.MessageBox]::Show("Geçerli bir dizin giriniz.")
        }
    }
})

$btnSelectFolder.Add_Click({
    $fd = New-Object System.Windows.Forms.FolderBrowserDialog
    if ($fd.ShowDialog() -eq "OK") {
        $txtPath.Text = $fd.SelectedPath
        Load-TxtFiles $fd.SelectedPath
    }
})

$form.Add_Shown({
    if (Test-Path $DefaultPath) {
        $txtPath.Text = $DefaultPath
        Load-TxtFiles $DefaultPath
    }
})

[void]$form.ShowDialog()
