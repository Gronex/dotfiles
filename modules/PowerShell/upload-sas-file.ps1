<#
.SYNOPSIS
Uploads a local file to Azure Blob Storage using a SAS token or container SAS URL.
.PARAMETER SasToken
The full HTTPS container SAS URL, or a bare SAS token with optional leading '?'.
The SAS must grant Write permission for staging and committing blocks.
.PARAMETER StorageAccountName
Required with a bare SAS token. The destination Azure storage account name.
.PARAMETER ContainerName
Required with a bare SAS token. The destination blob container name.
.PARAMETER RemoteFileName
Optional blob name, including any virtual folders. Defaults to the local filename.
.PARAMETER BlockSizeMB
In-memory block size in MiB. Defaults to 64. Increase it for files requiring
more than Azure's maximum of 50,000 blocks.
.EXAMPLE
./upload-sas-file.ps1 -FilePath './report.csv' -SasToken $containerSasUrl
.EXAMPLE
./upload-sas-file.ps1 './report.csv' $containerSasUrl 'reports/latest.csv'
.EXAMPLE
./upload-sas-file.ps1 './report.csv' $sasToken -StorageAccountName 'myaccount' -ContainerName 'reports'
.NOTES
Existing blobs with the same name are overwritten. Large files are uploaded in
blocks held in memory, without temporary files. The existing blob is not reset
before uploading; its content is replaced only when the block list is committed.
#>
[CmdletBinding(DefaultParameterSetName = 'Url')]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateNotNullOrEmpty()]
    [string]$FilePath,

    [Parameter(Mandatory = $true, Position = 1, ParameterSetName = 'Url')]
    [Parameter(Mandatory = $true, Position = 1, ParameterSetName = 'Token')]
    [ValidateNotNullOrEmpty()]
    [string]$SasToken,

    [Parameter(Position = 2)]
    [ValidateNotNullOrEmpty()]
    [string]$RemoteFileName,

    [Parameter(Mandatory = $true, ParameterSetName = 'Token')]
    [ValidatePattern('^[a-z0-9]{3,24}$')]
    [string]$StorageAccountName,

    [Parameter(Mandatory = $true, ParameterSetName = 'Token')]
    [ValidateNotNullOrEmpty()]
    [string]$ContainerName,

    [Parameter()]
    [ValidateRange(1, 1024)]
    [int]$BlockSizeMB = 64
)

$file = Get-Item -LiteralPath $FilePath -ErrorAction Stop
if ($file -isnot [System.IO.FileInfo]) {
    throw 'FilePath must refer to a file on disk.'
}
$sasUri = $null
if (-not [Uri]::TryCreate($SasToken, [UriKind]::Absolute, [ref]$sasUri)) {
    if (-not $StorageAccountName -or -not $ContainerName) {
        throw 'StorageAccountName and ContainerName are required when SasToken is a bare token.'
    }
    $container = [Uri]::EscapeDataString($ContainerName)
    $sasUri = [Uri]("https://$StorageAccountName.blob.core.windows.net/$container" + '?' + $SasToken.TrimStart('?'))
}
elseif ($StorageAccountName -or $ContainerName) {
    throw 'StorageAccountName and ContainerName must be omitted when SasToken is a full URL.'
}
if ($sasUri.Scheme -ne 'https' -or
    $sasUri.AbsolutePath.Trim('/') -eq '' -or
    $sasUri.Query -notmatch '[?&]sig=[^&]+' -or
    $sasUri.Fragment -ne '') {
    throw 'Provide a valid SAS token or full HTTPS container SAS URL, including its signature.'
}

if (-not $PSBoundParameters.ContainsKey('RemoteFileName')) {
    $RemoteFileName = $file.Name
}
if ([string]::IsNullOrWhiteSpace($RemoteFileName)) {
    throw 'RemoteFileName must not be blank.'
}

$encodedName = ($RemoteFileName.Split('/') | ForEach-Object {
    [Uri]::EscapeDataString($_)
}) -join '/'
$blobUrl = $sasUri.GetLeftPart([UriPartial]::Path).TrimEnd('/') + '/' + $encodedName
$uploadUrl = $blobUrl + $sasUri.Query
$blockSize = [long]$BlockSizeMB * 1MB
if ([Math]::Ceiling($file.Length / [double]$blockSize) -gt 50000) {
    throw 'The file requires more than 50,000 blocks. Increase BlockSizeMB (up to 1024).'
}
Add-Type -AssemblyName System.Net.Http
$httpClient = New-Object System.Net.Http.HttpClient
$httpClient.Timeout = [TimeSpan]::FromHours(4)
$httpClient.DefaultRequestHeaders.Add('x-ms-version', '2021-12-02')

