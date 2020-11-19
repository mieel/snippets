# Read from Blob Input Trigger
```
# Input bindings are passed in via param block.
param([byte[]] $InputBlob, $TriggerMetadata)
...
$TempFile = New-TemporaryFile
[io.file]::WriteAllBytes($TempFile.FullName, $InputBlob)
Write-Host Created Temp File $TempFile.FullName
$dataSet = Import-Csv $TempFile.FullName -Delimiter ';'
Write-Host $dataSet.Count lines
...

```
