# scripts
Repository of scripts 
This is a repository of miscellaneous scripts I've written to do various administrative tasks.

# DupSearch.ps1
This Powershell script searches a directory (and subdirectories) for duplicate files and writes the output to the terminal and a log file. The log file is created on execution and is stored in the directory where the script was executed. NO FILES ARE MODIFIED OR DELETED! This script uses the Get-FileHash cmdlet to compare the hashes of two or more files with the same name. If the hashes are identical, the file paths of both files are logged and presented at the end of the script for the user to decide on how to proceed. 

# DupSearch_Lite.ps1
Lite version of DupSearch. Uses only file name and length as testing for duplicates. DupSearch_Lite is recommended for general use and (in most cases) is accurate enough for common system admin purposes. For thorough testing, use DupSearch. 

# SizeSort.ps1
Simple script to identify the 20 largest files over 100MB in current directory and sub-directories
