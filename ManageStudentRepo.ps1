$StudentFolderPath = ".\StudentRepos"
if (-not (Test-Path -Path $StudentFolderPath)) {
    New-Item -ItemType Directory -Path $StudentFolderPath
}
Set-Location -Path $StudentFolderPath
$ErrorActionPreference = 'SilentlyContinue'
function Add-Student 
{
	Write-Host "Student Name: " -NoNewline -ForegroundColor DarkGreen
	[Console]::ForegroundColor = "Green"
	$filename = Read-Host
	[Console]::ResetColor()
	Write-Host "GitHub repo link: " -NoNewline -ForegroundColor DarkGreen
	[Console]::ForegroundColor = "Green"
	$githublink = Read-Host
	[Console]::ResetColor()
	mkdir $filename
	Set-Location .\$filename
	git clone $githublink
	Set-Location ..
}

function Find-Spaces
{
	param
	(
		$index
	)
	$spaces = "" 
	if($index -lt 10)
	{$spaces = "  "}
	elseif ($index -ge 10)
	{$spaces = " "}
	else
	{$spaces = "Error"}
	return $spaces
}

function Get-Students
{
    $arr = Get-ChildItem . | Where-Object {$_.PSIsContainer}

    if($arr.Count -eq 0)
    {
        Write-Host "How many students to add? " -NoNewline -ForegroundColor DarkGreen
        [Console]::ForegroundColor = "Green"
        $numStudents = Read-Host
        [Console]::ResetColor()
        for($index = 0; $index -lt $numStudents; $index++)
        {
            Add-Student
        }
        $arr = Get-ChildItem . | Where-Object {$_.PSIsContainer}
    }

    $unsortedStudents = foreach($node in $arr)
    {
        $name = $node.Name -split " ", 2
        [pscustomobject]@{Path=$node; LastName=$name[1]}
    }
    $sortedStudents = $unsortedStudents | Sort-Object -Property LastName
    return $sortedStudents
}

function Show-Students
{
	param(
	$sortedStudents
	)
	
	Write-Host " Index    Student Name" -ForegroundColor Green
	Write-Host "-------  --------------" -ForegroundColor Green
	for ( $index = 0; $index -lt $sortedStudents.Count; $index++)
	{
	$spaces = Find-Spaces $index
	$formattedStudent = "{0}{1}       {2}" -f $index, $spaces, $sortedStudents[$index].Path.Name
	if($index % 2 -eq 0)
	{
		Write-Host $formattedStudent -ForegroundColor Blue
	}
	else
	{
		Write-Host $formattedStudent -ForegroundColor Cyan
	}
	
	}
}


function Remove-Student
{
	param($sortedStudents)
	Show-Students $sortedStudents
	Write-Host "-------" -ForegroundColor Green
	Write-Host "Student Index: " -NoNewline -ForegroundColor DarkGreen
	[Console]::ForegroundColor = "Green"
	$userInput = Read-Host
	[Console]::ResetColor()
	Write-Host "-------" -ForegroundColor Green
	$formattedStudentSelection = "Student Selected: {0}" -f $sortedStudents[$userInput].Path.Name
	Write-Host $formattedStudentSelection
	Write-Host "-------" -ForegroundColor Green
	Remove-Item $sortedStudents[$userInput].Path
	
}

function Remove-All
{
	Get-ChildItem . | Where-Object {$_.PSIsContainer} | Remove-Item -Recurse -Force
}


$continue = 1

while($continue)
{
$sortedStudents = Get-Students
Show-Students $sortedStudents
$spaces = Find-Spaces $sortedStudents.Count
$formattedAdd = "{0}{1}       -Add Student-" -f $sortedStudents.Count, $spaces
Write-Host $formattedAdd -ForegroundColor Red

$deleteIndex = $sortedStudents.Count + 1
$spaces = Find-Spaces $deleteIndex
$formattedDelete = "{0}{1}       -Delete Student-" -f $deleteIndex, $spaces
Write-Host $formattedDelete -ForegroundColor Red

$deleteAllIndex = $deleteIndex + 1
$spaces = Find-Spaces $deleteAllIndex
$formattedDeleteAll = "{0}{1}       -Delete All Students-" -f $deleteAllIndex, $spaces
Write-Host $formattedDeleteAll -ForegroundColor Red

$quitIndex = $deleteAllIndex + 1
$spaces = Find-Spaces $quitIndex
$formattedQuit = "{0}{1}       -Quit-" -f $quitIndex, $spaces
Write-Host $formattedQuit -ForegroundColor Red



Write-Host "-------" -ForegroundColor Green
Write-Host "Index: " -NoNewline -ForegroundColor DarkGreen
[Console]::ForegroundColor = "Green"
$userInput = Read-Host
[Console]::ResetColor()
Write-Host "-------" -ForegroundColor Green
if($userInput -eq $sortedStudents.Count)
{Add-Student}
elseif($userInput -eq $deleteIndex)
{Remove-Student $sortedStudents}
elseif($userInput -eq $deleteAllIndex)
{Remove-All}
elseif($userInput -eq $quitIndex)
{$continue = 0}
else
{
$formattedStudentSelection = "Student Selected: {0}" -f $sortedStudents[$userInput].Path.Name
Write-Host $formattedStudentSelection -ForegroundColor DarkGreen
Write-Host "-------" -ForegroundColor Green
Set-Location $sortedStudents[$userInput].Path
Set-Location */
git pull
code .
Set-Location ../..
}
}