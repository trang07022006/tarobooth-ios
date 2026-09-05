# STEP 10 — MAC VALIDATION INSTRUCTIONS

This document outlines the required manual validation steps on macOS with Xcode for TAROBOOTH v1.0.0 (Step 10 Native Camera + Photo Library).

## Prerequisites
- macOS Sonoma or later
- Xcode 15.0+ (iOS 17.0+ SDK)
- Physical iPhone running iOS 17.0+ (for camera hardware tests)

---

## Validation Steps

### 1. Pull Latest Changes
```bash
git pull origin main
```

### 2. Open Xcode Project
Open `TAROBOOTH.xcodeproj` in Xcode.

### 3. Configure Camera Permission Description
1. In the Project Navigator, select the `TAROBOOTH` project.
2. Select the `TAROBOOTH` app target.
3. Select the **Info** tab (Custom iOS Target Properties).
4. Add a new key:
   - **Key**: `Privacy - Camera Usage Description` (`NSCameraUsageDescription`)
   - **Type**: `String`
   - **Value**: `TAROBOOTH uses the camera so you can capture photos for your photobooth.`

### 4. Clean Build Folder
- Press `Shift + Command + K` (Product -> Clean Build Folder).

### 5. Build Project
- Press `Command + B` (Product -> Build).
- Verify compilation succeeds with zero errors.

### 6. Simulator PhotosPicker Tests (iOS 17 Simulator)
1. Run app on iOS 17 Simulator.
2. Choose a template (e.g. 4 Cut).
3. Select **PHOTO LIBRARY** source.
4. Tap **CHOOSE FROM PHOTO LIBRARY**.
5. Select 4 photos in specific order in system PhotosPicker.
6. Verify:
   - Order in tray/booth matches selection order.
   - Photos display in Arrange, Crop, Review, and Canvas Editor.
   - Original photos retain aspect and show live film effects non-destructively.
7. Review screen -> Replace Photo -> Select 1 photo -> Verify only target slot is updated.

### 7. Physical iPhone Camera Tests (Real Device)
1. Connect physical iPhone with camera hardware.
2. Select device and press `Command + R` (Run).
3. First launch -> Tap **CAMERA** source:
   - Verify native permission alert appears with the description configured in Step 3.
   - Test **Allow**: Camera preview starts running with `.resizeAspectFill`.
   - Test camera flipping (front / back).
   - Test capture with active film preset (Warm, Cream, Mono, etc.).
   - Verify shot count increments and photos appear in Review.
4. Test Retake mode from Review:
   - Tap Retake on a photo -> Camera opens.
   - Capture new photo -> Replaces target slot atomically and returns to Review.
5. In iOS Settings -> TAROBOOTH -> disable Camera access:
   - Open Camera in app -> Verify permission required state appears with "OPEN SETTINGS" and "BACK".
   - Verify shutter button is hidden/disabled and mock capture is NOT executed.
