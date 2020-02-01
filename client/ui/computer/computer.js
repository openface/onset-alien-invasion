function ShowGarageComputer() {
    $('#terminal-box #content').html(`
The surrounding area has been invaded by alien lifeform. If you are
reading this message, you may be the last of the remaining human
survivors. Please read these instructions carefully!

The mainland has been infected with radiation. DO NOT ENTER THE OCEAN!

THERE ARE ALIENS ON THIS ISLAND! If you are being chased, RUN TO SAFETY! 
WATCH FOR SUPPLY DROPS. THEY CONTAIN WEAPONS, ARMOR, AND HEALTH. You 
will see flares indicating where they drop.

The mothership is on it's way to this island! You will need supplies
before you can fight back!

YOUR MISSION IS TO DESTROY THE MOTHERSHIP.  Scavenge the area to find
parts and bring them back to the satellite base.  The satellite, once
operational, can be used to draw the mothership.

Hit the TAB key for the scoreboard.

Good luc+++ATH0
NO CARRIER
    `);
    $('#terminal-box').show();
}

function ShowSatelliteComputer() {
    $('#terminal-box #content').html(`
Part acquired!
    `);
    $('#terminal-box').show();
}

function HideComputer() {
    $('#terminal-box').fadeOut();
}