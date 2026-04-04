(function () {
    const ui = document.querySelector('.fortnite-ui');
    const healthBar = document.getElementById('fortnite-health-level');
    const armorBar = document.getElementById('fortnite-armor-level');

    let hudEnabled = true;
    let healthUiActive = false;

    function clampPercent(value) {
        const n = Number(value);
        if (Number.isNaN(n)) return 0;
        return Math.max(0, Math.min(100, n));
    }

    function applyVisibility() {
        ui.style.display = healthUiActive && hudEnabled ? 'block' : 'none';
    }

    function renderBars(health, armor) {
        healthBar.style.width = `${health}%`;
        armorBar.style.width = `${armor}%`;

        if (health <= 30) {
            healthBar.style.backgroundColor = '#ff5454';
            healthBar.style.boxShadow = '0 0 14px rgba(255, 84, 84, 0.95)';
        } else if (health <= 60) {
            healthBar.style.backgroundColor = '#f1c94f';
            healthBar.style.boxShadow = '0 0 12px rgba(241, 201, 79, 0.8)';
        } else {
            healthBar.style.backgroundColor = '#63e058';
            healthBar.style.boxShadow = '0 0 10px rgba(100, 235, 84, 0.55)';
        }

        const armorGlow = 0.35 + (armor / 100) * 0.65;
        armorBar.style.backgroundColor = '#4f95ff';
        armorBar.style.boxShadow = `0 0 12px rgba(79, 149, 255, ${armorGlow.toFixed(2)})`;
    }

    window.addEventListener('message', function (event) {
        const data = event.data || {};

        if (typeof data.showMoney === 'boolean') {
            hudEnabled = data.showMoney;
            applyVisibility();
        }

        if (typeof data.health !== 'undefined' || typeof data.armor !== 'undefined') {
            healthUiActive = true;
            const health = clampPercent(data.health);
            const armor = clampPercent(data.armor);
            applyVisibility();
            renderBars(health, armor);
        }
    });
})();
