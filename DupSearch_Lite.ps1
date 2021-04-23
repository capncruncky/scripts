####################################################################

#DupSearch_Lite 1.0 - Script by @capncruncky github.com/capncruncky

#This script searches the current directory and sub-directories for duplicate files
# - comparing files by using file name and file length as comparison - 
#then lists the paths of duplicate files for manual removal.

#Tip: Make sure to backup your files before doing any deleting!!!!!
#Tip: Pipe the output to a text file for reference!

#Usage: C:\Dir DupSearch_Lite.ps1
#Log: [PATH]\DupSearch_Lite_Log.txt

#####################################################################

#Initialize Variables
$count = 1

#Display Duplicate Files
$path = $pwd

#Recurse through folder to collect all files and store in variable
$fileCollection = Get-ChildItem -File -Recurse

#Total number of files
$TotalFiles = $fileCollection.count

#Write total to output
Set-Content -Path $path/DupSearch_Lite_Log.txt "`nTotal number of Files: $TotalFiles`n" -PassThru

#Create Container(array) to hold matched files...
$MatchingFiles = @()

#Create Container(array) for storing Matched Source Files
$MatchedSourceFiles = @()

#Create Container(arra) for dipsplaying final results
$DuplicateResults = @()

foreach($file in $fileCollection)
{
    #Display Progress Bar...
    Write-Progress -Activity "Processing Files" -status "Processing File $count / $TotalFiles" -PercentComplete ($count / $TotalFiles * 100)

    #Display file information...
    Add-Content -Path $path/DupSearch_Lite_Log.txt "Path: $($file.FullName)`t Size: $($file.Length / 1000) KB" #-PassThru
     
    #Check for Matching File Names and Length...
    $MatchingFiles = $fileCollection | Where-Object {($_.Name -eq $file.Name) -and ($_.Length -eq $file.Length)}
    
    #Cycle through files in collection meeting above criteria...
    foreach($matchEntry in $MatchingFiles)
    {
        #Check files for various requirements...
        if(($file -ne $matchEntry) -and !(($MatchedSourceFiles) -contains $matchEntry))
        {
            <#
            #Write Output...
            Add-Content -Path $path/DupSearch_Lite_Log.txt "`nFile Names and Lengths Match! Evaluating Hashes...`n*$($file.FullName)`n*$($matchEntry.FullName)" -PassThru

            #Compare the binary of two files using hashes...
            if(($fileHash = ((Get-FileHash $file.FullName).hash)) -eq ($matchEntryHash = ((Get-FileHash $matchEntry.FullName).hash)))
            {
                #Write Output...
                Add-Content -Path $path/DupSearch_Lite_Log.txt "`n`t`tDUPLICATE FOUND!: $($file.Name)`n" -PassThru
                Add-Content -Path $path/DupSearch_Lite_Log.txt "`t$($file.FullName)`n`t$($fileHash)`n`t$($matchEntry.FullName)`n`t$($matchEntryHash)`n" -PassThru
         #>
                #Write Output...
                Add-Content -Path $path/DupSearch_Lite_Log.txt "`nFile Names and Lengths Match! `n*$($file.FullName)`n*$($matchEntry.FullName)" #-PassThru

                #Write Output...
                Add-Content -Path $path/DupSearch_Lite_Log.txt "`n`t`tDUPLICATE FOUND!: $($file.Name)" #-PassThru
                Add-Content -Path $path/DupSearch_Lite_Log.txt "`t$($file.FullName)`n`t$($matchEntry.FullName)`n" #-PassThru

                #Add match to array of matched files...
                $MatchedSourceFiles += $matchEntry

                #Create new output object for $file match...
                $NewObject=[pscustomobject][ordered]@{
                    File_Name = $file.Name
                    File_Path = $file.FullName
                    #File_Hash = $fileHash
                    File_Size = $file.Length
                }

                #Create new output object for $matchentry match...
                $NewObject2=[pscustomobject][ordered]@{
                    File_Name = $matchEntry.Name
                    File_Path = $matchEntry.FullName
                    #File_Hash = $matchEntryHash
                    File_Size = $matchEntry.Length
                }

                #Add new object to Duplicate Results array for processing later...
                $DuplicateResults += $NewObject 
                $DuplicateResults += $NewObject2
            }
            <#else
            {
                #Write Output...
                Add-Content -Path $path/DupSearch_Lite_Log.txt "`n`t`tHashes are not identical. Moving on...`n" -PassThru
            }#>
        #}
    }
    #Increment Counter...
    $count += 1
}

#Organize Objects in array
$GroupResults = $DuplicateResults
$FinalResults = @()
$tempSize = 0
$FinalSize = 0

#Cycle through all Duplicates...
foreach($result in $DuplicateResults)
{   #...
    foreach($object in $GroupResults)
    {
        #Check for matches and uniqueness of files for storing in Final Results array
        if(($object.File_Name -eq $result.File_Name) -and ($object.File_Path -ne $result.File_Path) -and ($object.File_Hash -eq $result.File_Hash) -and ($FinalResults.File_Path -notcontains $object.File_Path) -and ($FinalResults.File_Path -notcontains $result.File_Path))
        {
            #Accumulate file size into aggregate file size total
            $tempSize += $object.File_Size

            #Create new output object for match...
            $FinalObject=[pscustomobject][ordered]@{
                File_Name = $result.File_Name
                File_Path = $result.File_Path
                #File_Hash = $result.File_Hash
                Duplicate_Name = $object.File_Name
                Duplicate_Path = $object.File_Path
                #Duplicate_Hash = $object.File_Hash
            }

            #Add object to Final Results container
            $FinalResults += $FinalObject      
        }   
    }  
}

#Calculate Storage Total Size
$FinalSize = $tempSize / 1024
$unit = "kB"
if($FinalSize -gt 1024000)
{
    $FinalSize = $FinalSize / 1024000
    $unit = "GB"
}
else
{
    if($FinalSize -gt 1024)
    {
        $FinalSize = $FinalSize / 1024
        $unit = "MB"
    } 
}

#Write Output...
Add-Content -Path $path/DupSearch_Lite_Log.txt "`n************************************************************" -PassThru
Add-Content -Path $path/DupSearch_Lite_Log.txt "`t`tRESULTS OF SCAN" -PassThru
Add-Content -Path $path/DupSearch_Lite_Log.txt "************************************************************`n" -PassThru
Add-Content -Path $path/DupSearch_Lite_Log.txt "Total of Duplicate Files: $($FinalResults.count)" -PassThru
Add-Content -Path $path/DupSearch_Lite_Log.txt "`nTotal of Storage Space used by duplicate files: $([math]::Round($FinalSize,3))$unit" -PassThru

#Write Output based on size...
if($FinalResults.Count -lt 20)
{
    $FinalResults | Format-List -GroupBy File_Hash
    Add-Content -Path $path/DupSearch_Lite_Log.txt "`nSee: $path\DupSearch_Lite_Log.txt for detailed results..." -PassThru
}
else
{
    Add-Content -Path $path/DupSearch_Lite_Log.txt "`nSee: $path\DupSearch_Lite_Log.txt for detailed results..." -PassThru
}

#Write Output to log in correct format...
$FinalResults | Format-List -GroupBy File_Name | Out-File -FilePath $path/DupSearch_Lite_Log.txt -Append -Encoding utf8

#########End

