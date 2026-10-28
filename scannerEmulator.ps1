#simple PS script that emulates a barcode/datamatrix scanner sending GS1-128 code to a parser.
#Mathieu GRIVOIS, 20261023 v2.0

param(

    [ValidateSet(1,2)]
    [int]$Order = 1,

    # AIM-ID optionnel
    [string]$AIMID = "]d2",

    # AI fixes
    [string]$GTIN = "18437006085042",      # AI 01
    [string]$Expiry = "271231",            # AI 17
    [string]$ProductionDate = "",          # AI 11
    [string]$BestBefore = "",              # AI 15

    # AI variables
    [string]$Lot = "LOT123456",            # AI 10
    [string]$Serial = "SER987654321",      # AI 21
    [string]$AdditionalID = "",            # AI 240
    [string]$CustomerPart = "",            # AI 241

    [int]$DelaySeconds = 5
)

Add-Type -AssemblyName System.Windows.Forms

$GS = [char]29

function New-AI {
    param(
        [string]$AI,
        [string]$Value
    )

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return $null
    }

    return $AI + $Value
}

Write-Host "Envoi du code GS1 dans $DelaySeconds secondes..."
Start-Sleep -Seconds $DelaySeconds

#
# Construction des AI fixes
#

$barcode = ""

if ($AIMID) {
    $barcode += $AIMID
}

$barcode += New-AI "01" $GTIN
$barcode += New-AI "17" $Expiry
$barcode += New-AI "11" $ProductionDate
$barcode += New-AI "15" $BestBefore

#
# Construction des AI variables
#

$variableFields = @()

if ($Order -eq 1) {

    if ($Lot)          { $variableFields += ("10"  + $Lot) }
    if ($Serial)       { $variableFields += ("21"  + $Serial) }
    if ($AdditionalID) { $variableFields += ("240" + $AdditionalID) }
    if ($CustomerPart) { $variableFields += ("241" + $CustomerPart) }

}
else {

    if ($Serial)       { $variableFields += ("21"  + $Serial) }
    if ($Lot)          { $variableFields += ("10"  + $Lot) }
    if ($AdditionalID) { $variableFields += ("240" + $AdditionalID) }
    if ($CustomerPart) { $variableFields += ("241" + $CustomerPart) }

}

#
# Les champs à longueur variable doivent être séparés
# par GS sauf le dernier.
#

for ($i = 0; $i -lt $variableFields.Count; $i++) {

    $barcode += $variableFields[$i]

    if ($i -lt ($variableFields.Count - 1)) {
        $barcode += $GS
    }
}

#
# Affichage configuration
#

Write-Host ""
Write-Host "Configuration envoyée"
Write-Host "---------------------"
Write-Host "AIM-ID         : $AIMID"
Write-Host "Order          : $Order"
Write-Host "GTIN           : $GTIN"
Write-Host "Expiry         : $Expiry"
Write-Host "ProductionDate : $ProductionDate"
Write-Host "BestBefore     : $BestBefore"
Write-Host "Lot            : $Lot"
Write-Host "Serial         : $Serial"
Write-Host "AdditionalID   : $AdditionalID"
Write-Host "CustomerPart   : $CustomerPart"
Write-Host ""

#
# Trame lisible
#

$visible = $barcode.Replace(
    [string][char]29,
    [string][char]0x241D
)

Write-Host "Trame visualisée :"
Write-Host $visible
Write-Host ""

#
# Trame HEX
#

$hex = ($barcode.ToCharArray() | ForEach-Object {
    "{0:X2}" -f [int][char]$_
}) -join " "

Write-Host "Trame HEX :"
Write-Host $hex
Write-Host ""

#
# Envoi
#

[System.Windows.Forms.SendKeys]::SendWait($barcode)
[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
