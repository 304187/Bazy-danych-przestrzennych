#####Aktualna data i data tworzenia skryptu####
$Data = Get-Date 
${TIMESTAMP}  = "{0:MM-dd-yyyy}" -f ($Data) 
$Data


function zwrocdate
{
    param()

    $data = Get-Date
    $data = "{0:yyyy-MM-dd HH:mm:ss}" -f ($data) 
    $data
}

function zapiszdoplikulog
{
    param($komunikat)

    $pobierzDate = zwrocdate
    $pobierzDate + " - $komunikat - ZAKOŃCZONE SUKCESEM!!!" >> "C:\Users\User\Desktop\cw9bazy\cwiczenie9_${TIMESTAMP}.log"
}

$path = "C:\Users\User\Desktop\cw9bazy\Cwiczenie9.ps1"
####Tworzenie changelog'a####
$data_skryptu = Get-ItemProperty $path | Format-Wide -Property CreationTime
"################  Change log ###################`n`nData utworzenia skryptu:" > "C:\Users\User\Desktop\cw9bazy\Cwiczenie9_${TIMESTAMP}.log"
#zapisuje date utworzenia
$data_skryptu >> "C:\Users\User\Desktop\cw9bazy\Cwiczenie9_${TIMESTAMP}.log"

####Pobranie pliku####
    
    
    #lokalizacja pliku źródłowego
    $adresUrl = "https://home.agh.edu.pl/~wsarlej/Customers_Nov2021.zip"
    #miejsce zapisu pliku
    $plik = "C:\Users\User\Desktop\cw9bazy\Customers_Nov2021.zip"
    #pobieranie pliku
    $webclient = New-Object System.Net.WebClient
    $webclient.DownloadFile($adresUrl, $plik)

    zapiszdoplikulog("Pobranie pliku")


