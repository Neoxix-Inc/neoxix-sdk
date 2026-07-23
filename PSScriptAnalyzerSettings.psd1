@{
    IncludeDefaultRules = $true
    Severity            = @('Error', 'Warning', 'Information')
    Rules               = @{
        # These rules supplement the complete recommended ruleset. No default
        # rule is excluded. Explicit enablement documents the mission-specific
        # security and maintainability gates.
        PSAvoidGlobalVars                              = @{ Enable = $true }
        PSAvoidUsingAllowUnencryptedAuthentication     = @{ Enable = $true }
        PSAvoidUsingBrokenHashAlgorithms               = @{ Enable = $true }
        PSAvoidUsingCmdletAliases                      = @{ Enable = $true }
        PSAvoidUsingConvertToSecureStringWithPlainText = @{ Enable = $true }
        PSAvoidUsingInvokeExpression                   = @{ Enable = $true }
        PSAvoidUsingPlainTextForPassword               = @{ Enable = $true }
        PSAvoidUsingWriteHost                          = @{ Enable = $true }
        PSReviewUnusedParameter                        = @{ Enable = $true }
        PSUseApprovedVerbs                             = @{ Enable = $true }
        PSUseDeclaredVarsMoreThanAssignments           = @{ Enable = $true }
        PSUseShouldProcessForStateChangingFunctions    = @{ Enable = $true }
    }
}
