# GS1-128_scanner_decoder-emulator
Set of scripts for decoding raw data coming from a datamatrix/barcode scanner and see keycodes and emulating keycodes coming from a virtual scanner

## Scanner decoder (GS1 analyser)

### Purpose
scannerDecoder.ps1 is intended to troubleshoot and validate barcode scanner output when the scanner is configured in **Keyboard Wedge (HID Keyboard)** mode.
It captures every character received from the keyboard input stream and displays:
- The decoded text.
- The ASCII value of each character.
- Non-printable control characters that may be embedded in GS1 barcodes (such as the **Group Separator (GS, ASCII 29 / 0x1D)**).

This is particularly useful when testing **GS1-128** or **GS1 DataMatrix** barcodes containing variable-length Application Identifiers (AIs) separated by a GS character.

### Typical Use Case

When scanning a GS1 barcode containing:

```text
(01)18437006085042
(17)271231
(10)LOT123456
(21)SER987654321
```

the scanner may actually transmit:

```text
01184370060850421727123110LOT123456<GS>21SER987654321
```
where:

```text
<GS> = ASCII 29 = 0x1D
```
Many applications do not display this control character, making it difficult to determine whether the scanner is transmitting it correctly.
This script allows verification of the exact characters received by Windows.

### Usage

#### Start the script

```powershell
.\GS1KeyboardAnalyzer.ps1
```

The script displays:

```text
Scan a barcode then press Enter...
```

#### Scan a barcode

Scan any barcode using the connected scanner.

The characters received are buffered until an **Enter** key is detected.

#### Review the output

Example:

```text
Texte reçu :
01012345678901281727123110LOT12345621SER987654321

Codes ASCII :

48    0x30 '0'
49    0x31 '1'
...
29    0x1D
...
```

A line containing:

```text
29    0x1D
```

indicates that a **Group Separator (GS)** has been successfully received.

---

### Output Interpretation

#### Printable Characters

Example:

```text
65    0x41 'A'
49    0x31 '1'
```

Meaning:

| Character | ASCII | Hex |
|-----------|--------|------|
| A | 65 | 0x41 |
| 1 | 49 | 0x31 |

#### Group Separator

Example:

```text
29    0x1D
```

Meaning:

```text
GS = Group Separator
ASCII = 29
Hex = 0x1D
```

This is the standard GS1 separator used after variable-length AIs such as:

```text
(10) Lot Number
(21) Serial Number
(240) Additional Product Identification
(241) Customer Part Number
...
```

### Example

#### Barcode Structure

```text
(01)18437006085042
(17)271231
(10)LOT123456
<GS>
(21)SER987654321
```

#### Expected ASCII Sequence Around the Separator

```text
...
54 31 32 33 34 35 36
1D
32 31 53 45 52
...
```

or:

```text
...
'T' '1' '2' '3' '4' '5' '6'
GS
'2' '1' 'S' 'E' 'R'
...
```


### Notes

- If no `0x1D` appears, the scanner may be:
  - Removing the GS character.
  - Replacing it with another character.
  - Misconfigured for GS1 transmission.

- If a visible separator such as `|`, `^`, or `]` appears, the scanner may be configured to substitute the GS control character.
- For accurate GS1 validation, it is recommended to test with barcodes containing both a **Lot Number (AI 10)** and a **Serial Number (AI 21)**, as a separator is required whenever a variable-length AI is followed by another AI.



### Known Limitation

This script analyzes characters received through the Windows keyboard input subsystem. It does not capture raw USB HID packets or serial communications.
If the scanner suppresses a control character before sending it to Windows, the script cannot detect it. In that case, testing with a scanner configured in **USB-COM (Virtual COM Port)** mode is recommended.


## Scanner Emulator
### Purpose
scannerEmulator.ps1 is a simple PowerShell script that emulates a barcode scanner reading a **GS1 DataMatrix** or **GS1-128 barcode**. Only the GS1 standard is supported; HIBCC/HIBC is not supported.

### Supported Fields and Modes
- GTIN: 14-digit code corresponding to the UDI/UDI-DI of a medical device, or to a pharmaceutical UCD13/CIP13 code prefixed with a leading 0.
- Expiry: Expiration date expressed in YYMMDD format.
- Lot: Lot/batch number (variable-length alphanumeric string).
- Serial: Serial number (variable-length alphanumeric string).
- Order: Ordering mode (1 or 2), allowing you to choose whether the Lot Number appears before or after the Serial Number in the GS1 data stream.

### Usage
#### Preparation
Prepare the target field (the input field where the code should be entered by the virtual scanner).
#### Start the script
Execute the PowerShell script. All parameters are optional; default values will be used if omitted:
```
.\scannerEmulator.ps1 `
-Order 1 `
-GTIN 18437006085042 `
-Expiry 271231 `
-Lot LOT123456 `
-Serial SER987654321
```
#### Select target field
**Within 5 seconds** after launching the script, click on the target field and wait for the input to be completed.

### Additionnal note
As with a physical barcode scanner operating in keyboard wedge mode, the barcode data is sent character by character to the currently focused field. The script also inserts the **GS separator (ASCII 0x1D)** where required by the GS1 specifications.
