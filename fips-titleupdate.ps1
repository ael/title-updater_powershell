$path_studio1 = '\\fips-server\share\rds\source-current\Studio1-current.txt'
$path_studio2 = '\\fips-server\share\rds\source-current\Studio2-current.txt'
$path_geislingen = '\\fips-server\share\rds\source-current\StudioGEIS-current.txt'
$path_mobil = '\\fips-server\share\rds\source-current\StudioMOBFW-current.txt'
$path_zara = '\\fips-server\share\rds\source-current\CurrentSong.txt'
$path_onairstudio = '\\fips-server\share\rds\onair-studio.txt'
$path_nowonair = '\\fips-server\share\rds\now-onair.txt'
$broadcast_ip = "172.20.10.255"
$udp_port = 5005

$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$udp = New-Object Net.Sockets.UdpClient
$udp.EnableBroadcast = $true

$studioref = $null
Write-Output "$(Get-Date -format 'u') | Script gestartet"

While($true) {

$onairstudio = Get-Content -Path $path_onairstudio
$nowonair = Get-Content -Path $path_nowonair

if($studioref -ne $onairstudio) {
    Write-Output "$(Get-Date -format 'u') | $onairstudio"
    $message = @{studio = $onairstudio} | ConvertTo-Json -Depth 1
    $bytes = [Text.Encoding]::ASCII.GetBytes($message)
    $udp.Send($bytes, $bytes.Length, $broadcast_ip, $udp_port)
    $studioref = $onairstudio
}

function Send-Udp($songinfo) {
    $message = @{song = $songinfo} | ConvertTo-Json -Depth 1
    $bytes = [Text.Encoding]::ASCII.GetBytes($message)
    $udp.Send($bytes, $bytes.Length, $broadcast_ip, $udp_port)
}



Switch($onairstudio) {
    'Studio 1'{
        $studio1 = Get-Content -Path $path_studio1
        if($nowonair -ne $studio1){
            $studio1 > $path_nowonair
            Send-Udp ($studio1)
            Write-Output "$(Get-Date -format 'u') | $studio1"
        }
    }
    'Studio 2'{
        $studio2 = Get-Content -Path $path_studio2
        if($nowonair -ne $studio2){
            $studio2 > $path_nowonair
            Send-Udp ($studio2)
            Write-Output "$(Get-Date -format 'u') | $studio2"
        }
    }
    'Studio Geislingen'{
        $geislingen = Get-Content -Path $path_geislingen
        if($nowonair -ne $geislingen){
            $geislingen > $path_nowonair
            Send-Udp ($geislingen)
            Write-Output "$(Get-Date -format 'u') | $geislingen"
        }        
    }
    'Studio Mobil/FW'{
        $mobil = Get-Content -Path $path_mobil
        if($nowonair -ne $mobil){
            $mobil > $path_nowonair
            Send-Udp ($mobil)
            Write-Output "$(Get-Date -format 'u') | $mobil"
        }
    }
    'Loop / Zara'{
        $zara = Get-Content -Path $path_zara
        if($nowonair -ne $zara){
            $zara > $path_nowonair
            Send-Udp ($zara)
            Write-Output "$(Get-Date -format 'u') | $zara"
        }
    }
    'Havarie'{
        "FIPS ;-)" > $path_nowonair
        Send-Udp ("HAVARIE")
        Write-Output "$(Get-Date -format 'u') | HAVARIE!!!"
    }
  }
    Start-Sleep -m 1500
}
