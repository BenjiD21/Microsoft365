## Finalize Move Requests for a specific Group of users

#############################################################
# You will need a csv file of all users whose Move-Requests #
# should be approved. Delimiter should be ";". File should  #
# contain the MailNickName for each user.                   #
# ###########################################################

## WARNING: This script will complete all Move-Requests that have the status 'Investigate'

## Step 1: Get the file path of the csv file and replace %FILEPATH%
## Step 2: Get the name of the MailNickName column in your csv file and replace 'Benutzername'

## Connect to Exchange Online
Connect-ExchangeOnline

## TODO: Get the path to the csv file of the users
$Path = "%FILEPATH%"

## Import the CSV file
$dataArray = Import-Csv -Path $Path -Delimiter ";"

## Migrate the mailbox of each user within the list
$dataArray | ForEach-Object {

    ## Get the Move-Request for the user
    ## TODO: Switch out "Benutzername" with the name of the MailNickName column in your csv file
    $MoveRequest = Get-MoveRequest -Identity $_.Benutzername 

    ## Check if the MoveRequest needs approval
    $MoveRequestStatus = $MoveRequest | Get-MoveRequestStatistics | Select DataConsistencyScore

    ## Get ther Username
    $Username = $MoveRequest.Alias

    ## If it needs approval, approve first
    if($MoveRequestStatus.DataConsistencyScore.Value -eq "Investigate") {
        
        ## Set the ApprovalTime to 5 minutes ago so it approves directly
        $MoveRequest | Set-MoveRequest -SkippedItemApprovalTime ([DateTime]::UtcNow.AddMinutes(-5))

        Write-Output "Move-Request for $Username was approved"

    }

    ## Finalize the move request
    $MoveRequest | Set-MoveRequest -CompleteAfter 1

    Write-Output "Move-Request for $Username was finalized"

    ## Mark the end of a user migration
    Write-Output "---------------------------------------"

    }

## Disconnect from Exchange Online
Disconnect-ExchangeOnline -Confirm:true
