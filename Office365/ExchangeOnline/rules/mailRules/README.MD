# Forwarding Rules

This repository contains tools published by [Zolder](https://zolder.io). The tools can be used to secure a Microsoft Cloud environment, for example Office 365 or Azure. The main goal is to share useful tools that we built to detect threats or harden the configuration of a Microsoft tenant.

The blog related to these scripts can be found here: [https://zolder.io/2020/05/13/office-365-exchange-rules/](https://zolder.io/2020/05/13/office-365-exchange-rules/)

# Different Rules

The rules in this folder look for different types of inbox rules or other ways of exfiltrating emails. In order to minimize false posititves we try to determine where the email is going. If the domain is not in the whitelist our rule triggers. **be sure to update the whitelist**

```yml
let TimeFrame = 1d;
let domains = dynamic(["zolder.io" "rwxsecurity.nl"]);
OfficeActivity
| where TimeGenerated >= ago(TimeFrame) 
| where Operation == "Set-InboxRule"
| extend details = parse_json(Parameters)
| extend ruletype = tostring(details[0].Name) 
| where ruletype in ( "ForwardTo" , "ForwardAsAttachmentTo", "RedirectTo")
| extend forwardaddr = tostring(details[0].Value) 
| extend forwarddomain = tostring(split(forwardaddr, "@")[1])
| where isempty(forwarddomain) == false and forwarddomain !in (domains)
```

1. Create an array of valid forward domains
2. Parse the forward address
3. Only trigger if the forward domain is not in our whitelist

Types of methods the rules look at:

- [New-InboxRule](New-InboxRule.yml) with ruletype being one of the following:
    - ForwardTo
    - ForwardAsAttachmentTo
    - RedirectTo
- [Set-InboxRule](Set-InboxRule.yml) with ruletype being one of the following:
    - ForwardTo
    - ForwardAsAttachmentTo
    - RedirectTo
- [Set-Mailbox](Set-Mailbox.yml) with type: “ForwardingSmtpAddress”
- [New-TransportRule](New-TransportRule.yml)  (This operations require Admin permissions!)
- [Set-TransportRule](Set-TransportRule.yml)  (This operations require Admin permissions!)


# Caveat
The EWS API has the “UpdateInboxRules” operation. Logging for this operation lacks information, there doesnt seem to be a way to have propper logs for this. A way to solve this would be to log into our Exchange instance and query them with the “Get-InboxRule” cmdlet. Unfortunately it only returns the name of the rule but often lacks any additional information. The only way to get those is through the EWS API and for each user search through their inbox to find the rules. There is a usefull script in the [O365-InvestigationTooling Github repo](https://github.com/gscales/O365-InvestigationTooling/blob/master/Get-AllTenantRulesAndForms.ps1) that dumps all rules and forms.
