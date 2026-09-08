# Requires: Connect-ExchangeOnline

$base = @(
    "ApplyRecord", "Create", "HardDelete", "MailItemsAccessed", "Move",
    "MoveToDeletedItems", "RecordDelete", "SoftDelete", "Update",
    "UpdateFolderPermissions", "UpdateInboxRules"
)

$admin    = $base + @("Copy", "FolderBind", "Send", "SendAs", "SendOnBehalf", "UpdateCalendarDelegation")
$delegate = $base + @("FolderBind", "SendAs", "SendOnBehalf")
$owner    = $base + @("MailboxLogin", "SearchQueryInitiated", "Send", "UpdateCalendarDelegation")

$failed = @()

Get-Mailbox -ResultSize Unlimited -RecipientTypeDetails UserMailbox,SharedMailbox | ForEach-Object {
    try {
        Set-Mailbox -Identity $_.ExchangeGuid.ToString() `
            -AuditEnabled $true `
            -AuditAdmin $admin `
            -AuditDelegate $delegate `
            -AuditOwner $owner `
            -ErrorAction Stop
    }
    catch {
        $failed += "$($_.TargetObject): $($_.Exception.Message)"
    }
}

if ($failed) {
    Write-Warning "Could not update $($failed.Count) mailbox(es):"
    $failed
}
else {
    Write-Host "Audit logging updated for all mailboxes."
}
