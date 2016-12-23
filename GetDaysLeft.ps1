#whois.exe from micrsoft must be in specified in script or set as a avariable
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
  [string]$dateformattstring,
  [string]$whoisserveroveride,
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
    $expiredate = [DateTime]::ParseExact($datestring, $dateformattstring, $null)
}

$daystoexpire = ($expiredate - (Get-Date)).Days

$x=[string]$daystoexpire+":The domain registration expires in "+$daystoexpire+" days."
write-host $x

exit 0
