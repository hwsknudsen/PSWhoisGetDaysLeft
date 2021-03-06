#whois.exe from micrsoft must be in specified in script or set as a variable
#example .\GetDaysLeft.ps1 rg.bm "Registrar Registration Expiration Date: " whois.asaplatform.info
#example .\GetDaysLeft.ps1 google.com "Registrar Registration Expiration Date: "
#example .\GetDaysLeft.ps1 bbc.co.uk "        Expiry date:" 

#if whois server uses a custom date try something like below
#.\GetDaysLeft.ps1 -domain fre.fr -expirationtextsearch "Expiry Date: " -dateformattstring "dd/MM/yyyy"
#Custom Date and Time Format Strings https://msdn.microsoft.com/en-us/library/8kb3ddd4(v=vs.110).aspx

Param(
  [Parameter(Mandatory=$true)]
  [string]$domain,
  [Parameter(Mandatory=$true)]
  [string]$expirationtextsearch,
  [string]$whoisserveroveride,  
  [string]$dateformattstring,
  [string]$whoislocation
)

if(!$whoislocation){
    $Command = "c:\Windows\System32\whois.exe"
}else{
    $Command = $whoislocation    
}

$Parms = "/accepteula $domain $whoisserveroveride"
$Prms = $Parms.Split(" ")
$whoisoutput = (& "$Command" $Prms) 

$expirationresult = $whoisoutput | % { if($_ -match $expirationtextsearch) {$_}}

$datestring = $expirationresult.Substring($expirationtextsearch.Length)

if (!$dateformattstring){
    $expiredate = Get-Date $datestring
}else{
    $datestring = $datestring.substring(0,$dateformattstring.Length)
    $expiredate = [DateTime]::ParseExact($datestring, $dateformattstring, $null)
}



$daystoexpire = ($expiredate - (Get-Date)).Days

if ($daystoexpire -gt 3650){
    $x=[string]$daystoexpire+":The domain registration expires in "+$daystoexpire+" days. This is invalid as it exceeds ICAAN 10 years"
    write-host $x
    exit 4 
}

if ($daystoexpire -lt 0){
    $x=[string]$daystoexpire+":The domain registration expires in "+$daystoexpire+" days. This is invalid as it is negative "
    write-host $x
    exit 4 
}



$x=[string]$daystoexpire+":The domain registration expires in "+$daystoexpire+" days."
write-host $x

exit 0
