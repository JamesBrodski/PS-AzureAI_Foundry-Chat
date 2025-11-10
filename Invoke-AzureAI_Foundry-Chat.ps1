# Author: James Brodski

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Brodski AI"
$form.Size = New-Object System.Drawing.Size(500,400)
$form.StartPosition = "CenterScreen"

# Input label
$inputLabel = New-Object System.Windows.Forms.Label
$inputLabel.Text = "Ask anything"
$inputLabel.Location = New-Object System.Drawing.Point(10,20)
$inputLabel.Size = New-Object System.Drawing.Size(150,20)
$form.Controls.Add($inputLabel)

# Input textbox
$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Location = New-Object System.Drawing.Point(10,45)
$textBox.Size = New-Object System.Drawing.Size(460,25)
$form.Controls.Add($textBox)

# Submit button
$button = New-Object System.Windows.Forms.Button
$button.Text = "Submit"
$button.Location = New-Object System.Drawing.Point(10,80)
$button.Size = New-Object System.Drawing.Size(100,30)
$form.Controls.Add($button)

# Output textbox
$outputBox = New-Object System.Windows.Forms.TextBox
$outputBox.Location = New-Object System.Drawing.Point(10,120)
$outputBox.Size = New-Object System.Drawing.Size(460,220)
$outputBox.Multiline = $true
$outputBox.ScrollBars = "Vertical"
$outputBox.ReadOnly = $true
$form.Controls.Add($outputBox)

# When submit button is clicked
$button.Add_Click({
    $prompt = $textBox.Text.Trim()
    if ([string]::IsNullOrWhiteSpace($prompt)) {
        [System.Windows.Forms.MessageBox]::Show("Please enter something first!")
        return
    }

    try {
        $outputBox.Text = "Sending request..."

##################################################################################################
        # The Azure OpenAI endpoint and key
        $endpoint = "https://jbrod-mhsi0t6p-centralus.cognitiveservices.azure.com/openai/deployments/Brodski-Deployment/chat/completions?api-version=2025-01-01-preview"
        $apiKey = ''   # or set directly, e.g. "YOUR_KEY_HERE"

        # Set headers
        $headers = @{
            "Content-Type"  = "application/json"
            "Authorization" = "Bearer $apiKey"
        }

        # Create the request body as a hashtable
        $body = @{
            messages = @(
                @{
                    role    = 'system'
                    content = 'You are an AI assistant that helps people find information.'
                },
                @{
                    role    = "user"
                    content = "$prompt"
                }
            )
            max_completion_tokens = 16384
            model = "Brodski-Deployment"
        }

        # Convert hashtable to JSON string
        $jsonBody = $body | ConvertTo-Json

        # Send POST request
        $response = Invoke-RestMethod -Uri $endpoint -Method Post -Headers $headers -Body $jsonBody

################################################################################
        $outputBox.Text = $response.choices[0].message.content
    } catch {
        $outputBox.Text = "Error: " + $_.Exception.Message
    }
})

# Show the form
[void]$form.ShowDialog()