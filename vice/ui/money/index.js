$(document).ready(function(){
  let hudEnabled = true;
  let combatTimerSeconds = 0;
  window.addEventListener("message", function(event){
  if(typeof event.data.health !== "undefined" || typeof event.data.armor !== "undefined"){
      const health = clampPercent(event.data.health);
      const armor = clampPercent(event.data.armor);
      updateHealthArmor(health, armor);
  }
  if(event.data.updateMoney == true){
      positionHud(event.data.topLeftAnchor)
      setMoney(event.data.cash,'#cash-text');
      setMoney(event.data.redmoney,'#redmoney-text');
      if (event.data.redmoney == "£0" || event.data.redmoney == "Â£0")
      {
          document.getElementById('redmoney').style.display = "none";
      }
      else
      {
          document.getElementById('redmoney').style.display = "flex";
      }
      setMoney(event.data.bank,'#bank-text');
      setProximity(event.data.proximity);
  }
  if(typeof event.data.combatTimer !== "undefined"){
      setCombatTimer(event.data.combatTimer);
  }
  if(event.data.moneyTalking == true){
      document.getElementById('proximity').style.color = "lightblue";
  }else if(event.data.moneyTalking == false) {
      document.getElementById('proximity').style.color = "white";
  }
  if(event.data.showMoney == false){
      hudEnabled = false;
      document.getElementById('proximity').style.display = "none";
      document.getElementById('cash-text').style.display = "none";
      document.getElementById('bank-text').style.display = "none";
      if (combatTimerSeconds <= 0) {
          document.getElementById('bighudfam').style.display = "none";
      }
  }
  if(event.data.showMoney == true){
      hudEnabled = true;
      document.getElementById('proximity').style.display = "block";
      document.getElementById('cash-text').style.display = "block";
      document.getElementById('bank-text').style.display = "block";
      document.getElementById('bighudfam').style.display = "block";
  }
  if (event.data.type === "UPDATE_PROFILE_PIC") {
      document.getElementById('profile-pic').src = event.data.url;
  }
  if (event.data.setPFP) {
      const img = document.getElementById('profile-pic');
      img.src = event.data.setPFP;
      // If the image fails to load, show a fallback
      img.onerror = function() {
          img.src = 'money/img/default.png';
          img.alt = 'No Avatar URL';
          img.title = 'No Avatar URL: ' + event.data.setPFP;
      };
      // Also, show the URL as a tooltip for debugging
      img.title = event.data.setPFP;
  }
  if (typeof event.data.permId !== "undefined" && event.data.permId !== null) {
      const permidDiv = document.getElementById('permid');
      permidDiv.innerText = "ID: " + event.data.permId;
  }
  if (event.data.action === "displayUserId" && typeof event.data.userId !== "undefined") {
      const permidDiv = document.getElementById('permid');
      permidDiv.innerText = "ID: " + event.data.userId;
  }
  });

  function setProximity(amount, element){
      document.getElementById('proximity').innerHTML = amount;
  }
  function setMoney(amount, element){
      $(element).text(amount);
  }
  function setCombatTimer(amount){
      const timerEl = document.getElementById('combat-timer-text');
      const timerRowEl = document.getElementById('combat-timer-row');
      const hudEl = document.getElementById('bighudfam');
      if (!timerEl || !timerRowEl) return;
      const seconds = Math.max(0, parseInt(amount, 10) || 0);
      combatTimerSeconds = seconds;
      timerRowEl.style.display = seconds > 0 ? "flex" : "none";
      if (seconds > 0 && hudEl) {
          hudEl.style.display = "block";
      } else if (!hudEnabled && hudEl) {
          hudEl.style.display = "none";
      }
      timerEl.innerText = "Combat Timer: " + seconds + "s";
      timerEl.style.color = "#ff5252";
  }
  function clampPercent(value){
      const num = Number(value);
      if (Number.isNaN(num)) return 0;
      if (num < 0) return 0;
      if (num > 100) return 100;
      return num;
  }
  function updateHealthArmor(health, armor){
      const healthEl = document.getElementById('fortnite-health-level');
      const armorEl = document.getElementById('fortnite-armor-level');
      const healthTextEl = document.getElementById('fortnite-health-text');
      const armorTextEl = document.getElementById('fortnite-armor-text');
      if (!healthEl || !armorEl) return;

      healthEl.style.width = health + "%";
      armorEl.style.width = armor + "%";
      if (healthTextEl) healthTextEl.textContent = Math.round(health) + "%";
      if (armorTextEl) armorTextEl.textContent = Math.round(armor) + "%";

      if (health <= 30){
          healthEl.style.backgroundColor = '#ff5454';
          healthEl.style.boxShadow = '0 0 14px rgba(255, 84, 84, 0.95)';
      } else if (health <= 60){
          healthEl.style.backgroundColor = '#f1c94f';
          healthEl.style.boxShadow = '0 0 12px rgba(241, 201, 79, 0.8)';
      } else {
          healthEl.style.backgroundColor = '#63e058';
          healthEl.style.boxShadow = '0 0 10px rgba(100, 235, 84, 0.55)';
      }

      const armorGlow = (0.35 + (armor / 100) * 0.65).toFixed(2);
      armorEl.style.backgroundColor = '#4f95ff';
      armorEl.style.boxShadow = `0 0 12px rgba(79, 149, 255, ${armorGlow})`;
  }
  function positionHud(topLeftAnchor){
      $( ".money-hud" ).css({
        left: "auto",
        right: "0.25vw",
        bottom: "1.2vh"
      });
  }

  // Clock based on user's local hour
  function updateClock() {
  var now = new Date(),
      time = (now.getHours()<10?'0':'') + now.getHours() + ':' + (now.getMinutes()<10?'0':'') + now.getMinutes();

  document.getElementById('hour').innerHTML = [time];
  setTimeout(updateClock, 1000);
  }
  updateClock();

  $.post("https://vice/moneyUILoaded", JSON.stringify({}));
});




