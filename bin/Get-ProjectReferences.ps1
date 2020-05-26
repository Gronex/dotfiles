[CmdletBinding()]
param (
    # Specifies a path to one or more locations.
    [Parameter(Mandatory=$true,
               Position=0,
               ParameterSetName="folder",
               ValueFromPipeline=$true,
               ValueFromPipelineByPropertyName=$true,
               HelpMessage="Path to one or more locations.")]
    [Alias("PSPath")]
    [ValidateNotNullOrEmpty()]
    [string[]]
    $folder
)

Function Get-ProjectReferences ($rootFolder)
{
    $projectFiles = Get-ChildItem $rootFolder -Filter *.csproj -Recurse
    $ns = @{ defaultNamespace = "http://schemas.microsoft.com/developer/msbuild/2003" }

    $projectFiles | ForEach-Object {
        $projectFile = $_ | Select-Object -ExpandProperty FullName
        $projectName = $_ | Select-Object -ExpandProperty BaseName
        $projectXml = [xml](Get-Content $projectFile)

        $projectReferences = $projectXml | Select-Xml '//defaultNamespace:ProjectReference/defaultNamespace:Name' -Namespace $ns | Select-Object -ExpandProperty Node | Select-Object -ExpandProperty "#text"

        $projectReferences | ForEach-Object {
            "[" + $projectName + "] -> [" + $_ + "]"
        }
    }
}

Get-ProjectReferences $folder