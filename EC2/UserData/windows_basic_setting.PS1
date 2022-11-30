<powershell>
# Change Password
function ChangePasswd( $UserID, $Password )
{
$hostname = $Env:COMPUTERNAME
[ADSI]$UpdateUser = “WinNT://$HostName/$UserID,User”
$UpdateUser.SetPassword( $Password )
$UpdateUser.SetInfo()
}
$UserID = “Administrator”
$Password = “password“
ChangePasswd $UserID $Password
#
# Set TimeZone
tzutil /s “Tokyo Standard Time”
w32tm /config /manualpeerlist:169.254.169.123 /syncfromflags:manual /update
reg add “HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\TimeZoneInformation” /v RealTimeIsUniversal /d 1 /t REG_DWORD /f
#
# Set Proxy
reg add “HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings” /f /v ProxyEnable /t reg_dword /d 1
reg add “HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings” /f /v ProxyServer /t reg_sz /d （proxy）:（port）
reg add “HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings” /f /v ProxyOverride /t reg_sz /d “（proxy exception setting）;169.254.169.254;<local>”
#
# Rename Computer
Rename-Computer -NewName <hostname> -Force -Restart
#
</powershell>