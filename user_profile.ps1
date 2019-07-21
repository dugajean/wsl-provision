# Use this file to run your own startup commands

## Prompt Customization
<#
.SYNTAX
    <PrePrompt><CMDER DEFAULT>
    λ <PostPrompt> <repl input>
.EXAMPLE
    <PrePrompt>N:\Documents\src\cmder [master]
    λ <PostPrompt> |
#>

[ScriptBlock]$PrePrompt = {

}

# Replace the cmder prompt entirely with this.
# [ScriptBlock]$CmderPrompt = {}

[ScriptBlock]$PostPrompt = {

}

function phpunitFunc { & vendor/bin/phpunit }
function artisanFunc { & php artisan $args }
function dockFunc { & vendor/bin/dockr $args }
function wwwFunc { Set-Location C:\Users\Dugi\Code }
function gstFunc { & git status }
function gaFunc { & git add . }
function gcFunc { & git commit -m $args }
function gpFunc { & git push $args }
function wpCliFunc { & php C:\PHP\wp-cli.phar $args }
function dockrFunc { & php C:\PHP\dockr.phar $args }
function box2Func { & php C:\PHP\box.phar $args }
function backFunc { & cd .. }
function symfonyMakeMigrations { & php bin/console make:migration }
function symfonyRunMigrations { & php bin/console doctrine:migration:migrate }
function symfonyConsole { & php bin/console }

New-Alias -Name artisan -Value artisanFunc -Force -Option AllScope
New-Alias -Name www -Value wwwFunc -Force -Option AllScope
New-Alias -Name gst -Value gstFunc -Force -Option AllScope
New-Alias -Name ga -Value gaFunc -Force -Option AllScope
New-Alias -Name gc -Value gcFunc -Force -Option AllScope
New-Alias -Name gp -Value gpFunc -Force -Option AllScope
New-Alias -Name wp -Value wpCliFunc -Force -Option AllScope
New-Alias -Name dock -Value dockFunc -Force -Option AllScope
New-Alias -Name dockr -Value dockrFunc -Force -Option AllScope
New-Alias -Name box -Value box2Func -Force -Option AllScope
New-Alias -Name .. -Value backFunc -Force -Option AllScope
New-Alias -Name smigrations -Value symfonyMakeMigrations -Force -Option AllScope
New-Alias -Name smigrate -Value symfonyRunMigrations -Force -Option AllScope
New-Alias -Name scon -Value symfonyConsole -Force -Option AllScope
New-Alias which get-command

Set-PSReadlineKeyHandler -Key ctrl+w -Function DeleteCharOrExit
Set-PSReadlineKeyHandler -Key ctrl+l -Function ScrollDisplayDown