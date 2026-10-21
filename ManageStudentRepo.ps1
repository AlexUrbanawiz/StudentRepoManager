$StudentFolderPath = ".\StudentRepos"
if (-not (Test-Path -Path $StudentFolderPath)) {
    New-Item -ItemType Directory -Path $StudentFolderPath
}
Set-Location -Path $StudentFolderPath
$ErrorActionPreference = 'SilentlyContinue'
function Add-Student($studentNumber=0) 
{
	do {
		Write-Host "Student Name: " -NoNewline -ForegroundColor DarkGreen
		[Console]::ForegroundColor = "Green"
		$filename = Read-Host
		$validFilename = Validate "Student Name" $filename $studentNumber
		if($validFilename -eq $false)
		{
			Write-Host "Invalid name, try again" -ForegroundColor DarkRed
		}
	} while ($validFilename -eq $false)
	
	[Console]::ResetColor()
	do {
		Write-Host "GitHub repo link: " -NoNewline -ForegroundColor DarkGreen
		[Console]::ForegroundColor = "Green"
		$githublink = Read-Host
		$validLink = Validate "Github Repo" $githublink
		if($validLink -eq $false)
		{
			Write-Host "Invalid link, try again" -ForegroundColor DarkRed
		}
	} while ($validLink -eq $false)
	
	[Console]::ResetColor()
	mkdir $filename
	Set-Location .\$filename
	git clone $githublink
	Set-Location ..
}

function Validate($userInputType, $userInput, $studentCount=0)
{
	$valid = $false
	switch($userInputType)
	{
		"Student Name" 
		{
			# Checks to make sure the student's name is valid by having a first and last name, and making sure the name is not already present
			$splitName = $userInput -split " ", 2
			# Write-Host $splitName.Count -ForegroundColor Cyan
			if($splitName.Count -eq 2)
			{
				if($studentCount -gt 0)
				{
					$duplicate = $false
					$students = Get-Students
					foreach($student in $students)
					{
						$loweredStudentFullName = [string]$student.FullName.ToLower()
						$loweredUserInput = [string]$userInput.ToLower()

						if($loweredStudentFullName -eq $loweredUserInput)
						{
							$duplicate = $true
						}
					}
					if(-not $duplicate)
					{
						$valid = $true
					}

				}
				else
				{
					$valid = $true
				}
			}
			break
		}
		"Github Repo" 
		{
			# Checks to make sure the link is valid by making sure the beginnign of the string matches that of a github repo link, and the end is .git
			# The first 19 characters of a gitub repolink are "https://github.com/", and the final 4 are ".git"
			$urlStart = $userInput.Substring(0, 19)
			$urlEnd = $userInput.Substring($userInput.Length -4)
			if($urlStart -eq "https://github.com/" -and $urlEnd -eq ".git")
			{
				$valid = $true
			}
			break
		}
		"Student Index" 
		{
			# Checks to make sure the index inputted is an existing student
			if ($studentCount -gt 0 -and $userInput -lt $studentCount -and $userInput -ge 0 -and $userInput -is [int]) 
			{
				$valid = $true
			}
			break

		}
		"Extra Index"
		{
			# studentCountExtra is the number of students + number of extra indices (Add student, delete student ...)
			$studentCountExtra = $studentCount + 3
			if ($userInput -is [int] -and $userInput -ge $studentCount -and $userInput -le $studentCountExtra) 
			{
				$valid = $true
			}
		}
	}
	return $valid
}

function Find-Spaces($index)
{
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
            Add-Student $index
        }
        $arr = Get-ChildItem . | Where-Object {$_.PSIsContainer}
    }

    $unsortedStudents = foreach($node in $arr)
    {
        $name = $node.Name -split " ", 2
        [pscustomobject]@{Path=$node; LastName=$name[1]; FullName=$name}
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
	Remove-Item $sortedStudents[$userInput].Path -Recurse -Force
	
}

function Remove-All
{
	Get-ChildItem . | Where-Object {$_.PSIsContainer} | Remove-Item -Recurse -Force
}

# I want to be able to either input the index of a student/extra command, or input the name of a student/extra command. And have both work the same.

