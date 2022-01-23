[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]
    $mealieURL,

    [Parameter(Mandatory = $true)]
    [string]
    $token
)
    #If the last character in the site is a '/', removes it
    IF ( $mealieURL -match '/$' ){

        #Removes the last character from the string and assigns the new value to $mealieURL
        $mealieURL = $mealieURL.Remove(($mealieURL.Length - 1))

    }

    #Builds the API Endpoint address for getting details about the user token was assigned to
    # http(s)://mealie.XXXX.com/api/users/self - subdomain example
    # http://192.168.1.X/mealie/api/users/self - subfolder example
    $token_endpoint = '/api/users/self'
    $tokenAddress = $mealieURL + $token_endpoint

    try {

        #Builds the headers for the API call
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Authorization", "Bearer $token")

        #Makes the API call, if it returns successful, we know it was a valid token
        Invoke-RestMethod $tokenAddress -Method 'GET' -Headers $headers -ErrorAction Stop | Out-Null
        
        $validToken = $true

    }
    catch {

        $validToken = $false

    }

    return $validToken

