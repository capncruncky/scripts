####################################################################

#DupSearch 1.0 - Script by @cybercruncky

#This script searches the current directory and sub-directories for duplicate files
# - comparing files by using a SHA256 hash - 
#then lists the paths of duplicate files for manual removal.

#Tip: Make sure to backup your files before doing any deleting!!!!!
#Tip: Pipe the output to a text file for reference!

#Usage: C:\Dir DupSearch.ps1 > dupLog.txt

#####################################################################

#Initialize Variables
$count = 1

#Display Duplicate Files
$path = $pwd

#Recurse through folder to collect all files and store in variable
#$fileCollection = Get-ChildItem -File -Recurse | Select-Object -Property FullName,Length
$fileCollection = Get-ChildItem -File -Recurse

#Total number of files
$TotalFiles = $fileCollection.count

#Write total to output
Write-Output "`nTotal number of Files: $TotalFiles`n"
Set-Content -Path $path/DupSearchLog.txt "`nTotal number of Files: $TotalFiles`n"

#Create Container(array) for storing Matched Source Files
$MatchedSourceFiles = @()

#Create Container(arra) for dipsplaying final results
$DuplicateResults = @()

foreach($file in $fileCollection)
{
    #Display Progress to User
    Write-Progress -Activity "Processing Files" -status "Processing File $count / $TotalFiles" -PercentComplete ($count / $TotalFiles * 100)

    #Display file information
    Write-Output "Path: $($file.FullName) `t`t Size: $($file.Length / 1000) KB"
    Add-Content -Path $path/DupSearchLog.txt "Path: $($file.FullName) `t`t Size: $($file.Length / 1000) KB"

    #Create Container(array) to hold matched files
    $MatchingFiles = @()

    #Check for Matching Files
    $MatchingFiles = $fileCollection | Where-Object {$_.Name -eq $file.Name}
    
    foreach($matchEntry in $MatchingFiles)
    {
        if(($file -ne $matchEntry) -and !(($MatchedSourceFiles) -contains $matchEntry))
        {
            Write-Output "`nFile Names Match! `nEvaluating Hashes: $($file.FullName) and $($matchEntry.FullName)"
            Add-Content -Path $path/DupSearchLog.txt "`nFile Names Match! `nEvaluating Hashes: $($file.FullName) and $($matchEntry.FullName)"

            #Compare the binary of two files using fc.exe /B
            if((Get-FileHash $file.FullName).hash -eq (Get-FileHash $matchEntry.FullName).hash)
            {
                Write-Output "Duplicate found! $($file.Name) has duplicate!`n"
                Add-Content -Path $path/DupSearchLog.txt "Duplicate found! $($file.Name) has duplicate!`n"

                #Write-Output "$($file.Name) has duplicate!`n"
                $MatchedSourceFiles += $matchEntry

                #Create new output object for match
                $NewObject=[pscustomobject][ordered]@{
                    File_Path = $file.FullName
                    Duplicate_Path = $matchEntry.FullName
                }
                
                #Add new object to results array
                $DuplicateResults += $NewObject
            }
            else
            {
                Write-Output "Hashes are not identical. Moving on...`n"
                Add-Content -Path $path/DupSearchLog.txt "Hashes are not identical. Moving on...`n"
            }

        }
    }

    #Increment Counter
    $count += 1
}

#Total of Duplicate Files
Write-Output "`nTotal of Duplicate Files: $($DuplicateResults.count)"
Add-Content -Path $path/DupSearchLog.txt "`nTotal of Duplicate Files: $($DuplicateResults.count)"

Add-Content -Path $path/DupSearchLog.txt $DuplicateResults | Format-List
$DuplicateResults | Format-List


