<#
    This script will allow you to import a recipe using JSON from a file
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

    #filepath to file containing JOSN
    [Parameter(Mandatory = $true)]
    [string]
    $filePath
)

#Gets the current directory to use a temp file
$currentDirectory = (Get-Location).Path

#Attempts to get the content of the file and convert it to JSON
try {
    
    $recipe = Get-Content $filePath -ErrorAction Stop
    $recipe = $recipe | ConvertFrom-Json -ErrorAction Stop

    #Technically a blank file IS valid JSON, this catches that occurrence
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


#region Validates Input

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

#endregion

#If the last character in the site is a '/', removes it for consistent processing
IF ( $mealieURL -match '/$' ){

    #Removes the last character from the string and assigns the new value to $mealieURL
    $mealieURL = $mealieURL.Remove(($mealieURL.Length - 1))

}

#Exports the object to a JSON file to set the encoding properly, sometimes it will add an A with a special character over it
$jsonText = ($recipe | ConvertTo-Json) -replace [char](194),""
$outPath = "$currentDirectory\tempRecipe.json"

#Needs to be UTF-8 NO BOM, which Out-File does not set by default, requiring use of the .Net class
$Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False
[System.IO.File]::WriteAllLines($outPath, $jsonText, $Utf8NoBomEncoding)

#region Builds the API Call

#Generates the API endpoint
$endpoint = "$mealieURL/api/recipes/create"

#Builds the headers for the API call
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "Bearer $token")
$headers.Add("Content-Type", "application/json")

#Assigns the recipe content to be the body
$body = Get-Content "$currentDirectory\tempRecipe.json"

#endregion

#Attempts to make the API call
try {

    $response = Invoke-WebRequest $endpoint -Method 'POST' -Headers $headers -Body $body

    #Should return the slug and code 201 if successfully imported, otherwise it was passed to the catch blocks
    if ( $response.StatusCode -match 201 ){
        Write-Host "Successfully imported: " -ForegroundColor Green -NoNewline
        Write-Host $recipe.Name

        #Removes the file after it has served its purpose
        Remove-Item "$currentDirectory\tempRecipe.json"
    }
    
}
catch {

    Write-Host "Mealie encountered an error could not import the recipe."
    Write-Host
    $error[0]
    Read-Host -Prompt "Press any key to exit..."
    EXIT
    
}

