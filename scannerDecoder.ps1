#simple PS script that emulates a barcode/datamatrix scanner sending GS1-128 code to a parser.
#Mathieu GRIVOIS, 20261023 v1.0

Add-Type -AssemblyName System.Windows.Forms

Write-Host "Scannez un code-barres puis appuyez sur Entrée..."
Write-Host ""

$buffer = ""

while ($true) {
    $key = [System.Windows.Forms.Control]::ModifierKeys

    if ([Console]::KeyAvailable) {
        $k = [Console]::ReadKey($true)

        if ($k.Key -eq "Enter") {
            Write-Host ""
            Write-Host "Texte reçu :"
            Write-Host $buffer
            Write-Host ""
            Write-Host "Codes ASCII :"

            foreach ($c in $buffer.ToCharArray()) {
                $ascii = [int][char]$c
                "{0,-5} 0x{1:X2} '{2}'" -f $ascii, $ascii, $c
            }

            $buffer = ""
            Write-Host ""
            Write-Host "Prêt pour un nouveau scan..."
            Write-Host ""
        }
        else {
            $buffer += $k.KeyChar
        }
    }

    Start-Sleep -Milliseconds 10
}