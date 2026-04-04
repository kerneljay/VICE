function AnnounceManager()
{
  var _this = this;
  setInterval(function(){ _this.tick(); }, 30000);

  this.announces = []
  this.div = document.createElement("div");
  this.div.classList.add("announce");
  this.currentAnnounceTimeout = null; // Add a property to store the timeout ID

  document.body.appendChild(this.div);
}

AnnounceManager.prototype.addAnnounce = function(background, content)
{
  // Clear existing announcements and show the new one immediately with fade-in
  this.announces = []; // Clear queue to show the latest immediately

  // Clear any existing timeout and stop current animations before adding a new announce
  if (this.currentAnnounceTimeout) {
    clearTimeout(this.currentAnnounceTimeout);
    this.currentAnnounceTimeout = null;
  }
  $(this.div).stop(true, true); // Stop current animations and clear the animation queue

  var announce = {background: background, content: content}
  this.announces.push(announce);
  this.displayNextAnnounce(); // Call a new function to handle display
}

AnnounceManager.prototype.displayNextAnnounce = function()
{
  var _this = this;
  var jdiv = $(this.div);

  if (_this.announces.length > 0) {
    var announce = _this.announces[0];
    _this.announces.splice(0, 1); // Remove the announcement after getting it

    // Update content and background immediately
    _this.div.style.backgroundImage = "url('"+announce.background+"')";
    _this.div.innerHTML = '<div class="announce-text">' + announce.content + '</div>';

    // Ensure element is hidden before fading in
    _this.div.style.display = "none";

    // Fade in the element
    jdiv.fadeIn(800, function(){
      // After fading in, set a timeout to fade it out later
      _this.currentAnnounceTimeout = setTimeout(function(){
        jdiv.fadeOut(1500, function(){
          // After fading out, display the next announcement in the queue if any
          _this.displayNextAnnounce();
        });
      }, 30000); // Display duration (30 seconds)
    });
  } else {
    // If no announcements left, ensure the div is hidden
    _this.div.style.display = "none";
  }
}

// Remove or adjust the old tick function if it's no longer needed for queue processing
AnnounceManager.prototype.tick = function()
{
  // This function is now primarily for the initial setup or other periodic checks
  // The display logic is handled by displayNextAnnounce()
  // We can keep it for the setInterval if it's used for other things, otherwise remove setInterval
}

