# Modified David Rowe's Badblood to remove prompts allowing for automatic deployment.
function Get-ScriptDirectory {
    Split-Path -Parent $PSCommandPath
}
$basescriptPath = Get-ScriptDirectory
$totalscripts = 7

$i = 0

$Domain = Get-addomain
Write-Progress -Activity "Random Stuff into A domain" -Status "Progress:" -PercentComplete ($i/$totalscripts*100)


.($basescriptPath + '\AD_LAPS_Install\InstallLAPSSchema.ps1')
Write-Progress -Activity "Random Stuff into A domain: Install LAPS" -Status "Progress:" -PercentComplete ($i/$totalscripts*100)
$I++
.($basescriptPath + '\AD_OU_CreateStructure\CreateOUStructure.ps1')
Write-Progress -Activity "Random Stuff into A domain - Creating OUs" -Status "Progress:" -PercentComplete ($i/$totalscripts*100)
$I++
$ousAll = Get-adorganizationalunit -filter *
write-host "Creating Users on Domain" -ForegroundColor Green
$NumOfUsers = 100..500|Get-random #this number is the random number of users to create on a domain.  Todo: Make process createusers.ps1 in a parallel loop
$X=1
Write-Progress -Activity "Random Stuff into A domain - Creating Users" -Status "Progress:" -PercentComplete ($i/$totalscripts*100)
$I++
.($basescriptPath + '\AD_Users_Create\CreateUsers.ps1')
$createuserscriptpath = $basescriptPath + '\AD_Users_Create\'
do{
createuser -Domain $Domain -OUList $ousAll -ScriptDir $createuserscriptpath
   Write-Progress -Activity "Random Stuff into A domain - Creating $NumOfUsers Users" -Status "Progress:" -PercentComplete ($x/$NumOfUsers*100)
$x++
}while($x -lt $NumOfUsers)
$AllUsers = Get-aduser -Filter *

write-host "Creating Groups on Domain" -ForegroundColor Green
$NumOfGroups = 10..100|Get-random 
$X=1
Write-Progress -Activity "Random Stuff into A domain - Creating $NumOfGroups Groups" -Status "Progress:" -PercentComplete ($i/$totalscripts*100)
$I++
.($basescriptPath + '\AD_Groups_Create\CreateGroups.ps1')

do{
   Creategroup
   Write-Progress -Activity "Random Stuff into A domain - Creating $NumOfGroups Groups" -Status "Progress:" -PercentComplete ($x/$NumOfGroups*100)

$x++
}while($x -lt $NumOfGroups)
$Grouplist = Get-ADGroup -Filter { GroupCategory -eq "Security" -and GroupScope -eq "Global"  } -Properties isCriticalSystemObject
$LocalGroupList =  Get-ADGroup -Filter { GroupScope -eq "domainlocal"  } -Properties isCriticalSystemObject
write-host "Creating Computers on Domain" -ForegroundColor Green
$NumOfComps = 10..100|Get-random 
$X=1
Write-Progress -Activity "Random Stuff into A domain - Creating Computers" -Status "Progress:" -PercentComplete ($i/$totalscripts*100)
.($basescriptPath + '\AD_Computers_Create\CreateComputers.ps1')
$I++
do{
   Write-Progress -Activity "Random Stuff into A domain - Creating $NumOfComps computers" -Status "Progress:" -PercentComplete ($x/$NumOfComps*100)
   createcomputer
$x++
}while($x -lt $NumOfComps)
$Complist = get-adcomputer -filter *

$I++
write-host "Creating Permissions on Domain" -ForegroundColor Green
Write-Progress -Activity "Random Stuff into A domain - Creating Random Permissions" -Status "Progress:" -PercentComplete ($i/$totalscripts*100)
.($basescriptPath + '\AD_Permissions_Randomizer\GenerateRandomPermissions.ps1')


$I++
write-host "Nesting objects into groups on Domain" -ForegroundColor Green
.($basescriptPath + '\AD_Groups_Create\AddRandomToGroups.ps1')
Write-Progress -Activity "Random Stuff into A domain - Adding Stuff to Stuff and Things" -Status "Progress:" -PercentComplete ($i/$totalscripts*100)
AddRandomToGroups -Domain $Domain -Userlist $AllUsers -GroupList $Grouplist -LocalGroupList $LocalGroupList -complist $Complist
