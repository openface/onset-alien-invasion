function ShowGarageComputer() {
    $('#terminal-box #content').html(`
        <p>READ THESE INSTRUCTIONS CAREFULLY!</p>
        
        <p>The surrounding area has been invaded by alien lifeform. If you are
        reading this message, you may be the last of the remaining human
        survivors. Follow these rules to stay alive:</p>

        <ul>
            <li>This house and it's perimeter is a SAFE ZONE from alien attack.</li>

            <li>The mainland has been infected with radiation. DO NOT ENTER THE OCEAN!</li>

            <li>THERE ARE ALIENS ON THIS ISLAND! If you are being chased, RUN TO SAFETY
            UNLESS YOU ARE ARMED!</li>

            <li>WATCH FOR SUPPLY DROPS! They contain armor, health, and weapons. You 
            will see flares indicating where they drop.  You can also craft supplies
            from scrap parts found on the island.</li>

            <li>The mothership is on it's way to this island! YOUR MISSION IS TO DESTROY 
            THE MOTHERSHIP. You will need supplies before you can fight back!</li>

            <li>FIND THE MISSING SATELLITE PARTS!  Scavenge the area to find computer
            parts and bring them back to the satellite terminal. Once the satellite
            is operational, it will draw the mothership in for an attack.</li>
        </ul>

        <p>Good luck</p>
    `);
    $('#terminal-box').show();
}

function ShowSatelliteComputer(percentage) {
    $('#terminal-box #content').html(`
        <p>Installing new component...</p>
        <div class="meter">
            <span><span class="progress"></span></span>
        </div>

        <p class="blinking">SATELLITE COMMUNICATIONS WILL BE <b>${percentage}%</b> OPERATIONAL.</p>

        <p><b>The chance of being attacked by aliens has INCREASED!</b></p>

        <p>Continue collecting satellite parts to initiate signal transmission
        from this satellite.  Once enough parts are acquired, the satellite
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

$(document).ready(function () {
    /*ShowGarageComputer();*/
});
