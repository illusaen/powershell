Function CreateDevContainer {
  param (
    [Parameter(Mandatory)]
    [ValidateScript({
        $script:Directory = Join-Path -Path (get-item $PSScriptRoot).parent -ChildPath $_
        if (Test-Path -Path $script:Directory) {
          throw "$script:Directory already exists."
        }
        else {
          $true
        }
      })]
    [string]$Name,

    [ValidateSet('python', 'node', 'rust')]
    [string]$Type = 'rust',

    [bool]$Code = $true
  )

  Function WriteDevcontainerJson {
    $DevContainerJSONObject = @{
      "name"             = "${Type}-${Name}"
      "build"            = @{
        "dockerfile" = "./Dockerfile"
        "context"    = "."
      }
      "features"         = @{
        "ghcr.io/devcontainers/features/common-utils:2" = @{
          "configureZshAsDefaultShell" = $true
        }
        "ghcr.io/devcontainers/features/git:1"          = @{
          "version" = "latest"
          "ppa"     = "false"
        }
      }
      "postStartCommand" = 'git config --global --add safe.directory ${containerWorkspaceFolder}'
    }
    
    if ($Type -eq "rust") {
      $DevContainerJSONObject.features += @{ "ghcr.io/devcontainers/features/rust:1" = "latest" }
      $DevContainerJSONObject += @{ "postCreateCommand" = "test ! -f Cargo.toml && (cargo init)" }
    }
    elseif ($Type -eq "python") {
      $DevContainerJSONObject.features += @{
        "ghcr.io/devcontainers/features/python:1" = "latest"
        "ghcr.io/devcontainers/features/node:1"   = "latest"
      }
    }
    
    $DevContainerJSONObject | ConvertTo-Json | Set-Content -Path (Join-Path -Path $DevcontainerDirectory -ChildPath "devcontainer.json")
  }
  
  Function WriteDockerfile {
    $Image = $Type
    if ($Type -eq "node") {
      $Image = "mcr.microsoft.com/devcontainers/javascript-node"
    }
  
    $DockerfileObjectHeader = @(
      "FROM ${Image}:latest",
      '',
      "RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \",
      "    && apt-get purge -y imagemagick imagemagick-6-common",
      ''
    )
  
    $Additional = switch ($Type) {
      "rust" {
        @(
          "RUN apt-get -y install jq build-essential openssl",
          '',
          'RUN rustup component add rustfmt',
          'RUN rustup component add clippy'
        )
      }
      "python" {
        @(
          'RUN python3 -m pip install --upgrade setuptools'
        )
      }
    }
  
  
    $DockerfileObjectHeader += $Additional + @(
      '',
      "RUN apt-get clean -y && rm -rf /tmp/scripts"
    )
  
    $DockerfileObjectHeader -join "`r`n" | Out-File -FilePath (Join-Path -Path $DevcontainerDirectory -ChildPath "Dockerfile") -Encoding UTF8
  }

  Write-Host "Building dev container at ${script:Directory}."

  mkdir $Directory
  $DevcontainerDirectory = Join-Path -Path $Directory -ChildPath ".devcontainer"
  mkdir $DevcontainerDirectory
  
  WriteDevcontainerJson
  WriteDockerfile
  
  devcontainer up --workspace-folder $Directory

  Write-Host "Dev container successfully built at ${script:Directory}."

  if ($Code) { code $Directory }
}

