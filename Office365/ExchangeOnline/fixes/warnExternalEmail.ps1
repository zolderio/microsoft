#fill out the organisation name and email adress 
$orgName = "<YOURORGNAME>"
$recipient = "YOUREMAILADDRESS>"
$name = "[ZOLDER] External message warning"
$html = '<p><span style="color: #ffff00; background-color: #000000;"><span style="background-color: #ff0000;"><strong>&nbsp;CAUTION</strong>&nbsp;<span style="background-color: #000000;">&nbsp;</span></span><span style="color: #ffffff;">This email originated from outside of the {0} organization&nbsp;</span></span></p>' -f $orgName 

New-TransportRule -Name $name -SetAuditSeverity "High" -ApplyHtmlDisclaimerFallbackAction "Wrap" -ApplyHtmlDisclaimerLocation "Prepend" -RuleErrorAction "Ignore" -StopRuleProcessing $False -Mode "Enforce" -ApplyHtmlDisclaimerText $html -FromScope "NotInOrganization" -SenderAddressLocation "Header" -Comments "Zolder created flow rule, there to warn users some mail is external"