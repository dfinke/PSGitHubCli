function Invoke-ParseGHCli {
    param(
        $baseCMD = 'gh',
        [Parameter(ValueFromPipeline)]
        $target = 'CORE COMMANDS'
    )

    Process {    
        $found = $false
        switch (Invoke-Expression ($baseCMD + " --help")) {
            { $_ -eq $target } { $found = $true }
            { $found -and [string]::IsNullOrEmpty($_) } { $found = $false }
            Default { 
                if ($found) { $_ }
            }
        } 
    }
}

Write-Progress -Activity 'Parse GitHub CLI' -Status 'Start'
foreach ($subCommand in 'CORE COMMANDS', 'ADDITIONAL COMMANDS' | Invoke-ParseGHCli 'gh') {
    $parentCommand, $description = $subCommand.Split(':')
    
    $parentCommand = $parentCommand.Trim()
    $obj = [PSCustomObject][Ordered]@{
        Command     = $parentCommand.Trim()
        Description = $description.Trim()
        SubCommands = @()
    }

    Write-Progress -Activity 'Parse GitHub CLI' -Status "gh $parentCommand subcommands"    
    foreach ($detail in  'CORE COMMANDS' | Invoke-ParseGHCli "gh $parentCommand") {
        $cmd, $description = $detail.Split(':')
        $cmd = $cmd.Trim()
        $obj.SubCommands += [PSCustomObject][Ordered]@{
            ParentCommand = $parentCommand
            Command       = $cmd
            Description   = $description.Trim()
            Flags         = @()
        }
        
        Write-Progress -Activity 'Parse GitHub CLI' -Status "gh $parentCommand $cmd flags"    
        foreach ($flag in Invoke-ParseGHCli "gh $parentCommand $cmd" 'FLAGS') {
            $obj.SubCommands[-1].Flags += $flag
        }
    }

    $obj
}


# Start to think how to parse flags
<#
$data = @"
  -L, --limit int   Maximum number of gists to fetch (default 10)
      --public      Show only public gists
      --secret      Show only secret gists
"@ -split "`n"

foreach ($item in $data) {
    #$r=$item.trim().split('--')
    #$r.count     

    $item.trim().IndexOf('--')
}
#>