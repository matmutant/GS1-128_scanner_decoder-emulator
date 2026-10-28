#PS script that reads GS1-128 code coming from a datamatrix scanner to display individual keys, including control chars that are not printable.
#second stage feature is meant to parse and display content of the incoming data
#Mathieu GRIVOIS, 20261028 v2.0

Add-Type -AssemblyName System.Windows.Forms

function Extract-AIMID {

    param(
        [string]$Data
    )

    $result = [PSCustomObject]@{
        AIMID    = $null
        Data     = $Data
        Symbology = "Unknown"
    }

    #
    # AIM-ID = ] + 2 caractères
    # Exemple :
    # ]C1
    # ]d2
    # ]Q3
    #
    if ($Data.Length -ge 3 -and $Data[0] -eq ']') {

        $aim = $Data.Substring(0,3)

        $result.AIMID = $aim
        $result.Data  = $Data.Substring(3)

        switch ($aim) {

            "]C1" {
                $result.Symbology = "GS1-128"
            }

            "]d2" {
                $result.Symbology = "GS1 DataMatrix"
            }

            "]Q3" {
                $result.Symbology = "GS1 QR Code"
            }

            "]e0" {
                $result.Symbology = "EAN-13"
            }

            "]E0" {
                $result.Symbology = "EAN-8"
            }

            "]A0" {
                $result.Symbology = "Code 39"
            }

            default {
                $result.Symbology = "Unknown AIM-ID"
            }
        }
    }

    return $result
}

function Parse-GS1 {
    param (
        [string]$Data
    )

    $fields = [ordered]@{}
    $aiList = New-Object System.Collections.ArrayList

    $i = 0

    while ($i -lt $Data.Length) {

        # Ignorer les séparateurs GS
        if ([int][char]$Data[$i] -eq 29) {
            $i++
            continue
        }

        #
        # AI (01) GTIN
        #
        if (($i + 16) -le $Data.Length -and $Data.Substring($i,2) -eq "01") {

            $value = $Data.Substring($i + 2, 14)

            $fields.GTIN = $value

            [void]$aiList.Add([PSCustomObject]@{
                AI    = "01"
                Name  = "GTIN"
                Value = $value
            })

            $i += 16
            continue
        }

        #
        # AI (17) Expiry
        #
        if (($i + 8) -le $Data.Length -and $Data.Substring($i,2) -eq "17") {

            $raw = $Data.Substring($i + 2, 6)

            try {
                $value = [datetime]::ParseExact(
                    $raw,
                    "yyMMdd",
                    $null
                ).ToString("yyyy-MM-dd")
            }
            catch {
                $value = $raw
            }

            $fields.Expiry = $value

            [void]$aiList.Add([PSCustomObject]@{
                AI    = "17"
                Name  = "Expiry"
                Value = $value
            })

            $i += 8
            continue
        }

        #
        # AI (11) Production Date
        #
        if (($i + 8) -le $Data.Length -and $Data.Substring($i,2) -eq "11") {

            $raw = $Data.Substring($i + 2, 6)

            try {
                $value = [datetime]::ParseExact(
                    $raw,
                    "yyMMdd",
                    $null
                ).ToString("yyyy-MM-dd")
            }
            catch {
                $value = $raw
            }

            $fields.ProductionDate = $value

            [void]$aiList.Add([PSCustomObject]@{
                AI    = "11"
                Name  = "ProductionDate"
                Value = $value
            })

            $i += 8
            continue
        }

        #
        # AI (15) Best Before
        #
        if (($i + 8) -le $Data.Length -and $Data.Substring($i,2) -eq "15") {

            $raw = $Data.Substring($i + 2, 6)

            try {
                $value = [datetime]::ParseExact(
                    $raw,
                    "yyMMdd",
                    $null
                ).ToString("yyyy-MM-dd")
            }
            catch {
                $value = $raw
            }

            $fields.BestBefore = $value

            [void]$aiList.Add([PSCustomObject]@{
                AI    = "15"
                Name  = "BestBefore"
                Value = $value
            })

            $i += 8
            continue
        }

        #
        # AI (10) Lot
        #
        if (($i + 2) -le $Data.Length -and $Data.Substring($i,2) -eq "10") {

            $start = $i + 2
            $end = $Data.IndexOf([char]29, $start)

            if ($end -eq -1) {
                $end = $Data.Length
            }

            $value = $Data.Substring($start, $end - $start)

            $fields.Lot = $value

            [void]$aiList.Add([PSCustomObject]@{
                AI    = "10"
                Name  = "Lot"
                Value = $value
            })

            $i = $end
            continue
        }

        #
        # AI (21) Serial
        #
        if (($i + 2) -le $Data.Length -and $Data.Substring($i,2) -eq "21") {

            $start = $i + 2
            $end = $Data.IndexOf([char]29, $start)

            if ($end -eq -1) {
                $end = $Data.Length
            }

            $value = $Data.Substring($start, $end - $start)

            $fields.Serial = $value

            [void]$aiList.Add([PSCustomObject]@{
                AI    = "21"
                Name  = "Serial"
                Value = $value
            })

            $i = $end
            continue
        }

        #
        # AI (240) Additional ID
        #
        if (($i + 3) -le $Data.Length -and $Data.Substring($i,3) -eq "240") {

            $start = $i + 3
            $end = $Data.IndexOf([char]29, $start)

            if ($end -eq -1) {
                $end = $Data.Length
            }

            $value = $Data.Substring($start, $end - $start)

            $fields.AdditionalID = $value

            [void]$aiList.Add([PSCustomObject]@{
                AI    = "240"
                Name  = "AdditionalID"
                Value = $value
            })

            $i = $end
            continue
        }

        #
        # AI (241) Customer Part Number
        #
        if (($i + 3) -le $Data.Length -and $Data.Substring($i,3) -eq "241") {

            $start = $i + 3
            $end = $Data.IndexOf([char]29, $start)

            if ($end -eq -1) {
                $end = $Data.Length
            }

            $value = $Data.Substring($start, $end - $start)

            $fields.CustomerPart = $value

            [void]$aiList.Add([PSCustomObject]@{
                AI    = "241"
                Name  = "CustomerPart"
                Value = $value
            })

            $i = $end
            continue
        }

        # AI inconnue ou donnée non interprétée
        $i++
    }

    return [PSCustomObject]@{
        Fields = [PSCustomObject]$fields
        AIList = $aiList
    }
}

