####################################################################

#DupSearch 1.0 - Script by @capncruncky github.com/capncruncky

#This script searches the current directory and sub-directories for duplicate files
# - comparing files by using a SHA256 hash - 
#then lists the paths of duplicate files for manual removal.

#Tip: Make sure to backup your files before doing any deleting!!!!!
#Tip: Pipe the output to a text file for reference!

#Usage: C:\Dir DupSearch.ps1
#Log: [PATH]\DupSearchLog.txt

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
Set-Content -Path $path/DupSearchLog.txt "`nTotal number of Files: $TotalFiles`n" -PassThru

#Create Container(array) for storing Matched Source Files
$MatchedSourceFiles = @()

#Create Container(arra) for dipsplaying final results
$DuplicateResults = @()

foreach($file in $fileCollection)
{
    #Display Progress Bar...
    Write-Progress -Activity "Processing Files" -status "Processing File $count / $TotalFiles" -PercentComplete ($count / $TotalFiles * 100)

    #Display file information...
    Add-Content -Path $path/DupSearchLog.txt "Path: $($file.FullName)`t Size: $($file.Length / 1000) KB" -PassThru
     
    #Create Container(array) to hold matched files...
    $MatchingFiles = @()

    #Check for Matching File Names...
    $MatchingFiles = $fileCollection | Where-Object {$_.Name -eq $file.Name}
    
    #Cycle through files in collection meeting above criteria...
    foreach($matchEntry in $MatchingFiles)
    {
        #Check files for various requirements...
        if(($file -ne $matchEntry) -and !(($MatchedSourceFiles) -contains $matchEntry))
        {
            #Write Output...
            Add-Content -Path $path/DupSearchLog.txt "`nFile Names Match! Evaluating Hashes...`n*$($file.FullName)`n*$($matchEntry.FullName)" -PassThru

            #Compare the binary of two files using hashes...
            if(($fileHash = ((Get-FileHash $file.FullName).hash)) -eq ($matchEntryHash = ((Get-FileHash $matchEntry.FullName).hash)))
            {
                #Write Output...
                Add-Content -Path $path/DupSearchLog.txt "DUPLICATE FOUND!: $($file.Name)`n" -PassThru

                #Add match to array of matched files...
                $MatchedSourceFiles += $matchEntry

                #Create new output object for match...
                $NewObject=[pscustomobject][ordered]@{
                    File_Name = $file.Name
                    File_Path = $file.FullName
                    File_Hash = $fileHash
                    File_Size = $file.Length
                }

                #Add new object to Duplicate Results array for processing later...
                $DuplicateResults += $NewObject 
            }
            else
            {
                #Write Output...
                Add-Content -Path $path/DupSearchLog.txt "Hashes are not identical. Moving on...`n" -PassThru
            }
        }
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
        if(($object.File_Hash -eq $result.File_Hash) -and ($object.File_Path -ne $result.File_Path) -and ($FinalResults.File_Hash -notcontains $object.File_Hash))
        {
            #Accumulate file size into aggregate file size total
            $tempSize += $object.File_Size

            #Create new output object for match...
            $FinalObject=[pscustomobject][ordered]@{
                File_Name = $result.File_Name
                File_Path = $result.File_Path
                File_Hash = $result.File_Hash
                Duplicate_Name = $object.File_Name
                Duplicate_Path = $object.File_Path
                Duplicate_Hash = $object.File_Hash
            }

            #Add object to Final Results container
            $FinalResults += $FinalObject      
        }   
    }  
}

#Calculate Storage Total Size
$FinalSize = $tempSize / 1024
$unit = "kB"
if($FinalSize -gt 1024)
{
    $FinalSize = $FinalSize / 1024
    $unit = "MB"
}
else
{
    if($FinalSize -gt 1024000)
    {
        $FinalSize = $FinalSize / 1024
        $unit = "GB"
    }
}

#Write Output...
Add-Content -Path $path/DupSearchLog.txt "`n************************************************************" -PassThru
Add-Content -Path $path/DupSearchLog.txt "`t`tRESULTS OF SCAN" -PassThru
Add-Content -Path $path/DupSearchLog.txt "************************************************************`n" -PassThru
Add-Content -Path $path/DupSearchLog.txt "Total of Duplicate Files: $($FinalResults.count)" -PassThru
Add-Content -Path $path/DupSearchLog.txt "`nTotal of Storage Space used by duplicate files: $([math]::Round($FinalSize,3))$unit" -PassThru

#Write Output based on size...
if($FinalResults.Count -lt 20)
{
    $FinalResults | Format-List -GroupBy File_Name
    Add-Content -Path $path/DupSearchLog.txt "`nSee: $path\DupSearchLog.txt for detailed results..." -PassThru
}
else
{
    Add-Content -Path $path/DupSearchLog.txt "`nSee: $path\DupSearchLog.txt for detailed results..." -PassThru
}

#Write Output to log in correct format...
$FinalResults | Format-List -GroupBy File_Name | Out-File -FilePath $path/DupSearchLog.txt -Append -Encoding utf8

#########End
