<#############################################
SizeSort - by @capncruncky github.com/capncruncky

Simple Script to find the top 20 biggest files
over 100MB in directory and sub-directories

##############################################>

#Recurse through folder to collect all files and store in variable
$fileCollection = Get-ChildItem -File -Recurse -ErrorAction SilentlyContinue | Where-Object {$_.Length -gt 100mb} | Sort-Object Length -Descending | Select-Object -First 20

#Create array for sorted output..
$sortedFiles = @()

foreach($file in $fileCollection)
{
    #Determine unit of file size...
    if($file.Length -ge 1GB){$unit = "GB"}
        elseif($file.Length -ge 1MB){$unit = "MB"}
            else{$unit = "KB"}

    #Create custom object for custom output...
    $sortObject = [pscustomobject][ordered]@{
        TotalSize = $file.Length
        Size = $([math]::Round($file.Length/$("1$unit"),2))
        Unit = "$unit"
        filePath = $file.FullName
    }

    #Add new object to sortedFiles array...
    $sortedFiles += $sortObject
}

#Display results...
$sortedFiles | Format-Table -Property Size,Unit,filePath

