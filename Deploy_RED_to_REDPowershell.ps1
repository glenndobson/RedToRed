$ReleaseGroup="Releases" 
$ReleaseProject="001" 

$APP_VER="Deploy" 
$APP_VER= $APP_VER -replace '\s','' #Removes Spaces
$APP_VER=$APP_VER.substring(0,6) #No more than 12 characters
$APP_NUM="Demo"
$ReleaseFolder="001"

$SourceDSN = "Dev"
$SourceDatabaseName = "Dev"

$TGT_DSN = "Test"
$TargetDatabaseName = "Test"
$RED_ARC = 64

$RootFolder="C:\Program Files\WhereScape\RED"
$AppFolder="C:\GitRepo\demoTest\"


$APP_DIR=-join($AppFolder,$ReleaseFolder)

$AppFile = -join( "$APP_DIR\app_id_",$APP_VER,"_$APP_NUM.wst")
$AppLogFile = -join( "$APP_DIR\app_log_",$APP_VER,"_$APP_NUM.log")
$AppConfigFile = -join("C:\X Account\","WSL_Application_Load_SQL.xml")


 
$RESULT_MSG = ""


$PS_STEP = 100 
$PS_Description = "Checks if the app folder exisits and creates if not"

if (-not (Test-Path -LiteralPath $AppFolder)) {
    
    TRY {
        New-Item -Path $AppFolder -ItemType Directory -ErrorAction Stop | Out-Null #-Force
        $RESULT_MSG = -join($RESULT_MSG,"Successfully created appliction directory '$AppFolder'.")
    }
    CATCH { 
        Write-Error -Message "Unable to create appliction directory '$AppFolder'. Error was: $_" -ErrorAction Stop
    }
}  

$PS_STEP = 200 
$PS_Description = "Checks if the project folder exisits and creates if not"

if (-not (Test-Path -LiteralPath $APP_DIR)) {
    
    TRY {
        Remove-Item -Recurse -Force "$APP_DIR" -ErrorAction Ignore
        New-Item -Path $APP_DIR -ItemType Directory -ErrorAction Stop | Out-Null #-Force
        $RESULT_MSG = -join($RESULT_MSG,"Successfully created release folder directory '$APP_DIR'.`n")
    }
    CATCH {
        Write-Error -Message "Unable to create release folder directory '$APP_DIR'. Error was: $_" -ErrorAction Stop
    }
} 

$PS_STEP = 300 
$PS_Description = "Build Red application"
TRY {
    $output = & "$RootFolder\med.exe" --create-deploy-app --meta-dsn "$SourceDSN" --meta-dsn-arch "$RED_ARC" --output-dir "$APP_DIR" --app-version "$APP_VER" --app-number "$APP_NUM" --project-name "$ReleaseFolder"  | Out-String
         
    $RESULT_MSG = -join($RESULT_MSG,"Generated Application for $DocFolder`n")
    $RESULT_MSG = -join($RESULT_MSG,"$output`n")
    $PS_STATUS = 1
}

 

CATCH {
    $RESULT_MSG = -join($RESULT_MSG,"Error! $_`n")
    $PS_STATUS = -2
}


$PS_STEP = 400 
$PS_Description = "Deploy the Wherescapre Red application"
TRY {
    $TGT_ARG =""
    $RED_USR = -join("--red-user-name ", """Glenn Dobson""")

    $output = & "$RootFolder\RedCli.exe" deployment deploy --meta-dsn $TGT_DSN --meta-dsn-arch $RED_ARC $TGT_ARG --app-number $APP_NUM --app-version $APP_VER --app-dir $APP_DIR  > $AppLogFile 2>&1
    $RESULT_MSG = -join($RESULT_MSG,"Application $APP_VER $APP_NUM Released to $TGT_DSN`n")
    $RESULT_MSG = -join($RESULT_MSG,"$output`n")
    #Reads Log File and addes to output
    $output = Get-Content $AppLogFile -Raw
    $RESULT_MSG = -join($RESULT_MSG,"$output`n")
    $PS_STATUS = 1
}

CATCH {
    $RESULT_MSG = -join($RESULT_MSG,"Step: $PS_STEP`n","Step Message: $PS_Description`n","Error! $_`n")
    $PS_STATUS = -2
}

Write-Output $PS_STATUS;  
Write-Output $RESULT_MSG; 
Write-Output $PS_Description;
                       
                       if ($PS_STATUS = 1) 
                       {
                          $LASTEXITCODE = 0
                       }
                       EXIT $LastExitCode
