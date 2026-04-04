// Ensure jQuery is loaded securely
(function() {
    // Remove any existing jQuery
    if (window.jQuery) {
        delete window.jQuery;
        delete window.$;
    }
    
    // Load jQuery securely
    var script = document.createElement('script');
    script.src = 'https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js';
    script.type = 'text/javascript';
    document.head.appendChild(script);
    
    // Fix moneyUILoaded request
    script.onload = function() {
        // Override jQuery.ajax to force HTTPS
        var originalAjax = $.ajax;
        $.ajax = function(url, options) {
            if (typeof url === 'string') {
                url = url.replace('http://', 'https://');
            } else if (url && url.url) {
                url.url = url.url.replace('http://', 'https://');
            }
            return originalAjax.call($, url, options);
        };
        
        // Fix XMLHttpRequest to vice
        $(document).ajaxSend(function(e, xhr, settings) {
            if (settings.url.indexOf('vice/') !== -1) {
                settings.url = settings.url.replace('http://', 'https://');
            }
        });
    };
})(); 