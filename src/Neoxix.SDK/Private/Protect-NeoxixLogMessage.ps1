function Protect-NeoxixLogMessage {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Message
    )

    $protectedMessage = $Message

    $privateKeyPattern = '(?is)-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----.*?' +
        '-----END (?:RSA |EC |OPENSSH )?PRIVATE KEY-----'
    $protectedMessage = [regex]::Replace(
        $protectedMessage,
        $privateKeyPattern,
        '[REDACTED PRIVATE KEY]'
    )

    $namedSecretPattern = '(?i)(\b(?:password|passwd|pwd|secret|token|api[_-]?key|' +
        'access[_-]?key|client[_-]?secret|connection\s*string)\b["'']?\s*[:=]\s*)' +
        '(?:"[^"]*"|''[^'']*''|[^\s,;]+)'
    $protectedMessage = [regex]::Replace(
        $protectedMessage,
        $namedSecretPattern,
        '${1}[REDACTED]'
    )

    $protectedMessage = [regex]::Replace(
        $protectedMessage,
        '(?i)\bBearer\s+[A-Za-z0-9._~+/-]+=*',
        'Bearer [REDACTED]'
    )

    $tokenPatterns = @(
        '\bgh[pousr]_[A-Za-z0-9]{20,}\b'
        '\bsk-[A-Za-z0-9_-]{16,}\b'
        '\bAKIA[A-Z0-9]{16}\b'
        '\beyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\b'
    )
    foreach ($tokenPattern in $tokenPatterns) {
        $protectedMessage = [regex]::Replace(
            $protectedMessage,
            $tokenPattern,
            '[REDACTED TOKEN]'
        )
    }

    # Encode control characters so each call always produces exactly one log line.
    $protectedMessage = $protectedMessage.Replace("`r`n", '\n')
    $protectedMessage = $protectedMessage.Replace("`r", '\r')
    $protectedMessage = $protectedMessage.Replace("`n", '\n')

    return $protectedMessage
}