####Rozpakowanie pliku####


    #ścieżka do winrara
    $WinRAR = "C:\Program Files\WinRAR\WinRAR.exe"
    $haslo = "agh"
    #ustawienie lokalizacji
    Set-Location C:\Users\User\Desktop\cw9bazy
    #rozpakowanie
    Start-Process "$WinRAR" -ArgumentList "x -y `"$plik`" -p$haslo"

    zapiszdoplikulog("Rozpakowanie pliku")


####Sprawdzanie poprawności pliku####


    #$nrIndeksu = Read-Host "Podaj numer indeksu: "
    $nrIndeksu = "304187"

    sleep 3
    $zawartoscPliku_1 = Get-Content "C:\Users\User\Desktop\cw9bazy\Customers_Nov2021.csv"
    $zawartoscPliku_2 = Get-Content "C:\Users\User\Desktop\cw9bazy\Customers_old.csv"

    #szuka pustych linii
    $plikBezPustychLini = for($i = 0; $i -lt $zawartoscPliku_1.Count; $i++)
    {
        if($zawartoscPliku_1[$i] -ne "")
        {
            $zawartoscPliku_1[$i]  
        }
    } 
    #plik z blednymi wierszami
    $plikBezPustychLini[0] > "C:\Users\User\Desktop\cw9bazy\Customers_Nov2021.bad_${TIMESTAMP}"
    #porównuje plik wejściowy z plikiem Customers_old.csv, pozostawia te wiersze, które nie występują w pliku Customers_old.csv
    for($i = 1; $i -lt $plikBezPustychLini.Count; $i++)
    {

        for($j = 0; $j -lt $zawartoscPliku_2.Count; $j++)
        {
            if($plikBezPustychLini[$i] -eq $zawartoscPliku_2[$j])
            {
                $plikBezPustychLini[$i] >> "C:\Users\User\Desktop\cw9bazy\Customers_Nov2021.bad_${TIMESTAMP}"
                $plikBezPustychLini[$i] = $null
            }
        }
    } 
    #końcowy plik po walidacji
    $plikBezPustychLini > "C:\Users\User\Desktop\cw9bazy\Customers_Nov2021.csv" 
    

    zapiszdoplikulog("Poprawność pliku")

####Tworzenie tabeli-postgres####
    
    #ustawienie lokalizacji
    Set-Location 'C:\Program Files\PostgreSQL\13\bin\'
    
    #logowanie postgres
    $User = "postgres"
    $env:PGPASSWORD = 'Scott1234'
    $Database = "postgres"
    $NewDatabase = "cwiczenie9_customers"
    $newTable = "CUSTOMERS_$nrIndeksu"
    $Serwer  ="PostgreSQL 13"
    $Port = "5432"
    
    #dodawanie tabeli
     psql -U postgres -d $Database -w -c "DROP DATABASE IF EXISTS $NewDatabase"
     psql -U postgres -d $NewDatabase -w -c "DROP TABLE IF EXISTS $newTable"
     psql -U postgres -d $Database -w -c "CREATE DATABASE $NewDatabase"
     psql -U postgres -d $NewDatabase -w -c "CREATE TABLE IF NOT EXISTS $newTable (first_name VARCHAR(100), last_name VARCHAR(100) PRIMARY KEY, email VARCHAR(100), lat VARCHAR(100) NOT NULL, long VARCHAR(100) NOT NULL)"

     zapiszdoplikulog("Tworzenie tabeli w PostgreSQL")

 ####Ładowanie danych z pliku do bazy w postgresie####
 
    #zamiana , na ","
    $poprawnyPlik2 = $poprawnyPlik -replace ",", "','"
    
    #wczytanie danych do tabeli
    for($i=1; $i -lt $poprawnyPlik2.Count; $i++)
    {
        $poprawnyPlik2[$i] = "'" + $poprawnyPlik2[$i] + "'"
        $wczytaj = $poprawnyPlik2[$i]
        psql -U postgres -d $env:NewDatabase -w -c "INSERT INTO $env:newTable (first_name, last_name, email, lat, long) VALUES($wczytaj)"
    }
    #wyświetlenie tabeli
    psql -U postgres -d $NewDatabase -w -c "SELECT * FROM $newTable"

    zapiszDoPlikuLog("Wczytanie danych z pliku do bazy")

 #####Przeniesienie pliku####
    #tworzenie katalogu PROCESSED
    New-Item -Path 'C:\Users\User\Desktop\cw9bazy\PROCESSED' -ItemType Directory

    Set-Location C:\Users\User\Desktop\cw9bazy
    #przeniesienie do podkatalogu i zmiana nazwy
    Move-Item -Path "C:\Users\User\Desktop\cw9bazy\Customers_Nov2021.csv" -Destination "C:\Users\User\Desktop\cw9bazy\PROCESSED" -PassThru -ErrorAction Stop
    Rename-Item -Path "C:\Users\User\Desktop\cw9bazy\PROCESSED\Customers_Nov2021.csv" "${TIMESTAMP}_Customers_Nov2021.csv"

    zapiszDoPlikuLog("Przeniesienie pliku")

 #####Wysłanie maila####
    
    #ponowne wczytanie pliku
    $Plikinternet = $plikBezPustychLini
    $poprawny_plik = Get-Content "C:\Users\User\Desktop\cw9bazy\PROCESSED\${TIMESTAMP}_Customers_Nov2021.csv"
    $plikbledy = Get-Content "C:\Users\User\Desktop\cw9bazy\Customers_Nov2021.bad_${TIMESTAMP}"

    #obliczenia
    $wszystkie_wiersze = $Plikinternet.Count
    $wszystkie_wiersze
    $wiersze_po_czyszeniu = $poprawny_plik.Count
    $wiersze_po_czyszeniu
    $duplikaty = $plikbledy.Count
    $duplikaty
    $dane_tabela = $poprawny_plik.Count -1
    $dane_tabela

    #wyslanie maila
    $MyEmail = "dmrenca2105@gmail.com"
    $SMTP= "smtp.gmail.com"
    $To = "dmrenca2105@gmail.com"
    $Subject = "CUSTOMERS LOAD - ${TIMESTAMP}"
    $Body =
    "liczba wierszy w pliku pobranym z internetu: $wszystkie_wiersze`n
    liczba poprawnych wierszy (po czyszczeniu): $wiersze_po_czyszeniu`n
    liczba duplikatow w pliku wejsciowym: $duplikaty`n 
    ilosc danych zaladowanych do tabeli: $dane_tabela `n"
    
    #uzyskanie danych uwierzytelniających
    $Creds = (Get-Credential -Credential "$MyEmail")

    Send-MailMessage -To $MyEmail -From $MyEmail -Subject $Subject -Body $Body -SmtpServer $SMTP -Credential $Creds -UseSsl -Port 587 -DeliveryNotificationOption never
   

    zapiszDoPlikuLog("Wysłanie pierwszego maila")

####Kwerenda SQL####
    
    #tworzenie pliku txt
     
     New-Item -Path 'C:\Users\User\Desktop\cw9bazy\zapytanie.txt' -ItemType File

    #wpisanie do pliku kwerendysql

    Set-Content -Path 'C:\Users\User\Desktop\cw9bazy\zapytanie.txt' -Value " 
    alter table CUSTOMERS_304187 alter column lat type double precision using lat::double precision;
    alter table CUSTOMERS_304187 alter column long type double precision using long::double precision;
    SELECT first_name, last_name  INTO best_customers_304187 FROM customers_304187
				WHERE ST_DistanceSpheroid( 
			ST_Point(lat, long), ST_Point(41.39988501005976, -75.67329768604034),
			'SPHEROID[""WGS 84"",6378137,298.257223563]') <= 50000"

    #tabela już istnieje?

    $NOWATABELA = "BEST_CUSTOMERS_304187"
    psql -U postgres -d $NewDatabase -w -c "DROP TABLE IF EXISTS $NOWATABELA"
    psql -U postgres -d $NewDatabase -w -c "CREATE TABLE IF NOT EXISTS $NOWATABELA (first_name VARCHAR(100), last_name VARCHAR(100) PRIMARY KEY, email VARCHAR(100), lat VARCHAR(100) NOT NULL, long VARCHAR(100) NOT NULL)"
    #uruchomienie zapytania
    
    psql -U postgres -d $NewDatabase -w -c "CREATE EXTENSION postgis"
    psql -U postgres -d $NewDatabase -w -f "C:\Users\User\Desktop\cw9bazy\zapytanie.txt"

    zapiszDoPlikuLog("Kwerenda SQL działa?")

####Eksport tabeli####
    
    #zapisywanie tabeli
    $zapis = psql -U postgres -d $NewDatabase -w -c "SELECT * FROM $NOWATABELA" 
    $zapis
    $tab = @()

    for ($i=2; $i -lt $zapis.Count-2; $i++)
    {
        $dane = New-Object -TypeName PSObject
        $dane | Add-Member -Name 'first_name' -MemberType Noteproperty -Value $zapis[$i].Split( "|")[0]
        $dane | Add-Member -Name 'last_name' -MemberType Noteproperty -Value $zapis[$i].Split( "|")[1]
        $dane | Add-Member -Name 'odleglosc' -MemberType Noteproperty -Value $zapis[$i].Split( "|")[2]
        $tab += $dane
    }

    #eksport tabeli

    $tab | Export-Csv -Path "C:\Users\User\Desktop\cw9bazy\$NOWATABELA.csv" -NoTypeInformation

    zapiszDoPlikuLog("Eksport tabeli")

####Kompresja pliku####

    Compress-Archive -Path "C:\Users\User\Desktop\cw9bazy\$NOWATABELA.csv" -DestinationPath "C:\Users\User\Desktop\cw9bazy\$NOWATABELA.zip"

    zapiszDoPlikuLog("Kompresja pliku")

####Wysłanie drugiego maila####

    #data utworzenia pliku
    
    Get-ItemProperty "C:\Users\User\Desktop\cw9bazy\$NOWATABELA.csv" | Format-Wide -Property CreationTime > "C:\Users\User\Desktop\cw9bazy\data.txt"
    $data = Get-Content "C:\Users\User\Desktop\cw9bazy\data.txt"

    Remove-Item -Path "C:\Users\User\Desktop\cw9bazy\data.txt"

    #zapisanie danych

    $wiersze = $zapis.Count -3
    $Skompresowany_plik = "C:\Users\User\Desktop\cw9bazy\$NOWATABELA.zip"

    #treść maila

    $Body2 = "`n`nData ostatniej modyfikacji pliku:$data
    Ilosc wierszy w pliku CSV:   $wiersze"
    
    #uzyskanie danych uwierzytelniających
    $Creds = (Get-Credential -Credential "$MyEmail")

    #wysłanie maila
    Send-MailMessage -To $To -From $MyEmail -Subject $Subject -Body $Body2 -Attachments $Skompresowany_plik -SmtpServer $SMTP -Credential $Creds -UseSsl -Port 587 -DeliveryNotificationOption never

    zapiszDoPlikuLog("Wysłanie drugiego maila")