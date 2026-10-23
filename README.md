# GS1-128_scanner_decoder-emulator
Set of scripts for decoding raw data coming from a datamatrix/barcode scanner and see keycodes and emulating keycodes coming from a virtual scanner

## Scanner decoder



## Scanner Emulator
scannerEmulator.ps1 is a simple PowerShell script that emulates a barcode scanner reading a DataMatrix or GS1-128 barcode. Only the GS1 standard is supported; HIBCC/HIBC is not supported.

### Supported Fields and Modes
GTIN: 14-digit code corresponding to the UDI/UDI-DI of a medical device, or to a pharmaceutical UCD13/CIP13 code prefixed with a leading 0.
Expiry: Expiration date expressed in YYMMDD format.
Lot: Lot/batch number (variable-length alphanumeric string).
Serial: Serial number (variable-length alphanumeric string).
Order: Ordering mode (1 or 2), allowing you to choose whether the Lot Number appears before or after the Serial Number in the GS1 data stream.
### Usage
Prepare the target field (the input field where the code should be entered by the virtual scanner).
Execute the PowerShell script. All parameters are optional; default values will be used if omitted:
```
.\scannerEmulator.ps1 `
-Order 1 `
-GTIN 18437006085042 `
-Expiry 271231 `
-Lot LOT123456 `
-Serial SER987654321
```
Within 5 seconds after launching the script, click on the target field and wait for the input to be completed.

As with a physical barcode scanner operating in keyboard wedge mode, the barcode data is sent character by character to the currently focused field. The script also inserts the GS (ASCII 0x1D) separator where required by the GS1 specification.
