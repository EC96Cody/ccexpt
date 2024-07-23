document.addEventListener('DOMContentLoaded', () => {
  const exportButton = document.getElementById('export');
  const outputArea = document.getElementById('output');
  const downloadButton = document.getElementById('download');

  exportButton.addEventListener('click', () => {
    chrome.tabs.query({ active: true, currentWindow: true }, (tabs) => {
      chrome.tabs.sendMessage(tabs[0].id, { action: 'extractChats' }, (response) => {
        if (response && response.chats) {
          outputArea.textContent = response.markdown;
          downloadButton.style.display = 'block';
        } else {
          outputArea.textContent = 'No chats found or error occurred.';
        }
      });
    });
  });

  downloadButton.addEventListener('click', () => {
    chrome.tabs.query({ active: true, currentWindow: true }, (tabs) => {
      chrome.tabs.sendMessage(tabs[0].id, { action: 'downloadChats' }, (response) => {
        if (response && response.success) {
          outputArea.textContent += '\n\nFiles downloaded successfully!';
        } else {
          outputArea.textContent += '\n\nError downloading files.';
        }
      });
    });
  });
});