function Open-Student($studentIndex, $sortedStudents)
{
	$formattedStudentSelection = "Student Selected: {0}" -f $sortedStudents[$studentIndex].Path.Name
	Write-Host $formattedStudentSelection -ForegroundColor DarkGreen
	Write-Host "-------" -ForegroundColor Green
	$baseLocation = Get-Location
	Set-Location $sortedStudents[$userInput].Path
	Set-Location */
	git pull
	code .
	Set-Location $baseLocation
}


function Get-MenuLookUp($sortedStudents)
{
	$deleteIndex = $sortedStudents.Count + 1
	$deleteAllIndex = $deleteIndex + 1
	$quitIndex = $deleteAllIndex + 1
	$hash = $null
	$hash = @{}
	for ($i = 0; $i -lt $sortedStudents.Count; $i++) {
		$student = $sortedStudents[$i]
		$joinedFullName = $student.Path.Name
		$hash.add($joinedFullName, $i)
		$hash.add([string]$i,$i)
	}
	$hash.add("Add Student", $sortedStudents.Count)
	$hash.add([string]$sortedStudents.Count, $sortedStudents.Count)

	$hash.add("Delete Student", $deleteIndex)
	$hash.add([string]$deleteIndex, $deleteIndex)

	$hash.add("Delete All Students", $deleteAllIndex)
	$hash.add([string]$deleteAllIndex, $deleteAllIndex)

	$hash.add("Quit", $quitIndex)
	$hash.add([string]$quitIndex, $quitIndex)

	return $hash
}

function Get-MenuKeys($sortedStudents)
{
	$hash = Get-MenuLookUp $sortedStudents
	return $hash.Keys
}




function Process-Input($userInput, $sortedStudents)
{
	$userInput = [string]$userInput
	$proceed = 1
	
	$hash = Get-MenuLookUp $sortedStudents
	
	if($hash.ContainsKey($userInput))
	{
		$hashedInput = $hash[$userInput]
		switch($hashedInput)
		{
			$sortedStudents.Count {Add-Student}
			$deleteIndex {
				Write-Host "WARNING, THIS IS IRREVERSIBLE. DO YOU WANT TO CONTINUE? (y/n)" -ForegroundColor Red
				$warningResponse = [string](Read-Host).ToLower()
				if($warningResponse -eq "y")
				{
				Remove-Student $sortedStudents
				}}
			$deleteAllIndex {
				Write-Host "WARNING, THIS IS IRREVERSIBLE. DO YOU WANT TO CONTINUE? (y/n)" -ForegroundColor Red
				$warningResponse = [string](Read-Host).ToLower()
				if($warningResponse -eq "y")
				{
				Remove-All
				$proceed = 0
				}}
			$quitIndex {$proceed = 0}
			default {Open-Student $hashedInput $sortedStudents}
		}
	}
	else
	{
		Write-Host "Invalid Index, try again" -ForegroundColor DarkRed
	}

}

function ss($studentName)
{
	$sortedStudents = Get-Students
	$sortedStudents = Get-Students
	Process-Input $studentName $sortedStudents
	Display-Menu
}

Register-ArgumentCompleter `
    -CommandName ss `
    -ParameterName studentName `
    -ScriptBlock {
        param(
            $commandName,
            $parameterName,
            $wordToComplete,
            $commandAst,
            $fakeBoundParameters
        )

        $sortedStudents = Get-Students
        $entries = Get-MenuKeys $sortedStudents

        foreach($entry in $entries)
        {
            if($entry -like "$wordToComplete*")
            {
                $completionText =
                    if($entry.Contains(" "))
                    {
                        "`"$entry`""
                    }
                    else
                    {
                        $entry
                    }

                [System.Management.Automation.CompletionResult]::new(
                    $completionText,
                    $entry,
                    [System.Management.Automation.CompletionResultType]::ParameterValue,
                    $entry
                )
            }
        }
    }


function Display-Menu()
{
	
	$sortedStudents = Get-Students
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
	Write-Host "Use ss <name/index> to access repo" -ForegroundColor Green
}

Display-Menu
