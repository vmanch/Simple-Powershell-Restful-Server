# PowerShell RESTful server
#v1.0 vMan.ch, 31.05.2017 - Initial Version

$ScriptPath = (Get-Item -Path ".\" -Verbose).FullName

# Start of script
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add('http://+:6667/') # Must exactly match the netsh command above
$listener.Prefixes.Add('https://+:6666/')

$RunCollection = 1 
 
$listener.Start()
'Listening ...'
while ($true) {
    $context = $listener.GetContext() # blocks until request is received
    $request = $context.Request
    $response = $context.Response


    if ($request.Url -match '/customrest$') {
        $response.ContentType = 'text/xml'
        $hour = [System.DateTime]::Now.Hour
        $minute = [System.DateTime]::Now.Minute
        $message = "<?xml version=""1.0""?><Time><Hour>$hour</Hour><Minute>$minute</Minute></Time>"
        $request.HttpMethod
        $StreamReader = New-Object System.IO.StreamReader $request.InputStream
        $StreamData = $StreamReader.ReadToEnd()
        $RunDateTime = (Get-date)
        $RunDateTime = $RunDateTime.tostring("yyyyMMddHHmmss")
        $StreamData | out-file -FilePath "$ScriptPath\requests\$RunDateTime-$RunCollection.xml"
        $RunCollection += 1 
    }

    if ($request.Url -match '/rest$') {
        $response.ContentType = 'application/xml'
        $hour = [System.DateTime]::Now.Hour
        $minute = [System.DateTime]::Now.Minute
        $message = "<?xml version=""1.0""?><Time><Hour>$hour</Hour><Minute>$minute</Minute></Time>"
        $request.HttpMethod
        $StreamReader = New-Object System.IO.StreamReader $request.InputStream
        $StreamData = $StreamReader.ReadToEnd()
        $RunDateTime = (Get-date)
        $RunDateTime = $RunDateTime.tostring("yyyyMMddHHmmss") 
        $StreamData | out-file -FilePath "$ScriptPath\requests\$RunDateTime-$RunCollection.xml"
        $RunCollection += 1 
    }	
	
    if ($request.Url -match '/stop$') {break}
 
    [byte[]] $buffer = [System.Text.Encoding]::UTF8.GetBytes($message)
    $response.ContentLength64 = $buffer.length
    $output = $response.OutputStream
    $output.Write($buffer, 0, $buffer.length)
    $output.Close()

}
 
$listener.Stop()