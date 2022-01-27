
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

#If the last character in the site is a '/', removes it for consistent processing
IF ( $mealieURL -match '/$' ){

    #Removes the last character from the string and assigns the new value to $mealieURL
    $mealieURL = $mealieURL.Remove(($mealieURL.Length - 1))

}

#Sets up a boolean statement to track if the test-parse worked properly for the actual creation later.
$parseSuccess = $false

#Builds the headers
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "Bearer $token")
$headers.Add("Content-Type", "application/json")

#Sets the body to be the url and converts it to a json object
$body = New-Object psobject -Property (@{'url' = $recipeLink}) | ConvertTo-Json

#Test Scrapes to see if it can get the data from the provided url
try {

    Write-Host "Verifying we can scrape the site provided..."

    #Generates the API endpoint needed
    $endpoint = "$mealieURL/api/recipes/test-scrape-url"

    #Initiates the API call
    $response = Invoke-WebRequest $endpoint -Method 'POST' -Headers $headers -Body $body -ErrorAction Stop

    #Should return code 200 if successfully imported, otherwise it was passed to the catch blocks
    if ( $response.StatusCode -match 200 ){

        #Means that the backend was functional, just unable to scrape the data
        if ( $response.Content -match "`"recipe_scrapers was unable to scrape this URL`"" ){
            Write-Host "System is working, but this site was not able to be parsed." -ForegroundColor Yellow
        }
        else {
        #Means everything is good to go
        $recipeName = ( $response.Content | ConvertFrom-Json ).Name
        Write-Host "Successfully parsed: " -ForegroundColor Green -NoNewline
        Write-Host $recipeName

        #Sets the parseSuccess to be true, allowing the actual call to happen
        $parseSuccess = $true

        }
    }
    
}
catch {
    
    Write-Host "There was an issue calling the Mealie API with your request." -ForegroundColor Red
    Write-Host "Check that everything is configured properly and you have a valid bearer token." -ForegroundColor Red

}

#Makes the actual API call, if parseSuccess is true
if ($parseSuccess){

    Write-Host "Attempting to import the recipe..."

    try {

        #Generates the API endpoint
        $endpoint = "$mealieURL/api/recipes/create-url"

        #Initiates the API call
        $response = Invoke-WebRequest $endpoint -Method 'POST' -Headers $headers -Body $body -ErrorAction Stop

        #Should return the slug and code 201 if successfully imported, otherwise it was passed to the catch blocks
        if ( $response.StatusCode -match 201 ){
            Write-Host "Successfully imported: " -ForegroundColor Green -NoNewline
            Write-Host $recipeName
        }
    }
    catch {

        #attempts to ascertain the slug from the url provided

        [uri]$url = $mealieURL
        $slug = $url.Segments[$url.Segments.Length - 1]

        Write-Host "Could not import the recipe, usually this is because the recipe has a slug that is already in use." -ForegroundColor Red
        Write-Host "Auto-Enumerated slug: $slug"
        
    }

}

