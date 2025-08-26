param()

$AVD_NAME = "Small_Phone"  # Replace with your AVD name, e.g., Pixel_6_API_33

# Check if an emulator is already running
$devices = adb devices
$devicesCount = ($devices | Select-String -Pattern "emulator").Count
if ($devicesCount -eq 0) {
    Write-Host "Starting emulator..."
    Start-Process -FilePath "$env:ANDROID_HOME\emulator\emulator.exe" -ArgumentList "-avd $AVD_NAME -netdelay none -netspeed full" -NoNewWindow
}

# Wait for emulator to fully boot (checks boot animation status)
Write-Host "Waiting for emulator to boot..."
$bootanim = ""
$failcounter = 0
$timeout_in_sec = 360  # Timeout after 6 minutes if boot fails
do {
    $bootanim = adb shell getprop init.svc.bootanim 2>$null
    if ($bootanim -match "device not found" -or $bootanim -match "device offline" -or $bootanim -match "running") {
        $failcounter++
        Write-Host "Emulator booting... (attempt $failcounter)"
        if ($failcounter -gt $timeout_in_sec) {
            Write-Host "Timeout reached; failed to start emulator"
            exit 1
        }
    }
    Start-Sleep -Seconds 1
} until ($bootanim -match "stopped")
Write-Host "Emulator booted successfully."

# Add your requested 2-second delay for network stabilization
Start-Sleep -Seconds 2

# Now launch Expo
Write-Host "Launching Expo..."
expo start --android