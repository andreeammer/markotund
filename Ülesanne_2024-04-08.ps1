function Remove-Diacritics {
  param ([String]$src = [String]::Empty)
  $normalized = $src.Normalize([Text.NormalizationForm]::FormD)
  $sb = New-Object Text.StringBuilder
  $normalized.ToCharArray() | ForEach-Object { 
      if ([Globalization.CharUnicodeInfo]::GetUnicodeCategory($_) -ne [Globalization.UnicodeCategory]::NonSpacingMark) {
          [void]$sb.Append($_)
      }
  }
  $sb.ToString()
}

# Failide nimed
$failid = @("Eesnimed.txt", "Perenimed.txt", "Kirjeldused.txt")

# Kontrollime, kas kõik failid on olemas
foreach ($fail in $failid) {
  if (-not (Test-Path $fail)) {
      Write-Host "$fail puudub"
      return
  }
}

# Loeme failidest andmed
$eesnimed = Get-Content -Path "Eesnimed.txt" -Encoding UTF8
$perenimed = Get-Content -Path "Perenimed.txt" -Encoding UTF8
$kirjeldused = Get-Content -Path "Kirjeldused.txt" -Encoding UTF8

# Tühjendame faili, kui see on olemas
if (Test-Path "new_users_accounts.csv") {
  Remove-Item "new_users_accounts.csv"
}

# Küsime kasutajalt, kas soovitakse kasutada fikseeritud parooli
$paroolType = Read-Host "Kas soovite kasutada juhuslikku parooli (J) voi fikseeritud parooli (F)?"

# Kui valitakse fikseeritud parool, küsime seda kasutajalt
if ($paroolType -eq "F") {
  $fixedPassword = Read-Host "Sisestage fikseeritud parool (5-8 märki)"
}

# Lisame päise
Add-Content -Path "new_users_accounts.csv" -Value "Eesnimi;Perenimi;Kasutajanimi;Parool;Kirjeldus"

# Loome 5 kasutajat
for ($i=0; $i -lt 5; $i++) {
  $eesnimi = Get-Random -InputObject $eesnimed
  $perenimi = Get-Random -InputObject $perenimed
  $kirjeldus = Get-Random -InputObject $kirjeldused

  # Genereerime parooli vastavalt valikule
  if ($paroolType -eq "J") {
      $parool = -join ((65..90) + (97..122) + (48..57) | Get-Random -Count (Get-Random -Minimum 5 -Maximum 9) | ForEach-Object {[char]$_})
  } elseif ($paroolType -eq "F") {
      $parool = $fixedPassword
  }

  # Loome kasutajanime
  $kasutajanimi = Remove-Diacritics(("$eesnimi.$perenimi").ToLower().Replace(' ', '').Replace('-', ''))

  # Lisame uue rea CSV faili
  Add-Content -Path "new_users_accounts.csv" -Value "$eesnimi;$perenimi;$kasutajanimi;$parool;$kirjeldus" -Encoding utf8
}
Write-Host "Skript jooksis edukalt"