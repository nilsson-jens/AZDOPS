function Start-ADOPSPipeline {
    param (
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [string]$Project,

        [Parameter()]
        [string]$Organization,

        [Parameter()]
        [string]$Branch = 'main'
    )

    if (-not [string]::IsNullOrEmpty($Organization)) {
        $Org = GetADOPSHeader -Organization $Organization
    }
    else {
        $Org = GetADOPSHeader
    }

    $AllPipelinesURI = "https://dev.azure.com/$($Org['Organization'])/$Project/_apis/pipelines?api-version=7.1-preview.1"
    $AllPipelines = InvokeADOPSRestMethod -Method Get -Uri $AllPipelinesURI -Organization $Org['Organization']
    $PipelineID = ($AllPipelines.value | Where-Object -Property Name -EQ $Name).id

    if ([string]::IsNullOrEmpty($PipelineID)) {
        throw "No pipeline with name $Name found."
    }

    $URI = "https://dev.azure.com/$($Org['Organization'])/$Project/_apis/pipelines/$PipelineID/runs?api-version=7.1-preview.1"
    $Body = '{"stagesToSkip":[],"resources":{"repositories":{"self":{"refName":"refs/heads/' + $Branch + '"}}},"variables":{}}'
    
    $InvokeSplat = @{
        Method = 'Post' 
        Uri = $URI 
        Body = $Body
        Organization = $Org['Organization']
    }

    InvokeADOPSRestMethod @InvokeSplat
}