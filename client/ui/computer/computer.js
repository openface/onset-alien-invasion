function ShowGarageComputer() {
    $('#terminal-box #content').html(`
        <p>READ THESE INSTRUCTIONS CAREFULLY!</p>
        
        <p>The surrounding area has been invaded by alien lifeform. If you are
        reading this message, you may be the last of the remaining human
        survivors. Please read these instructions carefully!</p>

        <p>The mainland has been infected with radiation. DO NOT ENTER THE OCEAN!</p>

        <p>THERE ARE ALIENS ON THIS ISLAND! If you are being chased, RUN TO SAFETY!</p>
        <p>WATCH FOR SUPPLY DROPS! THEY CONTAIN WEAPONS, ARMOR, AND HEALTH. You 
        will see flares indicating where they drop.</p>

        <p>The mothership is on it's way to this island! You will need supplies
        before you can fight back!</p>

        <p>YOUR MISSION IS TO DESTROY THE MOTHERSHIP.  Scavenge the area to find
        parts and bring them back to the satellite computer terminal.  The 
        satellite, once operational, can be used to draw the mothership.</p>

        <p>Hit the TAB key for the scoreboard.</p>

        <p>Good luc+++ATH0<br />
        NO CARRIER</p>
    `);
    $('#terminal-box').show();
}

function ShowSatelliteComputer(percentage) {
    $('#terminal-box #content').html(`

        login&gt; ************
        <p>Access granted.</p>

        <p class="blinking">SATELLITE COMMUNICATIONS ARE NOW <b>${percentage}%</b> OPERATIONAL...</p>

        <p>The risk of being attacked by aliens have INCREASED!</p>

        <p>Continue collecting satellite parts to initiate transmission
        from the satellite.  Once enough parts are acquired, the satellite
        will be operational.</p>
    `);
    $('#terminal-box').show();
}

function ShowSatelliteComputerComplete() {
    $('#terminal-box #content').html(`
        <p>Commencing satellite transmission...  OK<br />
        Waiting for signal acknowledgement... OK</p>

        <p>Signal received.  Standby for response.</p>
    `);
    $('#terminal-box').show().delay(3000).fadeOut('fast');
}

function HideComputer() {
    $('#terminal-box').fadeOut();
}