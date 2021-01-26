# asks for number of webcams, bitrate and framerate. writes those values with cpu load into a csv file.

$file = "cpu_load.csv"
$sleep = 1
$samples = 20

# get cpu load
$webcams = Read-Host -Prompt 'Webcams'
$bitrate = Read-Host -Prompt 'Bitrate'
$framerate = Read-Host -Prompt 'framerate'

if (-not (Test-Path $file)) {
  Add-Content -Path $file -Value "webcams,bitrate,framerate,datetime,sample,cpu"
}

$i=1
do {
  write-host "loop number $i"
  sleep $sleep
  
  $datetime = Get-Date -Format "o"
  $cpu=(Get-WmiObject Win32_Processor | Measure-Object -Property LoadPercentage -Average | Select Average).Average
  Add-Content -Path $file -Value "$webcams,$bitrate,$framerate,$datetime,$i,$cpu"
  
  $i++ 
}while ($i -le $samples)