function Send-BlobRequest {
    param(
        [string]$Uri,
        [System.Net.Http.HttpContent]$Content,
        [string]$Operation
    )

    $response = $null
    try {
        $response = $httpClient.PutAsync($Uri, $Content).GetAwaiter().GetResult()
        if (-not $response.IsSuccessStatusCode) {
            $errorBody = $response.Content.ReadAsStringAsync().GetAwaiter().GetResult()
            throw "${Operation} failed: $([int]$response.StatusCode) $($response.ReasonPhrase)`n$errorBody"
        }
    }
    finally {
        if ($response) {
            $response.Dispose()
        }
        $Content.Dispose()
    }
}

$blockList = [System.Xml.XmlDocument]::new()
$null = $blockList.AppendChild($blockList.CreateElement('BlockList'))
$uploadId = [Guid]::NewGuid().ToString('N')
$source = $null
$activity = "Uploading $($file.Name)"
$bytesUploaded = 0L
$blockIndex = 0
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
try {
    $source = [System.IO.File]::OpenRead($file.FullName)
    $totalBytes = $source.Length
    $buffer = [byte[]]::new([int][Math]::Min([long]$blockSize, [long]$totalBytes))
    while ($source.Position -lt $source.Length) {
        $bytesRead = 0
        $chunkLength = [int][Math]::Min([long]$buffer.Length, [long]($totalBytes - $source.Position))
        while ($bytesRead -lt $chunkLength) {
            $read = $source.Read($buffer, $bytesRead, $chunkLength - $bytesRead)
            if ($read -eq 0) {
                throw 'Unexpected end of the local file during upload.'
            }
            $bytesRead += $read
        }

        $blockId = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(('{0}-{1:D5}' -f $uploadId, $blockIndex)))
        $blockUrl = $uploadUrl + '&comp=block&blockid=' + [Uri]::EscapeDataString($blockId)
        $content = [System.Net.Http.ByteArrayContent]::new($buffer, 0, $bytesRead)
        Send-BlobRequest -Uri $blockUrl -Content $content -Operation "Block $blockIndex"
        $entry = $blockList.CreateElement('Uncommitted')
        $entry.InnerText = $blockId
        $null = $blockList.DocumentElement.AppendChild($entry)
        $blockIndex++

        $bytesUploaded += $bytesRead
        $percent = [Math]::Min(100, ($bytesUploaded / $totalBytes) * 100)
        $elapsedSeconds = [Math]::Max($stopwatch.Elapsed.TotalSeconds, 0.001)
        $bytesPerSecond = $bytesUploaded / $elapsedSeconds
        $etaSeconds = [int][Math]::Ceiling(($totalBytes - $bytesUploaded) / $bytesPerSecond)
        $status = '{0:N1} / {1:N1} MiB | {2:N2} MiB/s | ETA {3}s | {4} blocks' -f `
            ($bytesUploaded / 1MB), ($totalBytes / 1MB), ($bytesPerSecond / 1MB), $etaSeconds, $blockIndex
        Write-Progress -Activity $activity -Status $status `
            -PercentComplete $percent -SecondsRemaining $etaSeconds
    }

    Write-Progress -Activity $activity -Status 'Committing block list...' -PercentComplete 100
    $commitContent = [System.Net.Http.StringContent]::new($blockList.OuterXml, [Text.Encoding]::UTF8, 'application/xml')
    $commitContent.Headers.Add('x-ms-blob-content-type', 'application/octet-stream')
    Send-BlobRequest -Uri ($uploadUrl + '&comp=blocklist') -Content $commitContent -Operation 'Commit'
}
finally {
    $stopwatch.Stop()
    Write-Progress -Activity $activity -Completed
    if ($source) {
        $source.Dispose()
    }
    $httpClient.Dispose()
}

Write-Host ('Upload complete: {0} blocks, {1:N1} MiB in {2:N1}s.' -f `
    $blockIndex, ($bytesUploaded / 1MB), $stopwatch.Elapsed.TotalSeconds)
Write-Output $blobUrl

