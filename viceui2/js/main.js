var selectedPlayer = null;
var chatHistory = {};
var userID = null;
var mutedPlayers = [];
var blockedPlayers = [];
var from_id = null;
var disputeData = null;
var messagesList = document.getElementById('messagesList');
var socket = null;
var connectionAttempts = 0;
const maxAttempts = 3;

function initializeWebSocket() {
    if (socket && (socket.readyState === WebSocket.OPEN || socket.readyState === WebSocket.CONNECTING)) {
        return;
    }

    try {
        // Use the current window location to determine WebSocket URL
        const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
        const host = window.location.hostname || 'localhost';
        const port = '30120';
        const wsUrl = `${protocol}//${host}:${port}`;

        socket = new WebSocket(wsUrl);

        socket.onopen = () => {
            console.log('WebSocket connected successfully');
            connectionAttempts = 0;
        };

        socket.onerror = (error) => {
            console.warn('WebSocket error - falling back to direct NUI messaging');
            // Don't retry on error - just use fallback
            socket = null;
        };

        socket.onclose = () => {
            if (connectionAttempts < maxAttempts) {
                connectionAttempts++;
                setTimeout(initializeWebSocket, 1000 * connectionAttempts);
            } else {
                console.warn('WebSocket connection failed - using fallback');
                socket = null;
            }
        };

        socket.onmessage = (event) => {
            handleWebSocketMessage(event.data);
        };

    } catch (error) {
        console.error('WebSocket initialization failed:', error);
        socket = null;
    }
}

function handleWebSocketMessage(data) {
    try {
        const message = typeof data === 'string' ? JSON.parse(data) : data;
        
        // Handle the message based on type
        switch (message.type) {
            case 'updateMoney':
                updateMoneyDisplay(message);
                break;
            // Add other message type handlers here
            default:
                console.log('Unhandled message type:', message.type);
        }
    } catch (error) {
        console.warn('Error handling message:', error);
    }
}

// Initialize WebSocket when document is ready
document.addEventListener('DOMContentLoaded', () => {
    initializeWebSocket();
});

// Handle visibility changes
document.addEventListener('visibilitychange', () => {
    if (document.visibilityState === 'visible') {
        initializeWebSocket();
    }
});

// Fallback for money updates when WebSocket isn't available
window.addEventListener('message', (event) => {
    if (!socket || socket.readyState !== WebSocket.OPEN) {
        handleWebSocketMessage(event.data);
    }
});

