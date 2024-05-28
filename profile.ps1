function Update-PSProfile {
    $Url = "https://raw.githubusercontent.com/stuart938503/Misc-PS-Public/main/profile.ps1"

    try {
        $ProfileResponse = Invoke-RestMethod $Url -ErrorAction Stop
        Set-Content -Path $profile -Value $ProfileResponse
        Write-Verbose "Updated PS profile" -Verbose
        . $profile
    }
    catch {
        Write-Verbose -Verbose "Was not able to update, try again next time"
        Write-Debug $_
    }
}

function Add-GraphPermissionsToManagedIdentity()
{
    param(
        [string]$TenantId,
        [string]$ManagedIdentityName,
        [string[]]$Permissions
    )

    # Connect to Microsoft Graph in the specified tenant
    Write-Host "Connecting to Microsoft Graph..."
    if((Get-MgContext).TenantId -ne $TenantId) {
        Connect-MgGraph -TenantId $TenantId -Scopes "Application.Read.All","AppRoleAssignment.ReadWrite.All,RoleManagement.ReadWrite.Directory"
    }

    # Get the Managed Identity and Graph service principals
    Write-Host "Getting service principals..."
    $GraphPrincipal = Get-MgServicePrincipal -Filter "AppId eq '00000003-0000-0000-c000-000000000000'"
    $ManagedIdentityPrincipal = Get-MgServicePrincipal -Filter "DisplayName eq '$ManagedIdentityName'"

    # Add the permissions to the Managed Identity
    foreach($Permission in $Permissions) {
        Write-Host "Adding permission $Permission..."
        $AppRole = $GraphPrincipal.AppRoles | Where-Object {$_.Value -eq $Permission -and $_.AllowedMemberTypes -contains "Application"}
        New-MgServicePrincipalAppRoleAssignment -PrincipalId $ManagedIdentityPrincipal.Id -ServicePrincipalId $ManagedIdentityPrincipal.Id -ResourceId $GraphPrincipal.Id -AppRoleId $AppRole.Id > $null
    }
    
}

function Get-PublicIp {
    ((Invoke-WebRequest -Uri "https://api.ipify.org?format=json").content | ConvertFrom-Json).ip
    ((Invoke-WebRequest -Uri "https://api64.ipify.org?format=json").content | ConvertFrom-Json).ip
}
