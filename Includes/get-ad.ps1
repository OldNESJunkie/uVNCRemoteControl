get-adcomputer -filter {OperatingSystem -ne '*Windows Server*'} -properties * | where Enabled -EQ $True | select name, description |export-csv -path C:\Tools\IT-Apps\PC.csv -notypeinformation
set-content PC.csv ((get-content PC.csv) -replace '"')
set-content PC.csv ((get-content PC.csv) -replace 'name')
set-content PC.csv ((get-content PC.csv) -replace 'description')