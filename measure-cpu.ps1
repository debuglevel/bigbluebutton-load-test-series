# asks for number of webcams, bitrate and framerate. writes those values with cpu load into a csv file.

$computername = $env:computername
$maxcpufrequency = Get-CimInstance Win32_Processor | Select-Object -Expand MaxClockSpeed

# constants
$file = "cpu_load.csv"

$couchdb = $True
if ($couchdb = $True)
{
	<#
	Sample document in CouchDB
	{
	  "_id": "c6c8bec9df3080ad9bff716f840008c2",
	  "_rev": "5-42e3f2fb51a32024752e8d8f6657c8a2",
	  "webcams": 12,
	  "framerate": 12,
	  "bitrate": 12,
	  "sleep": 1,
	  "samples": 10
	}
	#>

  $couchhost = "localhost:5984"
  $user = "admin"
  $password = "password"
  #http://$user:$password@$host/api/index/bigbluebutton-load-test-series-settings
  $document = "c6c8bec9df3080ad9bff716f840008c2"
  $url = "http://${user}:${password}@${couchhost}/bigbluebutton-load-test-series-settings/$document"

  echo "Getting settings from CouchDB..."
  $request = Invoke-WebRequest -Method GET -Headers @{"Authorization" = "Basic "+[System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("${user}:${password}")); "Content-Type"="application/json"} -Uri $url
  $content = ($request).Content
  $json = $content | ConvertFrom-JSON
  #$json | Write-Host
  #$json.webcams | Write-Host
  $webcams = $json.webcams
  $bitrate = $json.bitrate
  $framerate = $json.framerate
  $sleep = $json.sleep
  $samples = $json.samples
  
  echo "Using this settings:"
  echo "Webcams: ${webcams}"
  echo "Framerate: ${framerate}"
  echo "Bitrate: ${bitrate}"
  echo "Sleep: ${sleep}"
  echo "Samples: ${samples}"
  
  Read-Host -Prompt "Press Enter to continue"
}else{
  $sleep = 1
  $samples = 20

  # read current settings
  $webcams = Read-Host -Prompt 'Webcams'
  $bitrate = Read-Host -Prompt 'Bitrate'
  $framerate = Read-Host -Prompt 'Framerate'
  
  Read-Host -Prompt "Press Enter to continue"
}

# write csv header
if (-not (Test-Path $file)) {
  Add-Content -Path $file -Value "maxcpufrequency,CurrentClockSpeed,computername,webcams,bitrate,framerate,datetime,sample,cpu"
}

# get and writes samples
$i=1
do {
  write-host "loop number $i"
  sleep $sleep
  
  # TODO: https://stackoverflow.com/questions/61802420/unable-to-get-current-cpu-frequency-in-powershell-or-python
  $ProcessorPerformance = (Get-Counter -Counter "\prozessor(_total)\prozessorzeit (%)").CounterSamples.CookedValue
  echo $ProcessorPerformance
  $ProcessorPerformance = ($ProcessorPerformance) -split ',' -join '.'
  echo $ProcessorPerformance
  $CurrentClockSpeed = $maxcpufrequency*($ProcessorPerformance/100)
  echo $CurrentClockSpeed
  
  $datetime = Get-Date -Format "o"
  $cpu=(Get-WmiObject Win32_Processor | Measure-Object -Property LoadPercentage -Average | Select Average).Average
  Add-Content -Path $file -Value "$maxcpufrequency,$CurrentClockSpeed,$computername,$webcams,$bitrate,$framerate,$datetime,$i,$cpu"
  
  $i++ 
}while ($i -le $samples)