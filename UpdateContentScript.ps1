# This script provides instructions for manual DOM inspection and updates content_script.js

# Function to check if a file exists
function Test-FileExists($path) {
    if (Test-Path $path) {
        return $true
    } else {
        Write-Host "Error: File not found: $path" -ForegroundColor Red
        return $false
    }
}

# Instructions for manual inspection
$jsCode = @"
function inspectDOM() {
  const selectors = [
    '.chat-container',
    '.chat-message',
    '[data-testid="chat-message"]',
    '[data-testid="conversation-message"]',
    '.conversation-message',
    '.message-container'
  ];

  selectors.forEach(selector => {
    const elements = document.querySelectorAll(selector);
    console.log(`Selector "${selector}": ${elements.length} elements found`);
    if (elements.length > 0) {
      console.log('First element:', elements[0].outerHTML);
    }
  });

  // Log the structure of a potential chat message
  const potentialMessage = document.querySelector('.message-container') || document.querySelector('.chat-message');
  if (potentialMessage) {
    console.log('Potential chat message structure:');
    console.log(potentialMessage.outerHTML);
  } else {
    console.log('No potential chat message found. The structure might be different.');
  }
}

inspectDOM();
"@

Write-Host @"
Please follow these steps to inspect the DOM:
1. Open the Cody chat interface in Chrome (https://sourcegraph.com/cody/chat)
2. Right-click and select 'Inspect' to open Developer Tools
3. In the Console tab, paste and run the following JavaScript:

$jsCode

4. Review the console output and identify the correct selector for chat messages
5. Enter the correct selector below:
"@ -ForegroundColor Cyan

# Prompt for the correct selector
$chatMessageSelector = Read-Host "Enter the correct chat message selector"

# Update the content_script.js file
$contentScriptPath = Join-Path $PSScriptRoot "content_script.js"

if (Test-FileExists $contentScriptPath) {
    $contentScript = Get-Content $contentScriptPath -Raw
    $updatedScript = $contentScript -replace '\.correct-chat-message-selector', $chatMessageSelector

    # Also update the role and content selectors based on the structure
    $updatedScript = $updatedScript -replace '\.user-message-class', '.user-message'
    $updatedScript = $updatedScript -replace '\.message-content-selector', '.message-content'

    Set-Content $contentScriptPath $updatedScript
    Write-Host "content_script.js has been updated with the new selector: $chatMessageSelector" -ForegroundColor Green
} else {
    Write-Host "Please ensure content_script.js is in the same directory as this script." -ForegroundColor Yellow
}

Write-Host @"

Next steps:
1. Review and manually adjust the content_script.js file if needed.
2. In Chrome, go to chrome://extensions/
3. Enable 'Developer mode' if not already enabled
4. Click 'Load unpacked' and select your extension directory
5. If the extension was already loaded, click the refresh icon to reload it
6. Test the extension on the Cody chat page

If you encounter any issues, please check the console in Developer Tools for error messages.
"@ -ForegroundColor Cyan

# Prompt user to open content_script.js for manual review
$openFile = Read-Host "Do you want to open content_script.js for manual review? (Y/N)"
if ($openFile -eq 'Y' -or $openFile -eq 'y') {
    if (Test-FileExists $contentScriptPath) {
        Start-Process notepad $contentScriptPath
    }
}