window.addEventListener('message', function(event) {
    var data = event.data;

    if (data.type === 'toggleDisputeSystem') {
        var disputeContainer = document.getElementById('dispute-container');
        var disputeBackground = document.getElementById('dispute-background');
        var disputeScreen = document.getElementById('dispute-screen');
        var playersList = document.getElementById('playersList');
        var inboxList = document.getElementById('inbox-desc-id');
        var inboxList2 = document.getElementById('inbox-desc-name');
        var inboxContent = document.querySelector('.dispute-inbox-content'); 

        if (data.toggle === true) {
            disputeContainer.classList.remove('hide');
            disputeBackground.classList.remove('hide');
            disputeScreen.classList.remove('hide');
            inboxContent.style.display = 'block'; 

            var playersList = document.getElementById('dispute-players-list');
            
            playersList.innerHTML = '';
            
            disputeData = JSON.parse(data.disputeData);
            userID = data.userID;

            var userPlayer = disputeData.players.find(player => player.id === userID);            

            if (userPlayer) {
                var userName = userPlayer.name;
                document.getElementById('inbox-desc-id').textContent = userPlayer;
                document.getElementById('inbox-desc-name').textContent = userName;
            }

            var sentMessages = JSON.parse(data.sentMessages); 
            var receivedMessages = JSON.parse(data.receivedMessages); 

            chatHistory.sent = sentMessages;
            chatHistory.received = receivedMessages;

            messagesList.innerHTML = '';

            inboxList.innerHTML = '';

            inboxList2.innerHTML = '';
            
            if (Array.isArray(disputeData.players)) {
                disputeData.players.forEach(function(player) {
                    chatHistory[player.id] = {
                        sent: sentMessages.filter(message => message.to === player.id),
                        received: receivedMessages.filter(message => message.from === player.id)
                    };
                    let playerItem = document.createElement('div');
                    playerItem.className = 'dispute-players-item';
                
                    let playerInfo = document.createElement('div');
                    playerInfo.className = 'dispute-player-info';
                
                    let playerName = document.createElement('h4');
                    playerName.className = 'dispute-player-name';
                    playerName.textContent = player.name;
                    playerInfo.appendChild(playerName);
                
                    playerItem.appendChild(playerInfo);
                    playersList.appendChild(playerItem);
                
                    playerItem.addEventListener('click', function() {
                        if (selectedPlayer && selectedPlayer.id === player.id) {
                            showNotification('Dispute System', 'Already selected: ' + player.name);
                            return;
                        } else {
                            selectedPlayer = player;
                            showNotification('Dispute System', 'Selected player: ' + player.name);
                    
                            if (selectedPlayer) {
                                document.getElementById('inbox-desc-id').textContent = selectedPlayer.id;
                                document.getElementById('inbox-desc-name').textContent = selectedPlayer.name;
                            }
                        }
                    
                        if (messagesList) {
                            var allMessages = [];
                    
                            if (chatHistory[selectedPlayer.id] && chatHistory[selectedPlayer.id].sent) {
                                allMessages = allMessages.concat(chatHistory[selectedPlayer.id].sent.map(message => {
                                    return {...message, direction: 'right'};
                                }));
                            }
                            if (chatHistory[selectedPlayer.id] && chatHistory[selectedPlayer.id].received) {
                                allMessages = allMessages.concat(chatHistory[selectedPlayer.id].received.map(message => {
                                    return {...message, direction: 'left'};
                                }));
                            }
                    
                            function getTimestamp(message) {
                                return message.timestamp ? new Date(message.timestamp) : new Date(0);
                            }
                    
                            allMessages.sort((a, b) => getTimestamp(a) - getTimestamp(b));
                    
                            allMessages.forEach(function(message) {
                                var messageItem = document.createElement('div');
                                messageItem.className = 'dispute-message-item dispute-message-' + message.direction;
                            
                                var messageText = document.createElement('p');
                                messageText.className = 'dispute-message-text';
                                messageText.textContent = message.message;
                                messageItem.appendChild(messageText);
                            
                                var messageDate = document.createElement('span');
                                messageDate.className = 'dispute-message-date';
                                var messageTimestamp = new Date(message.timestamp); 
                                messageDate.textContent = messageTimestamp.getDate() + '/' + (messageTimestamp.getMonth() + 1) + '/' + messageTimestamp.getFullYear(); 
                                messageItem.appendChild(messageDate);
                            
                                messagesList.appendChild(messageItem);
                            });
                            messagesList.scrollTop = messagesList.scrollHeight;
                        }
                    });
                });
            }
        } 
        
        if (data.toggle === false) {
            disputeContainer.classList.add('hide');
            disputeBackground.classList.add('hide');
            disputeScreen.classList.add('hide');
            selectedPlayer = null;
        }
    }
    if (data.type === 'newMessage') {
        var from_id = data.from;
        var to_id = data.to;
        var message = data.message;
        var fromPlayer = disputeData.players.find(player => player.id === from_id); 
        var fromName = fromPlayer ? fromPlayer.name : from_id;
    
        var messageData = {message: message, timestamp: new Date()};
    
        addMessageToChatHistory(from_id, to_id, messageData);
    }
    if (data.type === 'showmessageNotification') {
        var from_id = data.from;
        var fromPlayer = disputeData.players.find(player => player.id === from_id);
        var fromName = fromPlayer ? fromPlayer.name : from_id;
    
        if (!mutedPlayers.includes(from_id)) {
            showNotification('Dispute System', 'New message from ' + fromName, from_id);
        }
    }
});

function addMessageToChatHistory(from_id, to_id, messageData) {
    if (!chatHistory[from_id]) {
        chatHistory[from_id] = {sent: [], received: []};
    }
    if (!chatHistory[to_id]) {
        chatHistory[to_id] = {sent: [], received: []};
    }

    chatHistory[from_id].sent.push(messageData);
    chatHistory[to_id].received.push(messageData);

    var event = new CustomEvent('newChatHistoryMessage', { detail: { from_id: from_id, to_id: to_id, messageData: messageData } });
    window.dispatchEvent(event);
}

