    # Complete logs
    $adminLogging = "AddFolderPermissions, ApplyRecord, Copy, Create, FolderBind, HardDelete, ModifyFolderPermissions, Move, MoveToDeletedItems, RecordDelete, RemoveFolderPermissions, SendAs, SendOnBehalf, SoftDelete, Update, UpdateFolderPermissions, UpdateCalendarDelegation, UpdateInboxRules"

    # Non-Complete logs UpdateCalendarDelegation NOT INCLUDED, should be according docs possible, but errors ATM.
    $delegateLogging = "AddFolderPermissions, ApplyRecord, Create, FolderBind, HardDelete, ModifyFolderPermissions, Move, MoveToDeletedItems, RecordDelete, RemoveFolderPermissions, SendAs, SendOnBehalf, SoftDelete, Update, UpdateFolderPermissions, UpdateInboxRules"

    # Complete logs
    $ownerLogging =  "AddFolderPermissions, ApplyRecord, Create, HardDelete, MailboxLogin, ModifyFolderPermissions, Move, MoveToDeletedItems, RecordDelete, RemoveFolderPermissions, SoftDelete, Update, UpdateFolderPermissions, UpdateCalendarDelegation, UpdateInboxRules"

    # Set the logging for all mailboxes
    Get-Mailbox -ResultSize Unlimited | Set-Mailbox -AuditEnabled $true -AuditOwner $ownerLogging -AuditDelegate $delegateLogging -AuditAdmin $adminLogging