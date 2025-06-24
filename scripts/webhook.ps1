param (
    [Parameter(Mandatory=$true)]
    [string]$CurrentMax,
    
    [Parameter(Mandatory=$true)]
    [string]$PreviousMax,
    
    [Parameter(Mandatory=$true)]
    [string]$MaxDrop,
    
    [Parameter(Mandatory=$true)]
    [string]$CurrentMedian,
    
    [Parameter(Mandatory=$true)]
    [string]$PreviousMedian,
    
    [Parameter(Mandatory=$true)]
    [string]$MedianDrop,
    
    [Parameter(Mandatory=$true)]
    [string]$CurrentMin,
    
    [Parameter(Mandatory=$true)]
    [string]$PreviousMin,
    
    [Parameter(Mandatory=$true)]
    [string]$MinDrop,
    
    [Parameter(Mandatory=$true)]
    [string]$LargestDrop,
    
    [Parameter(Mandatory=$true)]
    [string]$LargestDropMetric,
    
    [Parameter(Mandatory=$true)]
    [string]$AlertReason,
    
    [Parameter(Mandatory=$true)]
    [string]$Threshold,
    
    [Parameter(Mandatory=$true)]
    [string]$Timestamp,

    [Parameter(Mandatory=$false)]
    [string]$CurrentTimestamp,

    [Parameter(Mandatory=$false)]
    [string]$PreviousTimestamp,

    [Parameter(Mandatory=$false)]
    [string]$TimeGap,

    #add the webhook url
    [Parameter(Mandatory=$false)]
    [string]$WebhookUrl = "http://www.google.com",
        
    [Parameter(Mandatory=$false)]
    [string]$ImageUrl = "https://www.jenkins.io/images/logos/fire/fire.png"
)

# Handle missing values
function EnsureValue([string]$value, [string]$default) {
    if ([string]::IsNullOrEmpty($value) -or $value -eq "<MISSING VALUE>") { 
        return $default 
    }
    return $value
}

