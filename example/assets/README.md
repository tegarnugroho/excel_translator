# Example Localization Files

This directory contains example localization files in different formats to demonstrate the multi-format support of Excel Translator.

## Files

### 1. `example_localizations.xlsx` (Excel Format)

- **Format**: Microsoft Excel (.xlsx)
- **Content**: Complete example with multiple sheets:
  - **login** sheet: Login-related translations (hello, goodbye, welcome messages, etc.)
  - **buttons** sheet: Button-related translations (submit, delete, cancel, save)
- **Languages**: English (en), Indonesian (id), Spanish (es)
- **Total Keys**: 11 keys across 2 sheets

### 2. `example_localizations.csv` (CSV Format)

- **Format**: Comma-Separated Values (.csv)
- **Content**: Combined translations from both Excel sheets in a single file
- **Languages**: English (en), Indonesian (id), Spanish (es)
- **Total Keys**: 7 keys
- **Note**: CSV format supports single sheet only, so this contains a subset of Excel data

### 3. `example_localizations.ods` (OpenDocument Format)

- **Format**: OpenDocument Spreadsheet (.ods)
- **Content**: Same data as CSV file (LibreOffice Calc format)
- **Languages**: English (en), Indonesian (id), Spanish (es)
- **Total Keys**: 7 keys
- **Status**: ✅ Full support with spreadsheet_decoder

## Usage Examples

### Generate from Excel

```bash
dart run excel_translator example/assets/example_localizations.xlsx lib/generated
```

### Generate from CSV

```bash
dart run excel_translator example/assets/example_localizations.csv lib/generated
```

### Generate from ODS

```bash
dart run excel_translator example/assets/example_localizations.ods lib/generated
```

## Data Structure

All files follow the same basic structure:

| key | en | id | es |
|-----|----|----|-----|
| hello | Hello | Halo | Hola |
| goodbye | Goodbye | Selamat tinggal | Adiós |
| welcome_message | Welcome {name}! | Selamat datang {name}! | ¡Bienvenido {name}! |
| submit | Submit | Kirim | Enviar |
| delete | Delete | Hapus | Eliminar |
| cancel | Cancel | Batal | Cancelar |
| save | Save | Simpan | Guardar |

## Format Comparison

| Feature | Excel (.xlsx) | CSV (.csv) | ODS (.ods) |
|---------|---------------|------------|------------|
| Multiple Sheets | ✅ | ❌ | ✅ |
| Formatting | ✅ | ❌ | ✅ |
| Comments | ✅ | ❌ | ✅ |
| File Size | Medium | Small | Medium |
| Cross-platform | ✅ | ✅ | ✅ |
| Support Status | ✅ Full | ✅ Full | ✅ Full |

## Tips

1. **Excel Format**: Best for complex projects with multiple categories/sheets
2. **CSV Format**: Best for simple projects or when you need version control friendly format
3. **ODS Format**: Best for open-source projects using LibreOffice Calc (fully supported)
