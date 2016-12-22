#example .\GetDaysLeft.ps1 rg.bm "Registrar Registration Expiration Date: " whois.asaplatform.info
#example .\GetDaysLeft.ps1 google.com "Registrar Registration Expiration Date: "
#whois.exe from micrsoft must be in specified in script 
Param(
  [Parameter(Mandatory=$true)]
  [string]$domain,
  [Parameter(Mandatory=$true)]
  [string]$expirationtextsearch,
  [string]$whoisserveroveride
)

$Command = "C:\Program Files (x86)\PRTG Network Monitor\custom sensors\EXE\whois.exe"
$Parms = "/accepteula $domain $whoisserveroveride"
$Prms = $Parms.Split(" ")
$whoisoutput = (& "$Command" $Prms) 

$expirationresult = $whoisoutput | % { if($_ -match $expirationtextsearch) {$_}}

$datestring = $expirationresult.Substring($expirationtextsearch.Length)

$expiredate = Get-Date $datestring
$daystoexpire = ($expiredate - (Get-Date)).Days


$x=[string]$daystoexpire+":The domain registration expires in "+$daystoexpire+" days."
write-host $x

exit 0
