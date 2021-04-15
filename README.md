# scripts
Repository of scripts 

#DupSearch_02.ps1
This Powershell script searches a directory (and subdirectories) for duplicate files and writes the output to the terminal and a log file. The log file is created on execution and is stored in the directory where the script was executed. NO FILES ARE MODIFIED OR DELETED! This script uses the Get-FileHash cmdlet to compare the hashes of two or more files with the same name. If the hashes are identical, the file paths of both files are logged and presented at the end of the script for the user to decide on how to proceed. 