window.addEventListener('newChatHistoryMessage', function(event) {
    var from_id = event.detail.from_id;
    var to_id = event.detail.to_id;
    var messageData = event.detail.messageData;

    if (selectedPlayer && ((from_id === userID && to_id === selectedPlayer.id) || (from_id === selectedPlayer.id && to_id === userID))) {
        var direction = from_id === userID ? 'right' : 'left';

        if (direction === 'left') {
            if (messagesList) {
                var messageItem = document.createElement('div');
                messageItem.className = 'dispute-message-item dispute-message-' + direction;

                var messageText = document.createElement('p');
                messageText.className = 'dispute-message-text';
                messageText.textContent = messageData.message;
                messageItem.appendChild(messageText);

                var messageDate = document.createElement('span');
                messageDate.className = 'dispute-message-date';
                var currentDate = new Date();
                messageDate.textContent = currentDate.getDate() + '/' + (currentDate.getMonth() + 1) + '/' + currentDate.getFullYear();
                messageItem.appendChild(messageDate);

                messagesList.appendChild(messageItem);
                messagesList.scrollTop = messagesList.scrollHeight;
                
                if (to_id === userID) {
                    showReceivedNotification('Dispute System', 'New message from ID: ' + from_id, from_id, userID);
                }
            }
        }
    }
});

function sendMessage() {
    var messageInput = document.querySelector('.dispute-message-input');
    if (messageInput.value.trim() !== '' && selectedPlayer !== null) {
        var player = disputeData.players.find(player => player.id === selectedPlayer.id);

        console.log('Player:', player);

        if (player && player.blocked && player.blocked.includes(userID)) {
            console.log('This user has you blocked');
            showNotification('Dispute System', 'This user has you blocked');
            return;
        }

        var currentUser = disputeData.players.find(player => player.id === userID);
        if (currentUser && currentUser.blocked && currentUser.blocked.includes(selectedPlayer.id)) {
            console.log('You have this user blocked');
            showNotification('Dispute System', 'You have this user blocked');
            return;
        }

        if (blockedPlayers.includes(selectedPlayer.id)) {
            console.log('You have this user blocked');
            showNotification('Dispute System', 'You have this user blocked');
            return;
        }

        var newMessage = {
            from: userID,
            to: selectedPlayer.id,
            message: messageInput.value,
            timestamp: new Date() // Add a timestamp property
        };  

        var messageData = newMessage;
    
        addMessageToChatHistory(userID, selectedPlayer.id, messageData);

        $.post(`https://viceui2/newMessage`, JSON.stringify({
            message: newMessage
        }), function() {
            var event = new CustomEvent('newMessage', { detail: { from: userID, to: selectedPlayer.id } });
            window.dispatchEvent(event);
        });

        showNotification('Dispute System', 'Sent message to ' + selectedPlayer.name + ' successfully!');

        var newMessageElement = document.createElement('div');
        newMessageElement.className = 'dispute-message-item dispute-message-right';

        var messageText = document.createElement('p');
        messageText.className = 'dispute-message-text';
        messageText.textContent = messageInput.value;
        newMessageElement.appendChild(messageText);

        var messageDate = document.createElement('span');
        messageDate.className = 'dispute-message-date';
        var currentDate = new Date();
        messageDate.textContent = currentDate.getDate() + '/' + (currentDate.getMonth() + 1) + '/' + currentDate.getFullYear();
        newMessageElement.appendChild(messageDate);

        if (!selectedPlayer.messages) {
            selectedPlayer.messages = [];
        }
        selectedPlayer.messages.push(newMessage);

        if (!chatHistory[selectedPlayer.id]) {
            chatHistory[selectedPlayer.id] = {sent: [], received: []};
        }
        chatHistory[selectedPlayer.id].sent.push({...newMessage, direction: 'right'});

        if (chatHistory[userID]) {
            chatHistory[userID].sent.push({...newMessage, direction: 'right'});
        } else {
            chatHistory[userID] = {sent: [{...newMessage, direction: 'right'}], received: []};
        }

        messagesList.appendChild(newMessageElement);

        messagesList.scrollTop = messagesList.scrollHeight;

        if (socket.readyState === WebSocket.OPEN) {
            socket.send(JSON.stringify(newMessage));
        } else {
            console.error('Cannot send message, WebSocket is not open');
        }

        messageInput.value = '';
    } else {
        showNotification('Dispute System', 'Invalid selection or message');
    }
}

