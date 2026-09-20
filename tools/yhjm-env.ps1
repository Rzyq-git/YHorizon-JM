# Shared Windows env helpers for setup / build / flash.
# Dot-source:  . "$PSScriptRoot\yhjm-env.ps1"

$script:YhjmRoot = Split-Path -Parent $PSScriptRoot
$script:FirmwareRoot = Join-Path $script:YhjmRoot 'firmware'
$script:SdkPython = Join-Path $script:YhjmRoot 'sdk\python'
$script:ToolchainRoot = Join-Path $PSScriptRoot 'toolchain'

function Import-YhjmToolsEnv {
    $envFile = Join-Path $PSScriptRoot 'env.ps1'
    if (Test-Path -LiteralPath $envFile) {
        . $envFile
    }
}

function Get-YhjmFirstExisting {
    param([string[]]$Paths)
    foreach ($p in $Paths) {
        if ([string]::IsNullOrWhiteSpace($p)) { continue }
        $hits = @(Get-Item -Path $p -ErrorAction SilentlyContinue)
        if ($hits.Count -gt 0) {
            return ($hits | Sort-Object FullName -Descending | Select-Object -First 1).FullName
        }
    }
    return $null
}

function Find-YhjmCmake {
    $cmd = Get-Command cmake -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    return Get-YhjmFirstExisting @(
        (Join-Path $script:ToolchainRoot 'cmake\bin\cmake.exe')
        'C:\Program Files\JetBrains\CLion *\bin\cmake\win\x64\bin\cmake.exe'
        'C:\Program Files (x86)\JetBrains\CLion *\bin\cmake\win\x64\bin\cmake.exe'
        'D:\Program Files\JetBrains\CLion *\bin\cmake\win\x64\bin\cmake.exe'
        'D:\JetBrains\CLion *\bin\cmake\win\x64\bin\cmake.exe'
        "$env:LOCALAPPDATA\Programs\CLion\bin\cmake\win\x64\bin\cmake.exe"
        'C:\Program Files\CMake\bin\cmake.exe'
        'C:\ST\STM32CubeCLT*\CMake\bin\cmake.exe'
        'D:\ST\STM32CubeCLT*\CMake\bin\cmake.exe'
    )
}

function Find-YhjmNinja {
    $cmd = Get-Command ninja -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    return Get-YhjmFirstExisting @(
        (Join-Path $script:ToolchainRoot 'ninja\ninja.exe')
        'C:\Program Files\JetBrains\CLion *\bin\ninja\win\x64\ninja.exe'
        'D:\Program Files\JetBrains\CLion *\bin\ninja\win\x64\ninja.exe'
        'D:\JetBrains\CLion *\bin\ninja\win\x64\ninja.exe'
        "$env:LOCALAPPDATA\Programs\CLion\bin\ninja\win\x64\ninja.exe"
        'C:\ST\STM32CubeCLT*\Ninja\bin\ninja.exe'
        'D:\ST\STM32CubeCLT*\Ninja\bin\ninja.exe'
    )
}

function Find-YhjmArmGcc {
    if ($env:ARM_NONE_EABI_TOOLCHAIN_PATH) {
        $p = Join-Path $env:ARM_NONE_EABI_TOOLCHAIN_PATH 'arm-none-eabi-gcc.exe'
        if (Test-Path -LiteralPath $p) { return $p }
    }
    $cmd = Get-Command arm-none-eabi-gcc -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    return Get-YhjmFirstExisting @(
        (Join-Path $script:ToolchainRoot 'arm-gnu\bin\arm-none-eabi-gcc.exe')
        (Join-Path $script:ToolchainRoot 'arm-gnu\*\bin\arm-none-eabi-gcc.exe')
        'C:\ST\STM32CubeIDE*\STM32CubeIDE\plugins\com.st.stm32cube.ide.mcu.externaltools.gnu-tools-for-stm32.*\tools\bin\arm-none-eabi-gcc.exe'
        'D:\ST\STM32CubeIDE*\STM32CubeIDE\plugins\com.st.stm32cube.ide.mcu.externaltools.gnu-tools-for-stm32.*\tools\bin\arm-none-eabi-gcc.exe'
        'C:\ST\STM32CubeCLT*\GNU-tools-for-STM32\bin\arm-none-eabi-gcc.exe'
        'D:\ST\STM32CubeCLT*\GNU-tools-for-STM32\bin\arm-none-eabi-gcc.exe'
        'C:\Program Files\Arm GNU Toolchain arm-none-eabi\*\bin\arm-none-eabi-gcc.exe'
        'C:\Program Files (x86)\Arm GNU Toolchain arm-none-eabi\*\bin\arm-none-eabi-gcc.exe'
        'C:\Program Files (x86)\GNU Arm Embedded Toolchain\*\bin\arm-none-eabi-gcc.exe'
    )
}

