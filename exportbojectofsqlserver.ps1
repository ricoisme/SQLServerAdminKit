
$serverInstance 		= "127.0.0.1,1533"
$database 		= "WideWorldImporters"
$output_path 		= "D:\TestFiles"
$dateFolder = (Get-Date -Format "yyyyMMddHHmm")

[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | out-null

$SMOserver = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $serverInstance
# Set SQL authentication
$SMOserver.ConnectionContext.LoginSecure = $false  # False means SQL Authentication
$SMOserver.ConnectionContext.Login = "sa"
$SMOserver.ConnectionContext.Password = "Sa12345678"

$db 		= New-Object ("Microsoft.SqlServer.Management.SMO.Database")
$tbl 		= New-Object ("Microsoft.SqlServer.Management.SMO.Table")
$scripter 	= New-Object ("Microsoft.SqlServer.Management.SMO.Scripter") ($SMOserver)

# Get the database and table objects
$db = $SMOserver.Databases[$database]

#$schema 		= "dbo"
$table_path 		= "$output_path\$dateFolder\$db\Table\"
$storedProcs_path 	= "$output_path\$dateFolder\$db\StoredProcedure\"
$triggers_path 		= "$output_path\$dateFolder\$db\Triggers\"
$views_path 		= "$output_path\$dateFolder\$db\View\"
$udfs_path 			= "$output_path\$dateFolder\$db\UserDefinedFunction\"
$textCatalog_path 	= "$output_path\$dateFolder\$db\FullTextCatalog\"
$udtts_path 		= "$output_path\$dateFolder\$db\UserDefinedTableTypes\"
$synonys_path 		= "$output_path\$dateFolder\$db\Synonyms\"
$sequence_path 		= "$output_path\$dateFolder\$db\Sequences\"

$tbl		 	= $db.tables | Where-object { $_.IsSystemObject -eq $false } 
$storedProcs		= $db.StoredProcedures | Where-object { $_.IsSystemObject -eq $false } 
$triggers		= $db.Triggers + ($tbl | % { $_.Triggers })
$views 		 	= $db.Views | Where-object { $_.IsSystemObject -eq $false } 
$udfs		 	= $db.UserDefinedFunctions | Where-object { $_.IsSystemObject -eq $false } 
					#$_.schema -eq $schema -and -not $_.IsSystemObject
#$catlog		 	= $db.FullTextCatalogs
$udtts		 	= $db.UserDefinedTableTypes
$synonyms 		= $db.Synonyms
$sequences 		= $db.Sequences
	
# Set scripter options to ensure only data is scripted
$scripter.Options.ScriptSchema 	= $true;
$scripter.Options.ScriptData 	= $false;
$scripter.Options.FileName = $null

#Exclude GOs after every line
$scripter.Options.NoCommandTerminator 			= $false;
$scripter.Options.ToFileOnly 				= $true
$scripter.Options.AllowSystemObjects 			= $false
$scripter.Options.Permissions 				= $false
$scripter.Options.DriAllConstraints 			= $true
$scripter.Options.SchemaQualify 			= $true
$scripter.Options.AnsiFile 				= $false

$scripter.Options.SchemaQualifyForeignKeysReferences 	= $false

$scripter.Options.Indexes 				= $false
$scripter.Options.DriIndexes 				= $false
$scripter.Options.DriClustered 				= $false
$scripter.Options.DriNonClustered 			= $false
$scripter.Options.NonClusteredIndexes 			= $false
$scripter.Options.ClusteredIndexes 			= $false
$scripter.Options.FullTextIndexes 			= $false

$scripter.Options.EnforceScriptingOptions 		= $false

function CopyObjectsToFiles($objects, $outDir) {	
	
	if (-not (Test-Path -Path $outDir)){
		New-Item -Type Directory -Path $outDir | Out-Null		
	} 	
	
	foreach ($o in $objects) { 
	
		if ($o -ne $null) {
			
			$schemaPrefix = ""
			
			if ($o.Schema -ne $null -and $o.Schema -ne "") {
				$schemaPrefix = $o.Schema + "."
			}	
			
			$scripter.Options.ScriptDrops 	= $true
			$dropScript = $scripter.EnumScript($o) +" GO;"
			
			$scripter.Options.ScriptDrops = $false
			$createScript = $scripter.EnumScript($o)+" GO;"
			
			$fullScript = ($dropScript -join [Environment]::NewLine) + [Environment]::NewLine + ($createScript -join [Environment]::NewLine)
            $scriptFile =  $outDir + $schemaPrefix + $o.Name + ".sql"
		  
			#$scripter.Options.FileName = $outDir + $schemaPrefix + $o.Name + ".sql"			
			[System.IO.File]::WriteAllText($scriptFile, $fullScript)
			Write-Host "Writing " $scriptFile
			#$scripter.EnumScript($o)
			
		}
	}
}

# Output the scripts
#CopyObjectsToFiles $tbl $table_path
#CopyObjectsToFiles $storedProcs $storedProcs_path
#CopyObjectsToFiles $triggers $triggers_path
#CopyObjectsToFiles $views $views_path
#CopyObjectsToFiles $catlog $textCatalog_path
#CopyObjectsToFiles $udtts $udtts_path
#CopyObjectsToFiles $udfs $udfs_path
CopyObjectsToFiles $synonyms $synonys_path
CopyObjectsToFiles $sequences $sequence_path

Write-Host "Finished at" (Get-Date)