var fadeInEffect;
var fadeOutEffect;
var fadeOutTimeout;

function showReceivedNotification(title, message, from_id, receiver_id) {
    if (mutedPlayers.includes(from_id) || from_id === userID || receiver_id !== userID) {
        return;
    }
    var notification = document.getElementById('disputeNotification');

    clearInterval(fadeInEffect);
    clearInterval(fadeOutEffect);
    clearTimeout(fadeOutTimeout);

    notification.style.display = 'block';
    notification.style.opacity = 0;

    fadeInEffect = setInterval(function () {
        if (notification.style.opacity < 1) {
            notification.style.opacity = parseFloat(notification.style.opacity) + 0.1;
        } else {
            clearInterval(fadeInEffect);

            fadeOutTimeout = setTimeout(function() {
                fadeOutEffect = setInterval(function () {
                    if (notification.style.opacity > 0) {
                        notification.style.opacity = parseFloat(notification.style.opacity) - 0.1;
                    } else {
                        clearInterval(fadeOutEffect);
                        notification.style.display = 'none';
                    }
                }, 30);
            }, 5000);
        }
    }, 30);

    document.getElementById('disputeNotiTitle').textContent = title;
    document.getElementById('disputeNotiDesc').textContent = message;
}

function showNotification(title, message) {
    var notification = document.getElementById('disputeNotification');

    clearInterval(fadeInEffect);
    clearInterval(fadeOutEffect);
    clearTimeout(fadeOutTimeout);

    notification.style.display = 'block';
    notification.style.opacity = 0;

    fadeInEffect = setInterval(function () {
        if (notification.style.opacity < 1) {
            notification.style.opacity = parseFloat(notification.style.opacity) + 0.1;
        } else {
            clearInterval(fadeInEffect);

            fadeOutTimeout = setTimeout(function() {
                fadeOutEffect = setInterval(function () {
                    if (notification.style.opacity > 0) {
                        notification.style.opacity = parseFloat(notification.style.opacity) - 0.1;
                    } else {
                        clearInterval(fadeOutEffect);
                        notification.style.display = 'none';
                    }
                }, 30);
            }, 5000);
        }
    }, 30);

    document.getElementById('disputeNotiTitle').textContent = title;
    document.getElementById('disputeNotiDesc').textContent = message;
}

document.onkeydown = function(evt) {
    evt = evt || window.event;
    var isEscape = false;
    if ("key" in evt) {
        isEscape = (evt.key === "Escape" || evt.key === "Esc");
    } else {
        isEscape = (evt.keyCode === 27);
    }
    if (isEscape) {
        $.post('https://viceui2/closeDisputeMenu', JSON.stringify({}));
    }
};