function Find-YhjmGd32OpenOcdHome {
    $direct = Get-YhjmFirstExisting @(
        'D:\GD32EB_v1.5.11_Rel\GD32EB_v1.5.11_Rel\GD32EB\plugins\com.gd.tools.openocd_*\Tools\OpenOCD'
        'D:\GD32EB*\*\GD32EB\plugins\com.gd.tools.openocd_*\Tools\OpenOCD'
        'C:\GD32EB*\*\GD32EB\plugins\com.gd.tools.openocd_*\Tools\OpenOCD'
        'C:\Program Files\GD32EB*\GD32EB\plugins\com.gd.tools.openocd_*\Tools\OpenOCD'
        'D:\Program Files\GD32EB*\GD32EB\plugins\com.gd.tools.openocd_*\Tools\OpenOCD'
        "$env:LOCALAPPDATA\GD32EB*\GD32EB\plugins\com.gd.tools.openocd_*\Tools\OpenOCD"
    )
    if ($direct) { return $direct }

    $roots = @(Get-ChildItem -Path @('C:\', 'D:\') -Directory -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -like 'GD32EB*' })
    foreach ($root in $roots) {
        $hit = Get-ChildItem -Path $root.FullName -Directory -Recurse -Filter 'OpenOCD' -ErrorAction SilentlyContinue |
            Where-Object {
                (Test-Path -LiteralPath (Join-Path $_.FullName 'bin\openocd.exe')) -and
                (Test-Path -LiteralPath (Join-Path $_.FullName 'openocd\scripts\target\gd32f30x.cfg'))
            } |
            Select-Object -First 1
        if ($hit) { return $hit.FullName }
    }
    return $null
}

function Find-YhjmOpenOcdScriptsDir {
    param([string]$HomeDir)
    foreach ($rel in @('openocd\scripts', 'share\openocd\scripts', 'scripts')) {
        $d = Join-Path $HomeDir $rel
        if (Test-Path -LiteralPath $d) { return $d }
    }
    $nested = Get-ChildItem -Path $HomeDir -Directory -Recurse -Filter 'scripts' -ErrorAction SilentlyContinue |
        Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName 'target') } |
        Select-Object -First 1
    if ($nested) { return $nested.FullName }
    return $null
}

function Test-YhjmOpenOcdHasGd32 {
    param([string]$ScriptsDir)
    if (-not $ScriptsDir) { return $false }
    return (Test-Path -LiteralPath (Join-Path $ScriptsDir 'target\gd32f30x.cfg'))
}

function Find-YhjmOpenOcd {
    if ($env:YHJM_OPENOCD_EXE -and (Test-Path -LiteralPath $env:YHJM_OPENOCD_EXE)) {
        $homeDir = Split-Path -Parent (Split-Path -Parent $env:YHJM_OPENOCD_EXE)
        $scripts = $env:YHJM_OPENOCD_SCRIPTS
        if (-not $scripts) { $scripts = Find-YhjmOpenOcdScriptsDir $homeDir }
        return [pscustomobject]@{
            Exe     = $env:YHJM_OPENOCD_EXE
            Scripts = $scripts
            HasGd32 = [bool](($env:YHJM_OPENOCD_HAS_GD32 -eq '1') -or (Test-YhjmOpenOcdHasGd32 $scripts))
        }
    }

    $gd = Find-YhjmGd32OpenOcdHome
    if ($gd) {
        return [pscustomobject]@{
            Exe     = Join-Path $gd 'bin\openocd.exe'
            Scripts = Join-Path $gd 'openocd\scripts'
            HasGd32 = $true
        }
    }

    $exe = Get-YhjmFirstExisting @(
        (Join-Path $script:ToolchainRoot 'openocd\bin\openocd.exe')
        (Join-Path $script:ToolchainRoot 'openocd\*\bin\openocd.exe')
    )
    if ($exe) {
        $homeDir = Split-Path -Parent (Split-Path -Parent $exe)
        $scripts = Find-YhjmOpenOcdScriptsDir $homeDir
        return [pscustomobject]@{
            Exe     = $exe
            Scripts = $scripts
            HasGd32 = Test-YhjmOpenOcdHasGd32 $scripts
        }
    }

    $cmd = Get-Command openocd -ErrorAction SilentlyContinue
    if ($cmd) {
        $homeDir = Split-Path -Parent (Split-Path -Parent $cmd.Source)
        $scripts = Find-YhjmOpenOcdScriptsDir $homeDir
        return [pscustomobject]@{
            Exe     = $cmd.Source
            Scripts = $scripts
            HasGd32 = Test-YhjmOpenOcdHasGd32 $scripts
        }
    }
    return $null
}

function Find-YhjmPython {
    foreach ($cmdName in @('py', 'python', 'python3')) {
        $cmd = Get-Command $cmdName -ErrorAction SilentlyContinue
        if (-not $cmd) { continue }
        $src = $cmd.Source
        if ($src -match 'WindowsApps\\python') { continue }
        try {
            if ($cmdName -eq 'py') {
                $ver = & $src -3 -c "import sys; print(sys.version)" 2>$null
                if ($LASTEXITCODE -eq 0 -and $ver) {
                    return @{ Exe = $src; Prefix = @('-3') }
                }
            }
            else {
                $ver = & $src -c "import sys; print(sys.version)" 2>$null
                if ($LASTEXITCODE -eq 0 -and $ver) {
                    return @{ Exe = $src; Prefix = @() }
                }
            }
        }
        catch { }
    }
    return $null
}
