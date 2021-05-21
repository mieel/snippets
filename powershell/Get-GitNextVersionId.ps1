Function Get-CurrentGitBranch {
    Write-Output (git branch --show-current)
}
Function Test-CurrentGitTag {
    <#
        .EXAMPLE
            Test-GitTag -Tag 0.1.108
    #>
    param(
        $Tag
    )
    $Result = git tag | Where-Object {$_ -eq $tag }
    If ($Result) {
        Return $true
    } Else {
        Return $false
    }
}
Function Get-GitNextVersionId {
    <#
        .SYNOPSIS
            Increments the revision/build number when the Tag already exists.
            It's adapted to work with Universal Package which strictly expects a 3 part SemVer.
            1.2.3.0 would be 1.2.3
            1.2.3.1 would be 1.2.3-r2
            1.2.3.2 would be 1.2.3-r3
            etc..
        .EXAMPLE
            $Splat = @{
                TagPrefix = 'Components.Service'
                MajorMinorPatch = '0.1.0'
                PrereleaseTag = ''
                CommitsSince = '12'
                SourceBranch = 'master'
            }
            $VersionId = Get-AzDoNextVersionId @Splat
            Write-Host $VersionId
    #>
    param(
        [string ]$TagPrefix
        ,
        [Parameter(Mandatory=$True)]
        [string] $MajorMinorPatch
        ,
        [string] $PrereleaseTag = ''
        ,
        [string] $SourceBranch
        ,
        [string] $RevisionPrefix = 'r'
        ,
        [switch] $UseRevisionInVersionId
        ,
        [switch] $UsePsRepoScheme
    )
    # We cant use FullSemVer because + signs are not allowed
    If ($UsePsRepoScheme -and $PreReleaseTag -ne '') {
        $PrereleaseTag = $PrereleaseTag.Replace("-","").Replace(".","")       # psrepo does not allow sings in prerelease label
    }
    $VersionId = $MajorMinorPatch

    If (-not $SourceBranch) {
        $SourceBranch = Get-CurrentGitBranch
    }
    # Add prereleaselabel when not in main/master
    If ( $SourceBranch -notlike '*master' -or  $SourceBranch -notlike '*main' -and $PreReleaseTag -ne '') {
        $VersionId += "-$PreReleaseTag"
    }
    $NewTag = $VersionId
    If ($TagPrefix) {
        $NewTag = "$TagPrefix-$VersionId"
    }
    Write-Host "Testing Tag: $NewTag"
    $Exists = Test-CurrentGitTag -Tag $NewTag
    Write-Host "Going to use $NewTag"
    If ($Exists -eq $True) {
        Write-Host "$NewTag Exists, incrementing revision..."
        $i = 1
        Do {
            If ($UseRevisionInVersionId) {
                $Revision = $i
                Write-Host "Add build number: $Revision"
                $VersionId = "$MajorMinorPatch.$Revision"                    # 1.1.1.1
                $NewTag = $VersionId
                If ($PreReleaseTag -ne '') {
                    $NewTag += "-$PreReleaseTag"
                }
            } Else {
                $Revision = $i + 1                                             # Start with 2, because only want to start showing -r when >= r2
                $VersionId  = "$MajorMinorPatch-$RevisionPrefix$Revision"
                $NewTag = $VersionId
            }
            If ($TagPrefix) {
                $NewTag = "$TagPrefix-$NewTag"
            }
            Write-Host "new: $NewTag"
            $Exists = Test-CurrentGitTag -Tag $NewTag
            $i++
        } While ($Exists -eq $True)
    }
    Write-Output $VersionId
}
