////////////////////////////////////////
//////Tutorial Character Selcetion//////

window.addEventListener("message", (event) => {
    if (event.data.type === "menuState") {
        if (event.data.value) {
            $('#tutoriallist').fadeIn();
            ShowCharacterSelection();
        } else {
            $('#tutoriallist').fadeOut();
            hideCharacterSelection();
        }
    }
});

function ShowCharacterSelection() {
    var body = document.getElementById("tutoriallist");
    body.style.display = "";
}

function hideCharacterSelection() {
    var body = document.getElementById("tutoriallist");
    body.style.display = "none";
}

function emit(event) {
    fetch(`https://${GetParentResourceName()}/${event}`);
}

//////Tutorial Character Selcetion//////
///////////////////////////////////////