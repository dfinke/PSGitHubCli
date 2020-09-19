function Show-GitHubRepo {
    param(
        $url
    )

    gh repo view --web $url
}

function New-GitHubRepo {
    param(
        [Parameter(Mandatory)]
        $RepositoryName,
        [Switch]$Public,
        [Switch]$Force
    )


    $visibility="--private"
    if($Public) { $visibility="--public" }
 
    $confirm=$null
    if($Force) { $confirm="--confirm" }

    "gh repo create $($visibility) $RepositoryName $($confirm)" | iex
}