try {
    # Ensure all values have defaults if missing
    $CurrentMax = EnsureValue $CurrentMax "204.0"
    $PreviousMax = EnsureValue $PreviousMax "204.0"
    $MaxDrop = EnsureValue $MaxDrop "0.0"
    
    $CurrentMedian = EnsureValue $CurrentMedian "204.0"
    $PreviousMedian = EnsureValue $PreviousMedian "204.0"
    $MedianDrop = EnsureValue $MedianDrop "0.0"
    
    $CurrentMin = EnsureValue $CurrentMin "202.0"
    $PreviousMin = EnsureValue $PreviousMin "204.0"
    $MinDrop = EnsureValue $MinDrop "0.0"
    
    $LargestDrop = EnsureValue $LargestDrop "0.0"
    $LargestDropMetric = EnsureValue $LargestDropMetric "None"
    $AlertReason = EnsureValue $AlertReason "No significant drops detected"
    $Threshold = EnsureValue $Threshold "10.0"
    
    if ([string]::IsNullOrEmpty($Timestamp) -or $Timestamp -eq "<MISSING VALUE>") {
        $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }
    
    # Convert string parameters to decimal
    [decimal]$CurrentMaxValue = [decimal]::Parse($CurrentMax)
    [decimal]$PreviousMaxValue = [decimal]::Parse($PreviousMax)
    [decimal]$MaxDropValue = [decimal]::Parse($MaxDrop)
    
    [decimal]$CurrentMedianValue = [decimal]::Parse($CurrentMedian)
    [decimal]$PreviousMedianValue = [decimal]::Parse($PreviousMedian)
    [decimal]$MedianDropValue = [decimal]::Parse($MedianDrop)
    
    [decimal]$CurrentMinValue = [decimal]::Parse($CurrentMin)
    [decimal]$PreviousMinValue = [decimal]::Parse($PreviousMin)
    [decimal]$MinDropValue = [decimal]::Parse($MinDrop)
    
    [decimal]$LargestDropValue = [decimal]::Parse($LargestDrop)
    [decimal]$ThresholdValue = [decimal]::Parse($Threshold)
    
    # Format the values for better readability
    $CurrentMaxFormatted = [math]::Round($CurrentMaxValue, 2)
    $PreviousMaxFormatted = [math]::Round($PreviousMaxValue, 2)
    $MaxDropFormatted = [math]::Round($MaxDropValue, 2)
    
    $CurrentMedianFormatted = [math]::Round($CurrentMedianValue, 2)
    $PreviousMedianFormatted = [math]::Round($PreviousMedianValue, 2)
    $MedianDropFormatted = [math]::Round($MedianDropValue, 2)
    
    $CurrentMinFormatted = [math]::Round($CurrentMinValue, 2)
    $PreviousMinFormatted = [math]::Round($PreviousMinValue, 2)
    $MinDropFormatted = [math]::Round($MinDropValue, 2)
    
    $LargestDropFormatted = [math]::Round($LargestDropValue, 2)
    $ThresholdFormatted = [math]::Round($ThresholdValue, 2)
    
    # Determine alert severity based on the largest drop percentage
    $Severity = "INFO"
    if ($LargestDropValue -ge 30) {
        $Severity = "CRITICAL"
    } elseif ($LargestDropValue -ge 20) {
        $Severity = "HIGH"
    } elseif ($LargestDropValue -ge 10) {
        $Severity = "MEDIUM"
    }
    
    # Create the alert message text
    $DetailsText = @"
- Maximum Executors:
  Current: $CurrentMaxFormatted (Previous: $PreviousMaxFormatted) - Drop: $MaxDropFormatted%
  
- Median Executors:
  Current: $CurrentMedianFormatted (Previous: $PreviousMedianFormatted) - Drop: $MedianDropFormatted%
  
- Minimum Executors:
  Current: $CurrentMinFormatted (Previous: $PreviousMinFormatted) - Drop: $MinDropFormatted%
  
Alert triggered by: $AlertReason
Threshold: $ThresholdFormatted%
Timestamp: $Timestamp

"@
    
    # Prepare Google Chat webhook payload with card format
    $WebhookPayload = @{
        cards = @(
            @{
                header = @{
                    title = "Jenkins Executor Alert - $Severity"
                    subtitle = "$LargestDropMetric dropped by $LargestDropFormatted%"
                    imageUrl = $ImageUrl
                }
                sections = @(
                    @{
                        widgets = @(
                            @{
                                textParagraph = @{
                                    text = $DetailsText
                                }
                            }
                        )
                    },
                    @{
                        widgets = @(
                            @{
                                textParagraph = @{
                                    text = $ActionsText
                                }
                            }
                        )
                    }
                )
            }
        )
    } | ConvertTo-Json -Depth 10
    
    # Log alert details to console
    Write-Output "JENKINS EXECUTOR POOL ALERT - $Severity"
    Write-Output "Alert triggered by: $AlertReason"
    Write-Output "Maximum: $CurrentMaxFormatted (was $PreviousMaxFormatted) - Drop: $MaxDropFormatted%"
    Write-Output "Median: $CurrentMedianFormatted (was $PreviousMedianFormatted) - Drop: $MedianDropFormatted%"
    Write-Output "Minimum: $CurrentMinFormatted (was $PreviousMinFormatted) - Drop: $MinDropFormatted%"
    
    # Send the webhook if URL is provided
    if ($WebhookUrl -notlike "*YOUR_SPACE_ID*") {
        Write-Verbose "Sending webhook notification to Google Chat..."
        
        try {
            $WebhookParams = @{
                Uri = $WebhookUrl
                Method = 'POST'
                Body = $WebhookPayload
                ContentType = 'application/json'
            }
            
            $WebhookResponse = Invoke-RestMethod @WebhookParams
            Write-Verbose "Webhook sent successfully to Google Chat."
            Write-Output "Alert with image successfully sent to Google Chat."
        }
        catch {
            $webhookError = "Failed to send webhook to Google Chat: $_"
            Write-Error $webhookError
            exit 1
        }
    }
    else {
        Write-Warning "No valid Google Chat webhook URL provided."
    }
    
    exit 0
}
catch {
    $errorMessage = "ERROR: $_`nException details: $($_.Exception.Message)"
    Write-Error $errorMessage
    exit 1
}
