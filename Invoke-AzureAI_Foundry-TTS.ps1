# Author: James Brodski
# Description: GUI that talks to Azure AI Foundry API to convert text to speech

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Used to play audio
Add-Type -AssemblyName PresentationCore

$outFile = "$env:TEMP\tts_output.wav"

##################################### Build the GUI #####################################
$form = New-Object System.Windows.Forms.Form
$form.Text = "Brodski AI"
$form.Size = New-Object System.Drawing.Size(500,350)
$form.StartPosition = "CenterScreen"

# Label
$label = New-Object System.Windows.Forms.Label
$label.Text = "Enter text to convert to speech:"
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(400,20)
$form.Controls.Add($label)

# Textbox
$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Location = New-Object System.Drawing.Point(10,45)
$textBox.Size = New-Object System.Drawing.Size(460,100)
$textBox.Multiline = $true
$form.Controls.Add($textBox)

# Submit button
$submitBtn = New-Object System.Windows.Forms.Button
$submitBtn.Text = "Submit"
$submitBtn.Location = New-Object System.Drawing.Point(10,160)
$submitBtn.Size = New-Object System.Drawing.Size(100,30)
$form.Controls.Add($submitBtn)

# Play button
$playBtn = New-Object System.Windows.Forms.Button
$playBtn.Text = "Play"
$playBtn.Location = New-Object System.Drawing.Point(120,160)
$playBtn.Size = New-Object System.Drawing.Size(100,30)
$playBtn.Enabled = $false
$form.Controls.Add($playBtn)

# Output label
$outputLabel = New-Object System.Windows.Forms.Label
$outputLabel.Location = New-Object System.Drawing.Point(10,210)
$outputLabel.Size = New-Object System.Drawing.Size(460,80)
$outputLabel.Text = ""
$form.Controls.Add($outputLabel)

##################################### Functions #####################################

function Invoke-TTS($text) {

    $endpoint = "https://jbrod-mhtkw7u0-westus3.cognitiveservices.azure.com/openai/deployments/Brodski-tts/audio/speech?api-version=2025-03-01-preview"
    $apiKey = ''

    # Headers
    $headers = @{
        "Content-Type"  = "application/json"
        "Authorization" = "Bearer $apiKey"
    }

    # Request body
    $body = @{
        model = "Brodski-tts"
        input = "$text"
        voice = "alloy"
    }

    # Convert hashtable to string
    $jsonBody = $body | ConvertTo-Json

    # See if this code throws errors,
    try {

        # Send request and save the audio
        Invoke-WebRequest -Uri $endpoint -Method Post -Headers $headers -Body $jsonBody -OutFile $outFile

        return $true

    # If a problem happens,
    } catch {

        return $false
    }
}

function Play-Audio {

    $MediaPlayer = New-Object System.Windows.Media.MediaPlayer
    $MediaPlayer.Open($outFile)
    $MediaPlayer.Play()
}

##################################### Event Handlers #####################################

$submitBtn.Add_Click({

    # Grab the text from textbox and store into variable
    $text = $textBox.Text.Trim()

    # If there is no text, tell the user to put some text
    if ([string]::IsNullOrWhiteSpace($text)) {
        [System.Windows.Forms.MessageBox]::Show("Please enter text before submitting.")
        return
    }

    $outputLabel.Text = "Sending request to Azure TTS..."
    $form.Refresh()

    # If the submit button is clicked and file is downloaded,
    if (Invoke-TTS $text) {

        $outputLabel.Text = "Audio downloaded successfully! Click 'Play' to listen."
        $playBtn.Enabled = $true

    # If the submit button was clicked and file failed to download,
    } else {

        $outputLabel.Text = "Request failed."
    }
})

# When user clicks on the play button
$playBtn.Add_Click({

    # If the audio file plays with no problem,
    if (Test-Path $outFile) {

        Play-Audio
        $outputLabel.Text = "Playing audio now..."

    # If the audio file has problem playing,
    } else {

        # Assume the audio file was not found
        [System.Windows.Forms.MessageBox]::Show("Audio file not found.")
    }
})

##################################### Show the Form #####################################
[void]$form.ShowDialog()