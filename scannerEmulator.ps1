#simple PS script that emulates a barcode/datamatrix scanner sending GS1-128 code to a parser.
#Mathieu GRIVOIS, 20261023 v1.1

param(
    [ValidateSet(1, 2)]
    [int]$Order = 1,

    [string]$GTIN = "18437006085042", #GTIN (UCD, CIP, UDI)

    [string]$Expiry = "271231", #YYMMDD

    [string]$Lot = "LOT123456", #Lot Number

    [string]$Serial = "SER987654321", #Serial Number

    [int]$DelaySeconds = 5
)

Add-Type -AssemblyName System.Windows.Forms

Write-Host "Envoi du code GS1 dans $DelaySeconds secondes..."
Start-Sleep -Seconds $DelaySeconds

$gs = [char]29   # GS = ASCII 29

$barcode = switch ($Order) {
    1 {
        "01" + $GTIN +
        "17" + $Expiry +
        "10" + $Lot +
        $gs +
        "21" + $Serial
    }
    2 {
        "01" + $GTIN +
        "17" + $Expiry +
        "21" + $Serial +
        $gs +
        "10" + $Lot
    }
}

Write-Host "Configuration envoyée :"
Write-Host "  Ordre  : $Order"
Write-Host "  GTIN   : $GTIN"
Write-Host "  Expiry : $Expiry"
Write-Host "  Lot    : $Lot"
Write-Host "  Serial : $Serial"
Write-Host ""

# Affichage de la trame en hexadécimal pour vérification
$hex = ($barcode.ToCharArray() | ForEach-Object {
    "{0:X2}" -f [int][char]$_
}) -join " "

Write-Host "Trame HEX :"
Write-Host $hex
Write-Host ""

[System.Windows.Forms.SendKeys]::SendWait($barcode)
[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")