document.addEventListener('DOMContentLoaded', function() {
    var sendButton = document.querySelector('.dispute-message-button');
    var muteButton = document.getElementById('muteButton');
    var blockButton = document.getElementById('blockButton');
    var deleteButton = document.getElementById('deleteButton');
    messagesList = document.querySelector('.dispute-messages-list');
    var searchInput = document.getElementById('dispute-players-search');
    var playersList = document.getElementById('dispute-players-list');
    var reportButon = document.getElementById('dispute-report');

    searchInput.addEventListener('keypress', function(event) {
        if (event.key === 'Enter') {
            var searchValue = searchInput.value.toLowerCase();
            var filteredPlayers = disputeData.players.filter(player => player.name.toLowerCase().includes(searchValue));
    
            playersList.innerHTML = '';
    
            if (filteredPlayers.length === 0) {
                playersList.textContent = 'No players found';
            } else {
                filteredPlayers.forEach(function(player) {
                    let playerItem = document.createElement('div');
                    playerItem.className = 'dispute-players-item';
                
                    let playerInfo = document.createElement('div');
                    playerInfo.className = 'dispute-player-info';
                
                    let playerName = document.createElement('h4');
                    playerName.className = 'dispute-player-name';
                    playerName.textContent = player.name;
                    playerInfo.appendChild(playerName);
                
                    playerItem.appendChild(playerInfo);
                    playersList.appendChild(playerItem);
                
                    playerItem.addEventListener('click', function() {
                        selectedPlayer = player;
                    
                        showNotification('Dispute System', 'Selected player: ' + player.name);
                    
                        if (selectedPlayer) {
                            document.getElementById('inbox-desc-id').textContent = selectedPlayer.id;
                            document.getElementById('inbox-desc-name').textContent = selectedPlayer.name;
                        }
                    
                        if (messagesList) {
                            messagesList.innerHTML = '';
                            var allMessages = [];
                    
                            if (chatHistory[selectedPlayer.id] && chatHistory[selectedPlayer.id].sent) {
                                allMessages = allMessages.concat(chatHistory[selectedPlayer.id].sent.map(message => {
                                    return {...message, direction: 'right'};
                                }));
                            }
                            if (chatHistory[selectedPlayer.id] && chatHistory[selectedPlayer.id].received) {
                                allMessages = allMessages.concat(chatHistory[selectedPlayer.id].received.map(message => {
                                    return {...message, direction: 'left'};
                                }));
                            }
                    
                            function getTimestamp(message) {
                                return message.timestamp ? new Date(message.timestamp) : new Date(0);
                            }
                    
                            allMessages.sort((a, b) => getTimestamp(a) - getTimestamp(b));
                    
                            allMessages.forEach(function(message) {
                                var messageItem = document.createElement('div');
                                messageItem.className = 'dispute-message-item dispute-message-' + message.direction;
                    
                                var messageText = document.createElement('p');
                                messageText.className = 'dispute-message-text';
                                messageText.textContent = message.message;
                                messageItem.appendChild(messageText);
                    
                                var messageDate = document.createElement('span');
                                messageDate.className = 'dispute-message-date';
                                var currentDate = new Date();
                                messageDate.textContent = currentDate.getDate() + '/' + (currentDate.getMonth() + 1) + '/' + currentDate.getFullYear();
                                messageItem.appendChild(messageDate);
                    
                                messagesList.appendChild(messageItem);
                            });
                            messagesList.scrollTop = messagesList.scrollHeight;
                        }
                    });
                });
            }
        }
    });

    document.querySelector('.dispute-message-input').addEventListener('keypress', function(event) {
        if (event.key === 'Enter') {
            sendMessage();
        }
    });

    sendButton.addEventListener('click', function() {
        sendMessage();
    });

    reportButon.addEventListener('click', function() {
        $.post(`https://viceui2/openPReport`, JSON.stringify({
        }));
    });


        muteButton.addEventListener('click', function() {
            console.log('Mute button clicked');
            if (selectedPlayer === null) {
                showNotification('Dispute System', 'No player selected');
                return;
            }
            $.post(`https://viceui2/mutePlr`, JSON.stringify({
                user2bMuted: selectedPlayer.id
            }));
            mutedPlayers.push(selectedPlayer.id);
            showNotification('Dispute System', 'You have muted ID: ' + selectedPlayer.id);
        });

        blockButton.addEventListener('click', function() {
            console.log('Block button clicked');
            if (selectedPlayer === null) {
                showNotification('Dispute System', 'No player selected');
                return;
            }
            $.post(`https://viceui2/blockPlr`, JSON.stringify({
                user2bMuted: selectedPlayer.id
            }));
            blockedPlayers.push(selectedPlayer.id);
            showNotification('Dispute System', 'You have blocked ID: ' + selectedPlayer.id);
        });

        deleteButton.addEventListener('click', function() {
            console.log('Delete button clicked');
            if (selectedPlayer === null) {
                showNotification('Dispute System', 'No player selected');
                return;
            }
            $.post(`https://viceui2/delPlr`, JSON.stringify({
                user2bMuted: selectedPlayer.id
            })).done(function() {
                var playersList = document.getElementById('dispute-players-list');
                playersList.innerHTML = '';
                selectedPlayer.id = null;
                showNotification('Dispute System', 'Deleted Player');
        
                var inbox = document.querySelector('.dispute-inbox');
                var children = inbox.children;
                for (var i = 0; i < children.length; i++) {
                    if (children[i].classList.contains('dispute-body-header') === false) {
                        children[i].style.display = 'none';
                    }
                }
            });
        });
});