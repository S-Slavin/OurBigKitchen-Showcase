# OurBigKitchen Project Version Guide

## Active Working Version
- Directory: `OurBigKitchen_Restored/`
- This is the main working version
- Contains all the latest fixes and working components
- Git repository: https://github.com/S-S-Slavin/OurBigKitchen.git

## Preserved Backup (DO NOT MODIFY)
- Directory: `OurBigKitchen_New/`
- This is our reference backup
- Contains original working files and structure
- Used only for reference and recovery if needed

## Other Versions (Can be ignored)
- `OurBigKitchen/` (original version)
- `OurBigKitchenMockup/` and `OurBigKitchenMockup_New/` (mockup versions)
- `OurBigKitchenAccurate/` (another version)
- Various backup versions with timestamps

## Important Notes
1. Always work in `OurBigKitchen_Restored/`
2. Never modify `OurBigKitchen_New/` as it's our reference backup
3. If you need to reference original files, use `OurBigKitchen_New/`
4. All other versions can be ignored or cleaned up if needed

## Key Components Location
- `ImagePicker.swift` → `Views/Components/`
- `ShareSheet.swift` → `Views/Components/`
- `FlowLayout.swift` → `Views/Components/`
- `ImpactShareCard` → Inside `Services/ImageRenderingService.swift` 