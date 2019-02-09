function AzureLogin {   
     
    Write-Output "Getting vsts endpoint..."
    $serviceNameInput = Get-VstsInput -Name ConnectedServiceNameSelector -Default 'ConnectedServiceName'
    $serviceName = Get-VstsInput -Name $serviceNameInput -Default (Get-VstsInput -Name DeploymentEnvironmentName)

    Write-Host $serviceName
    if (!$serviceName) {
        Get-VstsInput -Name $serviceNameInput -Require
    }

    $vstsEndpoint = Get-VstsEndpoint -Name $serviceName -Require

    $cred = New-Object System.Management.Automation.PSCredential(
        $vstsEndpoint.Auth.Parameters.ServicePrincipalId,
        (ConvertTo-SecureString $vstsEndpoint.Auth.Parameters.ServicePrincipalKey -AsPlainText -Force))

    Login-AzureRmAccount -Credential $cred -ServicePrincipal -TenantId $vstsEndpoint.Auth.Parameters.TenantId -SubscriptionId $vstsEndpoint.Data.SubscriptionId
    
}

function Get-KeyVaultSecret {
    param (
		[string]$SecretName,
		[string[]]$KeyVaultNames 
    )	   

    $secrets = New-Object System.Collections.ArrayList

    
    foreach ($kv in $KeyVaultNames) {
        $secret = Get-AzureKeyVaultSecret -VaultName $kv -Name $SecretName 
        if ($null -ne $secret) {
            $secrets.Add($secret) | Out-Null
        }
    }

    if ($secrets.Count -eq 0) {
        Write-Warning "Secret '$SecretName' not found in any key vault"	
    }
    elseif ($secrets.Count -gt 1) {
        Write-Error "Was found more than one secret with this name"
	}
	
	[string]$return = ($secrets[0]).SecretValueText

    
	return $return
}