Write-Host ""
Write-Host "====================================================="
Write-Host "GS1 Scanner Debug Tool"
Write-Host "====================================================="
Write-Host "Scannez un code puis appuyez sur Entrée"
Write-Host ""

$buffer = ""

while ($true) {

    if ([Console]::KeyAvailable) {

        $k = [Console]::ReadKey($true)

        if ($k.Key -eq "Enter") {

            Clear-Host

Write-Host ""
Write-Host "DEBUG:"
Write-Host ("BUFFER LENGTH : {0}" -f $buffer.Length)

for($i=0; $i -lt [Math]::Min(10,$buffer.Length); $i++) {
    Write-Host ("[{0}] '{1}' 0x{2:X2}" -f $i,$buffer[$i],[int][char]$buffer[$i])
}
            Write-Host ""
            Write-Host "====================================================="
            Write-Host "TRAME BRUTE"
            Write-Host "====================================================="
            Write-Host $buffer

            #
            # Trame visualisée
            #
            $visible = $buffer.Replace([string][char]29, "<GS>")

            Write-Host ""
            Write-Host "====================================================="
            Write-Host "TRAME VISUALISEE"
            Write-Host "====================================================="
            Write-Host $visible

            #
            # Trame échappée
            #
            $escaped = ""

            foreach ($c in $buffer.ToCharArray()) {

                if ([int][char]$c -eq 29) {
                    $escaped += "\x1D"
                }
                else {
                    $escaped += $c
                }
            }

            Write-Host ""
            Write-Host "====================================================="
            Write-Host "TRAME ECHAPPEE"
            Write-Host "====================================================="
            Write-Host $escaped

            #
            # Dump ASCII / HEX
            #
            Write-Host ""
            Write-Host "====================================================="
            Write-Host "ASCII / HEX"
            Write-Host "====================================================="

            foreach ($c in $buffer.ToCharArray()) {

                $ascii = [int][char]$c

                if ($ascii -eq 29) {
                    "{0,-5} 0x{1:X2} <GS>" -f $ascii, $ascii
                }
                else {
                    "{0,-5} 0x{1:X2} '{2}'" -f $ascii, $ascii, $c
                }
            }


            #
            # Parsing GS1
	    # Extraction des potentiels AIMID
            $aimInfo = Extract-AIMID $buffer
	    # Parsing des données
            $parsed = Parse-GS1 $aimInfo.Data


            Write-Host ""
            Write-Host "====================================================="
            Write-Host "IDENTIFICATION SYMBOLOGIE"
            Write-Host "====================================================="

            if ($aimInfo.AIMID) {

                Write-Host ("AIM-ID     : {0}" -f $aimInfo.AIMID)
                Write-Host ("Symbology : {0}" -f $aimInfo.Symbology)

            }
            else {

                Write-Host "Aucun AIM-ID détecté"

            }

            #
	    # Display of parsed data
	    #
            Write-Host ""
            Write-Host "====================================================="
            Write-Host "DONNEES DECODEES"
            Write-Host "====================================================="

            if ($parsed.Fields.PSObject.Properties.Count -gt 0) {
                $parsed.Fields | Format-List
            }
            else {
                Write-Host "Aucune donnée GS1 reconnue."
            }

            #
            # Liste AI dans l'ordre réel de la trame
            #
            Write-Host ""
            Write-Host "====================================================="
            Write-Host "AIs DETECTES (ORDRE REEL)"
            Write-Host "====================================================="

            if ($parsed.AIList.Count -gt 0) {

                foreach ($ai in $parsed.AIList) {
                    "{0,-4} {1,-18} {2}" -f $ai.AI, $ai.Name, $ai.Value
                }

            }
            else {

                Write-Host "Aucun AI reconnu."

            }

            Write-Host ""
            Write-Host "====================================================="
            Write-Host "PRET POUR UN NOUVEAU SCAN"
            Write-Host "====================================================="
            Write-Host ""

            $buffer = ""
            Start-Sleep -Milliseconds 50
            while ([Console]::KeyAvailable) {
                [Console]::ReadKey($true) | Out-Null
            }

            break
        }
        else {
            $buffer += $k.KeyChar
        }
    }

    Start-Sleep -Milliseconds 10
}
