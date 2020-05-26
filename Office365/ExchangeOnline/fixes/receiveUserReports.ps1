
#Modify email adress and rule name below: 
$recipient = "YOUREMAILADRESS"
$name = "[ZOLDER] Recieve user alerts"

New-TransportRule $name -SentTo "abuse@messaging.microsoft.com","junk@office365.microsoft.com","phish@office365.microsoft.com" -BlindCopyTo $recipient -StopRuleProcessing $false -Mode "Enforce" -Comment "" -RuleErrorAction "Ignore" -SenderAddressLocation "Header"

