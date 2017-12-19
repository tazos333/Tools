function Add-DataTakenToFilesName{
    param(
	[Parameter(Mandatory)]
	[string] 
    $Path)
	
	$filesMetadata = Get-FileMetaData -folder $Path
	foreach($fileMetadata in $filesMetadata)
	{
		$dateTaken = Get-DataTaken -fileMetadata $fileMetadata
		if (-not $dateTaken)
		{
			continue;
		}
       
		$fileName = Get-FileName -fileMetadata $fileMetadata

		if($fileName.StartsWith($dateTaken) )
		{
			continue
		}

        $filePath = Join-Path -Path $Path -ChildPath $fileName
        $newName = $dateTaken + ' - ' + $fileName 
        $newPath = Join-Path -Path $Path -ChildPath $newName

        Rename-Item -Path $filePath -newName $newName
	}
}

function Get-FileMetaData
{
    Param([string]$folder)
    $a = 0
    $objShell = New-Object -ComObject Shell.Application
    $objFolder = $objShell.namespace($folder)

    foreach ($File in $objFolder.items())
    { 
        $FileMetaData = New-Object PSOBJECT
        for ($a ; $a  -le 266; $a++)
        { 
            if($objFolder.getDetailsOf($File, $a))
            {
                $hash += @{$($objFolder.getDetailsOf($objFolder.items, $a))  =
                $($objFolder.getDetailsOf($File, $a)) }
                $FileMetaData | Add-Member $hash
                $hash.clear() 
            }
        }  
        $a=0
        $FileMetaData
    }
} 

function Get-DataTaken {
    param ($fileMetadata)
    $rawDate = $fileMetadata.'Data wykonania'
    if($rawDate -eq $null){
      $rawDate = $fileMetadata.'Data modyfikacji'
    }
    $rawDate = $rawDate -replace '[^a-zA-Z0-9 :.]', '' #remove non date format characters
    $datePattern = [System.Threading.Thread]::CurrentThread.CurrentUICulture.DateTimeFormat.ShortDatePattern;
    $timePattern = [System.Threading.Thread]::CurrentThread.CurrentUICulture.DateTimeFormat.ShortTimePattern;
    $pattern = "$datePattern $timePattern"
    $culture = [System.Globalization.CultureInfo]::InvariantCulture 

    $parsedDate = [DateTime]::ParseExact($rawDate, $pattern, $culture)

    $formatedDate = $parsedDate.ToString('yyyy.MM.dd HH-mm');
    $formatedDate 
}


function Get-FileName {
    param ($fileMetadata)
    $name = $fileMetadata.'Nazwa'
    $extenstion = Get-Extension -fileMetadata $fileMetadata
    if($name.EndsWith($extenstion) )
    {
        $name
    }
    $name = $name + $extenstion
    $name
}

function Get-Extension {
    param ($fileMetadata)
    $rawExtension= $fileMetadata.'Rozszerzenie Pliku'
    $rawExtension
}
