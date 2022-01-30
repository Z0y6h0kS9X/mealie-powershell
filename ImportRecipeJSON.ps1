<#
    This script will allow you to import a recipe using JSON from a file or JSON string
#>

[CmdletBinding()]
param (
    
    #URL of your mealie instance
    [Parameter(Mandatory = $true)]
    [string]
    $mealieURL, 
    
    #Bearer token to access mealie
    [Parameter(Mandatory = $true)]
    [string]
    $token,

    #Either a filepath to a file containing JSON, or a string of JSON
    [Parameter(Mandatory = $true)]
    $source

)

$currentDirectory = ( Get-Location )

#Starts by seeing if Test-Path resolves true, if so it assumes that it is a file
if ( Test-Path $source ){

    Write-Host "Attempting to import recipe from file."

    try {
        
        $recipe = Get-Content $source | ConvertFrom-Json -ErrorAction Stop
        #technically a blank file IS valid JSON, this catches that occurrence
        if ( $recipe.Length -match 0 ){
            Write-Host "The JSON file is blank!" -ForegroundColor Red
            Read-Host -Prompt "Press any key to exit..."
        EXIT
        }

    }
    catch {

        Write-Host "Unable to parse the file: $source, with the following error" -ForegroundColor Red
        Write-Host
        $error[0]
        Read-Host -Prompt "Press any key to exit..."
        EXIT
        
    }        

}
#If the Test-Path returns false, assumes it is a string
else {

    Write-Host "Attempting to import recipe from JSON string"

    try {

        $recipe = $source | ConvertFrom-Json -ErrorAction Stop
        
    }
    catch {

        Write-Host "Unable to convert the string to JSON, see below" -ForegroundColor Red
        Write-Host
        $error[0]
        Read-Host -Prompt "Press any key to exit..."
        EXIT
        
    }
    
    
}

#Tests to make sure the required fields are passed
<#
Required Fields:
Field - Type - Can be blank
name - String - No
recipe_ingredients - Array - Yes
recipe_instructions - Array - Yes
slug - String - No
#>

#Checks to confirm that the Recipe Name has a value
if ( [string]::IsNullOrEmpty($recipe.name) ){

    Write-Host "Recipe name cannot be blank!" -ForegroundColor Red
    Read-Host -Prompt "Press any key to exit..."
    EXIT

}

if ( $recipe.recipe_ingredient.GetType().BaseType.name -notmatch "Array" ){

    Write-Host "Recipe Ingredients are not in an array!" -ForegroundColor Red
    Read-Host -Prompt "Press any key to exit..."
    EXIT

}

if ( $recipe.recipe_instructions.GetType().BaseType.name -notmatch "Array" ){

    Write-Host "Recipe Instructions are not in an array!" -ForegroundColor Red
    Read-Host -Prompt "Press any key to exit..."
    EXIT

}

#Confirms that the Recipe slug has a value
if ( [string]::IsNullOrEmpty($recipe.slug) ){

    Write-Host "Recipe slug cannot be blank!" -ForegroundColor Red
    Read-Host -Prompt "Press any key to exit..."
    EXIT

}

#If the last character in the site is a '/', removes it for consistent processing
IF ( $mealieURL -match '/$' ){

    #Removes the last character from the string and assigns the new value to $mealieURL
    $mealieURL = $mealieURL.Remove(($mealieURL.Length - 1))

}

#Exports the object to a JSON file to set the encoding properly and imports it as a text string
$recipe | ConvertTo-Json | Out-File "$currentDirectory\temp.json"
$recipeBody = Get-Content "$currentDirectory\temp.json"

#Generates the API endpoint
$endpoint = "$mealieURL/api/recipes/create"

#Builds the headers for the API call
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "Bearer $token")
$headers.Add("Content-Type", "application/json")

#Assigns the recipe content to be the body
$body = $recipeBody

#Attempts to make the API call
try {

    $response = Invoke-WebRequest $endpoint -Method 'POST' -Headers $headers -Body $body

    #Should return the slug and code 201 if successfully imported, otherwise it was passed to the catch blocks
    if ( $response.StatusCode -match 201 ){
        Write-Host "Successfully imported: " -ForegroundColor Green -NoNewline
        Write-Host $recipe.Name

        #Removes the file after it has served ts purpose
        Remove-Item "$currentDirectory\temp.json"
    }
    
}
catch {

    Write-Host "Mealie encountered an error could not import the recipe."
    Write-Host
    $error[0]
    Read-Host -Prompt "Press any key to exit..."
    EXIT
    
}

