param(
    [string]$BuildDirectory = (Join-Path $PSScriptRoot '..\tmp\gmcm-build')
)

$ErrorActionPreference = 'Stop'
$build = [System.IO.Path]::GetFullPath($BuildDirectory)
[System.IO.Directory]::CreateDirectory($build) | Out-Null
$oldBibInputs = $env:BIBINPUTS
$oldBstInputs = $env:BSTINPUTS

function Invoke-Checked {
    param([string]$Program, [string[]]$Arguments)
    & $Program @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "$Program failed with exit code $LASTEXITCODE. See $build."
    }
}

Get-Command xelatex, bibtex -ErrorAction Stop | Out-Null
Push-Location $PSScriptRoot
try {
    $env:BIBINPUTS = "$PSScriptRoot;$oldBibInputs"
    $env:BSTINPUTS = "$PSScriptRoot;$oldBstInputs"
    $latexArguments = @(
        '-interaction=nonstopmode'
        '-halt-on-error'
        '-file-line-error'
        "-output-directory=$build"
        'main.tex'
    )
    Invoke-Checked 'xelatex' $latexArguments
    Push-Location $build
    try {
        Invoke-Checked 'bibtex' @('main')
    }
    finally {
        Pop-Location
    }
    Invoke-Checked 'xelatex' $latexArguments
    Invoke-Checked 'xelatex' $latexArguments
    Copy-Item -LiteralPath (Join-Path $build 'main.pdf') -Destination (Join-Path $PSScriptRoot 'main.pdf') -Force
    Write-Host "PDF: $(Join-Path $PSScriptRoot 'main.pdf')"
    Write-Host "Build files: $build"
}
finally {
    $env:BIBINPUTS = $oldBibInputs
    $env:BSTINPUTS = $oldBstInputs
    Pop-Location
}
