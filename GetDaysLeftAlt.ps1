#needs merging with other version 
#this version is multi channel and checks if the domain is transfer and updated locked

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

Write-Host $expirationresult

$datestring = $expirationresult.Substring($expirationtextsearch.Length)

$expiredate = Get-Date $datestring
$daystoexpire = ($expiredate - (Get-Date)).Days

$daystoexpirewarning = 0 
if($daystoexpire -le 30){
    $daystoexpirewarning =1
}

#$x=[string]$daystoexpire+":The domain registration expires in "+$daystoexpire+" days."
#write-host $x





Write-Host "<prtg>"

Write-Host "<result>"
Write-Host "    <channel>DaystoExpire</channel>"
Write-Host "    <unit>#</unit>"
Write-Host "    <LimitMinWarning>30</LimitMinWarning>"
Write-Host "    <LimitMinError>7</LimitMinError>"
Write-Host "    <warning>"$daystoexpirewarning"</warning>"
Write-Host "    <LimitMode>1</LimitMode>"
Write-Host "    <float>0</float>"
Write-Host "    <value>"$daystoexpire"</value>"
Write-Host "</result>"

$clientTransferProhibitedwarning = 0
$clientTransferProhibited = 0
$clientTransferProhibited = $whoisoutput | % { if($_ -match "clientTransferProhibited") {1}}
if ($clientTransferProhibited -cne '1'){
    $clientTransferProhibitedwarning = 1
}

Write-Host "<result>"
Write-Host "    <channel>clientTransferProhibited</channel>"
Write-Host "    <unit>#</unit>"
Write-Host "    <warning>"$clientTransferProhibitedwarning"</warning>"
Write-Host "    <float>0</float>"
Write-Host "    <value>"$clientTransferProhibited"</value>"
Write-Host "</result>"

$clientUpdateProhibitedwarning = 0
$clientUpdateProhibited = 0
$clientUpdateProhibited  = $whoisoutput | % { if($_ -match "clientUpdateProhibited") {1}}
if ($clientUpdateProhibited  -cne '1'){
    $clientUpdateProhibitedwarning = 1
}

Write-Host "<result>"
Write-Host "    <channel>clientUpdateProhibited</channel>"
Write-Host "    <unit>#</unit>"
Write-Host "    <warning>"$clientUpdateProhibitedwarning"</warning>"
Write-Host "    <float>0</float>"
Write-Host "    <value>"$clientUpdateProhibited"</value>"
Write-Host "</result>"

#Will show warning if doman status is equal to ok as this implies that it is not locked and updated prohibited 
$DomainstatusOKwarning = 0
$DomainstatusOK = 0
$DomainstatusOK  = $whoisoutput | % { if($_ -match "Domain Status: ok") {1}}
if ($DomainstatusOK  -eq '1'){
    $DomainstatusOKwarning = 1
}

Write-Host "<result>"
Write-Host "    <channel>DomainstatusOK</channel>"
Write-Host "    <unit>#</unit>"
Write-Host "    <warning>"$DomainstatusOKwarning"</warning>"
Write-Host "    <float>0</float>"
Write-Host "    <value>"$DomainstatusOK"</value>"
Write-Host "</result>"

Write-Host "<Text>"The domain registration expires in "$daystoexpire" days."</Text>"

Write-Host "</prtg>"

exit 0
