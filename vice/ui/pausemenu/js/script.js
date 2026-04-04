window.addEventListener('message', function(event) {
    var data = event.data;
    let date = new Date();
    let day = String(date.getDate()).padStart(2, '0');
    let month = String(date.getMonth() + 1).padStart(2, '0');
    let year = date.getFullYear();
    let hours = String(date.getHours()).padStart(2, '0');
    let minutes = String(date.getMinutes()).padStart(2, '0');
    let seconds = String(date.getSeconds()).padStart(2, '0');
    let currentTime = hours + ':' + minutes;
    let currentDate = day + '/' + month + '/' + year + ' ' + currentTime;

    if (data.type === 'viceTogglePauseMenu') {
        if (data.toggle === true) {
            document.getElementById('viceRoot').style.display = "block";
            document.getElementById('todaysDate').innerText = currentDate;
            document.getElementById('viceDLastName').innerText = data.viceDLastName;
            document.getElementById('viceDBirthdate').innerText = data.viceDBirthdate;
            document.getElementById('viceDGender').innerText = data.viceDGender;
            document.getElementById('vicePlrName').innerText = data.vicePlrName;
            document.getElementById('totalPlayers').innerText = data.totalPlayers;
        }  else if (data.toggle === false) {
            document.getElementById('viceRoot').style.display = "none";
        }
    }
});

var elements = document.querySelectorAll("#viceCuBbox, #viceconnect, #vicePmRow, #vicePmBox3, #vicePmBox2, #viceCsettings, #viceCsButtons, #viceComRules, #Store, #joinDiscord, #disupte, #viceCdisconnect, #viceCmap, .vicePmNavCont, .viceNavRow, .vicePmBox2, .vicePmBox3");

elements.forEach(function(element) {
    element.addEventListener('mouseenter', function() {
        var audio = new Audio('hover.mp3');
        audio.volume = 0.3;
        audio.play();
    });
});

$('#viceCsettings').click(function(){
    $.post('https://vice/Settings', JSON.stringify({}), function(data) {
    });
});

$('#Store').click(function(){
    $.post('https://vice/Store', JSON.stringify({}), function(data) {
    });
});

$('#viceCuBbox').click(function(){
    $.post('https://vice/Guide', JSON.stringify({}), function(data) {
    });
});

$('#twitter').click(function(){
    $.post('https://vice/Twitter', JSON.stringify({}), function(data) {
    });
});

$('#dispute').click(function(){
    $.post('https://vice/Dispute', JSON.stringify({}), function(data) {
    });
});

$('#viceconnect').click(function(){
    $.post('https://vice/DeathMatchF8', JSON.stringify({}), function(data) {
    });
});

$('#joinDiscord').click(function(){
    $.post('https://vice/DeathMatchDiscord', JSON.stringify({}), function(data) {
    });
});

$('#website').click(function(){
    $.post('https://vice/Website', JSON.stringify({}), function(data) {
    });
});

$('#viceCuBbox').click(function(){
    $.post('https://vice/Guide', JSON.stringify({}), function(data) {
    });
});

$('#vicePmBox3').click(function(){
    $.post('https://vice/ComRules', JSON.stringify({}), function(data) {
    });
});

$('#vicePmBox2').click(function(){
    $.post('https://vice/Rules', JSON.stringify({}), function(data) {
    });
});
$('#viceCmap').click(function(){
    $.post('https://vice/Map', JSON.stringify({}), function(data) {
    });
});
$('#viceCdisconnect').click(function(){
    $.post('https://vice/Disconnect', JSON.stringify({}), function(data) {
    });
});

window.addEventListener('keydown', function(event) {
    if (event.key === "Escape") {
        $.post('https://vice/Close', JSON.stringify({}), function(data) {});
        document.getElementById('viceRoot').style.display = "none";
    }
});