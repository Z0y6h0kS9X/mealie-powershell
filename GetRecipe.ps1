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
    #Generates the API endpoint using the mealie site and the slug
    $endpoint = "$mealieURL/api/recipes/$slug"

    #Generates the headers to pass with the API call
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Authorization", "Bearer $token")

    #Attempts a connection using the endpoint, if successful it returns the JSON, if not, it returns FALSE
    try {

        #Initiates the API call
        $response = Invoke-RestMethod $endpoint -Method 'GET' -Headers $headers -ErrorAction Stop
        return $response | ConvertTo-Json
        
    }
    catch {

        return $false

    }
