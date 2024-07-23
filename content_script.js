function extractCodyChats() {
  let chats = [];
  const chatContainer = document.querySelector('.NewCodyChatPage-module__chat-container');
  
  if (!chatContainer) {
    console.error('Chat container not found');
    return chats;
  }

  const chatMessages = chatContainer.querySelectorAll('[data-testid="message"]');
  
  chatMessages.forEach((message, index) => {
    const roleElement = message.querySelector('img[alt^="Avatar for"]');
    const role = roleElement && roleElement.alt.includes('cody') ? 'Cody' : 'User';
    
    const contentElement = message.querySelector('[data-lexical-editor="true"]');
    
    if (contentElement) {
      const content = contentElement.innerText.trim();
      chats.push({ role, content, timestamp: new Date().toISOString(), index });
    }
  });

  return chats;
}

function formatChatsAsMarkdown(chats) {
  return chats.map(chat => `## ${chat.role} (Message ${chat.index + 1})

${chat.content}

*Timestamp: ${chat.timestamp}*

---`).join('\n\n');
}

function downloadAsFile(content, filename, contentType) {
  const a = document.createElement('a');
  const file = new Blob([content], {type: contentType});
  a.href = URL.createObjectURL(file);
  a.download = filename;
  a.click();
  URL.revokeObjectURL(a.href);
}

chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
  if (request.action === 'extractChats') {
    const chats = extractCodyChats();
    sendResponse({
      chats: chats,
      markdown: formatChatsAsMarkdown(chats),
      json: JSON.stringify(chats, null, 2)
    });
  } else if (request.action === 'downloadChats') {
    const chats = extractCodyChats();
    const markdownContent = formatChatsAsMarkdown(chats);
    const jsonContent = JSON.stringify(chats, null, 2);

    downloadAsFile(markdownContent, 'cody_chat_export.md', 'text/markdown');
    downloadAsFile(jsonContent, 'cody_chat_export.json', 'application/json');

    sendResponse({success: true});
  }
  return true; // Indicates that the response will be sent asynchronously
});

console.log('Cody Exporter content script loaded');
