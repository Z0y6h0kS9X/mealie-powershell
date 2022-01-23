[CmdletBinding()]
param (

    [Parameter()]
    [string]
    $user,

    [Parameter()]
    [string]
    $pass

)
    #IF the user AND pass are not specified, asks for both
    IF ( ( !$user ) -and ( !$pass ) ){

        Write-Host "Please enter the Username and Password to access Mealie" -ForegroundColor Yellow
        $user = Read-Host -Prompt "Username"
        $securePass = Read-Host -Prompt "Password" -AsSecureString

        $credentials = New-Object System.Management.Automation.PSCredential ($user, $securePass)    

    }
    elseif ( ( !$user ) -and ( ( $pass ) ) ) {

        #Keeps asking for username if it is not passed, otherwise it stores the input as the username
        do {
            Write-Host "Enter the username to access Mealie" -ForegroundColor Yellow
            $user = Read-Host
        } while ( [string]::IsNullOrEmpty( $user ) )

        $securePass = ConvertTo-SecureString -String $pass -AsPlainText -Force
        $credentials = New-Object System.Management.Automation.PSCredential ($user, $securePass)      
        
    }
    elseif ( ( $user ) -and ( ( !$pass ) ) ) {

        #Gets the credentials for the specified username
        Write-Host "Enter the password to connect to Mealie as $user" -ForegroundColor
        $securePass = Read-Host -Prompt "Password" -AsSecureString
        $credentials = New-Object System.Management.Automation.PSCredential ($user, $securePass)
        
    }
    #user/pass were specified, so it creates the object without need for input
    else{

        #Creates a secure credential object
        $securePass = ConvertTo-SecureString -String $pass -AsPlainText -Force
        $credentials = New-Object System.Management.Automation.PSCredential ($user, $securePass)

    }

    #Clears out the plain-text values for the credentials
    $user = ''
    $pass = ''

    #Returns the credential object
    return $credentials