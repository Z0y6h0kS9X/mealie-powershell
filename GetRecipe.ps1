#Gets the recipe given the provided slug, returning details or false

  param ( 

      [Parameter()]
      [string]
      $mealieURL,

      [Parameter()]
      [string]
      $slug,

      [Parameter()]
      [string]
      $token

  )

    #If the last character in the site is a '/', removes it for consistent processing
    IF ( $mealieURL -match '/$' ){

        #Removes the last character from the string and assigns the new value to $mealieURL
        $mealieURL = $mealieURL.Remove(($mealieURL.Length - 1))

    }

    #Generates the API endpoint using the mealie site and the slug
    $endpoint = "$mealieURL/api/recipes/$slug"

    #Generates the headers to pass with the API call
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Authorization", "Bearer $token")

    #Attempts a connection using the endpoint, if successful it returns the JSON, if not, it returns FALSE
    try {

        #Initiates the API call
        $response = Invoke-WebRequest $endpoint -Method 'GET' -Headers $headers -ErrorAction Stop

        #returns a 200 Status Code if successful
        if ( $response.StatusCode -match 200 ){

            return $response | ConvertTo-Json
            
        }
        else{

            return $false

        }
        
    }
    catch {

        return $false

    }
