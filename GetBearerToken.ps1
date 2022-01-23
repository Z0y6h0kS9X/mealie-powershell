#FUNCTION GetBearerToken( [System.Management.Automation.PSCredential] $cred, [string] $mealieURL ){
    [CmdletBinding()]
    param (
        #Need to pass in a PSCredential Object
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $cred,

        #Need to pass in the URL of your mealie instance to connect to, example: http(s)://mealie.XXXX.com/
        [Parameter(Mandatory = $true)]
        [string]
        $mealieURL
    )

    #If the last character in the site is a '/', removes it for consistent processing
    IF ( $mealieURL -match '/$' ){

        #Removes the last character from the string and assigns the new value to $mealieURL
        $mealieURL = $mealieURL.Remove(($mealieURL.Length - 1))

    }

    #Generates the API endpoint address for credentials passed - should resolve to
    # http(s)://mealie.XXXX.com/api/user/token - subdomain example
    # http://192.168.1.X/mealie/api/user/token - subfolder example
    $token_endpoint = '/api/auth/token'
    $tokenAddress = $mealieURL + $token_endpoint

    #Attempts to access the endpoint and get the token
    try {

        #Builds the headers for the API call
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Content-Type", "application/x-www-form-urlencoded")

        #Converts the strings to URL-Encoded format (necessary for special characters) and compiles it in the body
        $body = "username=$( [uri]::EscapeDataString($cred.UserName) )&password=$( [uri]::EscapeDataString($cred.GetNetworkCredential().Password) )"

        #Sends the API call to the site
        $response = Invoke-RestMethod $tokenAddress -Method 'POST' -Headers $headers -Body $body -ErrorAction Stop

        #Stores the token from the response in the $token variable
        $token = $response.access_token;
        
    }
    catch [ System.Net.WebException ] {

        #Assigns last error message to new variable in case other errors overwrite
        $exception = $error[0]

        switch ($exception.ErrorDetails.Message) {
            #credentials in the credential object are invalid
            '{"detail":"Unauthorized"}' { 
                Write-Host "The credentials provided were not valid" -ForegroundColor Yellow
                break;
             }
             #Server was unable to find the endpoint
             '{"detail":"Not Found"}' {
                 Write-Host "The server could not find the resource $token_endpoint" -ForegroundColor Yellow
                 break;
             }
             #Usually caused by an incorrect request (GET rather than POST, etc.)
             "The remote server returned an error: (422) Unprocessable Entity."{
                 Write-Host "Invalid input provided to server" -ForegroundColor Yellow
                 break;
             }
            Default {
                Write-Host "Other WebException occurred" -ForegroundColor Yellow
                Write-Host $exception;
                break;
            }
        }
    }
    #If a non-System.Net.WebException occurs, catches it here
    catch{

        Write-Host "Could not get token"
        #Assigns last error message to new variable in case other errors overwrite
        $error[0]
    }

    #returns the token object to the caller
    return $token