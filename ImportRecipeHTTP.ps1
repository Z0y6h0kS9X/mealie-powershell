
<#
    This script will allow you to import a recipe from one of the approved sources
    Approved sources: https://github.com/hhursev/recipe-scrapers
#>

[CmdletBinding()]
param (

    [Parameter(Mandatory = $true)]
    [string]
    $mealieURL,

    [Parameter(Mandatory = $true)]
    [string]
    $token,

    [Parameter(Mandatory = $true)]
    [string]
    $recipeLink

)

try {
    
    #Generates the API endpoint needed
    $endpoint = "$mealieURL/api/recipes/create-url"

    #Builds the headers
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Authorization", "Bearer $token")
    $headers.Add("Content-Type", "application/json")

    #Sets the body to be the url and converts it to a json object
    $body = New-Object psobject -Property (@{'url' = $url}) | ConvertTo-Json

    #Initiates the API call
    $response = Invoke-RestMethod $enpoint -Method 'POST' -Headers $headers -Body $body -ErrorAction Stop

    #Should return the slug if successfully imported, otherwise it was passed to the catch blocks

}
catch {

    Write-Host "Could not import the recipe, usually this is because the recipe has a slug that is already in use " -ForegroundColor Red
    
}

