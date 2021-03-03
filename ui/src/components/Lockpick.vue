<template>
    <div id="container" @mousemove="onMouseMove" @mouseleave="onMouseLeave" @mousedown="onMouseDown" @mouseup="onMouseUp">
        <div id="wrap">
            <img src="https://s3-us-west-2.amazonaws.com/s.cdpn.io/95637/collar.png" alt="" id="collar" />
            <div id="cylinder" ref="cylinder"></div>
            <div id="driver" ref="driver"></div>
            <div id="pin" ref="pin">
                <div class="top"></div>
                <div class="bott"></div>
            </div>
        </div>
        <p>EXPERT LOCK</p>
        <p><span ref="pins_remaining">5</span> Bobby Pins Remaining</p>
        <div id="modal">
            <div id="win">
                <h1>Congratulations!</h1>
                <h2>By Jove, you've done it!</h2>
                <h3>You win: Nothing! Absolutely Nothing!</h3>
                <h4>Looks like you'll die alone and unfulfilled in the wasteland!</h4>
                <img src="https://s3-us-west-2.amazonaws.com/s.cdpn.io/95637/success.png" alt="" />
            </div>
            <div id="lose">
                <h1>Oh Dear</h1>
                <h2>It seems you've run out of bobby pins.</h2>
                <h3>Looks like you'll die alone and unfulfilled in the wasteland.</h3>
                <h4>Better luck next time.</h4>
                <img src="https://s3-us-west-2.amazonaws.com/s.cdpn.io/95637/failure.png" alt="" />
            </div>
        </div>
    </div>
</template>

<script>
import { gsap } from "gsap";
export default {
    name: "Lockpick",
    data: function() {
        return {
            minRot: -90,
            maxRot: 90,
            solveDeg: Math.random() * 180 - 90,
            solvePadding: 4,
            maxDistFromSolve: 45,
            pinRot: 0,
            cylRot: 0,
            lastMousePos: 0,
            mouseSmoothing: 2,
            keyRepeatRate: 25,
            cylRotSpeed: 3,
            pinDamage: 20,
            pinHealth: 100,
            pinDamageInterval: 150,
            numPins: 5,
            userPushingCyl: false,
            gameOver: false,
            gamePaused: false,
            cylRotationInterval: null,
            pinLastDamaged: null,
        };
    },
    computed: {},
    methods: {
        pushCyl: function() {
            var distFromSolve, cylRotationAllowance;
            clearInterval(this.cylRotationInterval);
            this.userPushingCyl = true;
            //set an interval based on keyrepeat that will rotate the cyl forward, and if cyl is at or past maxCylRotation based on pick distance from solve, display "bounce" anim and do damage to pick. If pick is within sweet spot params, allow pick to rotate to maxRot and trigger solve functionality

            //SO...to calculate max rotation, we need to create a linear scale from solveDeg+padding to maxDistFromSolve - if the user is more than X degrees away from solve zone, they are maximally distant and the cylinder cannot travel at all. Let's start with 45deg. So...we need to create a scale and do a linear conversion. If user is at or beyond max, return 0. If user is within padding zone, return 100. Cyl may travel that percentage of maxRot before hitting the damage zone.

            distFromSolve = Math.abs(this.pinRot - this.solveDeg) - this.solvePadding;
            distFromSolve = this.clamp(distFromSolve, this.maxDistFromSolve, 0);

            cylRotationAllowance = this.convertRanges(distFromSolve, 0, this.maxDistFromSolve, 1, 0.02); //oldval is distfromsolve, oldmin is....0? oldMax is maxDistFromSolve, newMin is 100 (we are at solve, so cyl may travel 100% of maxRot), newMax is 0 (we are at or beyond max dist from solve, so cyl may not travel at all - UPDATE - must give cyl just a teensy bit of travel so user isn't hammered);
            cylRotationAllowance = cylRotationAllowance * this.maxRot;

            this.cylRotationInterval = setInterval(() => {
                this.cylRot += this.cylRotSpeed;
                if (this.cylRot >= this.maxRot) {
                    this.cylRot = this.maxRot;
                    // do happy solvey stuff
                    clearInterval(this.cylRotationInterval);
                    this.unlock();
                } else if (this.cylRot >= cylRotationAllowance) {
                    this.cylRot = cylRotationAllowance;
                    // do sad pin-hurty stuff
                    this.damagePin();
                }

                //this.$refs.cylinder.style.transform = "rotateZ(" + this.cylRot + "deg)";
                this.$refs.driver.style.transform = "rotateZ(" + this.cylRot + "deg)";

            }, this.keyRepeatRate);
        },

        unpushCyl: function() {
            this.userPushingCyl = false;
            //set an interval based on keyrepeat that will rotate the cyl backward, and if cyl is at or past origin, set to origin and stop.
            clearInterval(this.cylRotationInterval);
            this.cylRotationInterval = setInterval(() => {
                this.cylRot -= this.cylRotSpeed;
                this.cylRot = Math.max(this.cylRot, 0);

                //this.$refs.cylinder.style.transform = "rotateZ(" + this.cylRot + "deg)";
                this.$refs.driver.style.transform = "rotateZ(" + this.cylRot + "deg)";

                if (this.cylRot <= 0) {
                    this.cylRot = 0;
                    clearInterval(this.cylRotationInterval);
                }
            }, this.keyRepeatRate);
        },

        damagePin: function() {
            if (!this.pinLastDamaged || Date.now() - this.pinLastDamaged > this.pinDamageInterval) {
                var tl = new gsap.timeline();

                this.pinHealth -= this.pinDamage;
                window.console.log("damagePin, pinHealth=", this.pinHealth);
                this.pinLastDamaged = Date.now();

                //pin damage/lock jiggle animation
                tl.to(this.$refs.pin, this.pinDamageInterval / 4 / 1000, {
                    rotationZ: this.pinRot - 2,
                });
                tl.to(this.$refs.pin, this.pinDamageInterval / 4 / 1000, {
                    rotationZ: this.pinRot,
                });
                if (this.pinHealth <= 0) {
                    this.breakPin();
                }
            }
        },

        breakPin: function() {
            var tl, pinTop, pinBott;
            this.gamePaused = true;
            clearInterval(this.cylRotationInterval);
            this.numPins--;
            this.$refs.pins_remaining.innerHTML = this.numPins;
            pinTop = this.$refs.pin.querySelector(".top");
            pinBott = this.$refs.pin.querySelector(".bott");
            let that = this;
            tl = gsap.timeline();
            tl.to(pinTop, 0.7, {
                rotationZ: -400,
                x: -200,
                y: -100,
                opacity: 0,
            });
            tl.to(
                pinBott,
                0.7,
                {
                    rotationZ: 400,
                    x: 200,
                    y: 100,
                    opacity: 0,
                    onComplete: function() {
                        if (that.numPins > 0) {
                            that.gamePaused = false;
                            that.reset();
                        } else {
                            that.outOfPins();
                        }
                    },
                },
                0
            );
            tl.play();
        },

        reset: function() {
            //solveDeg = ( Math.random() * 180 ) - 90;
            this.cylRot = 0;
            this.pinHealth = 100;
            this.pinRot = 0;
            //this.pin.style.transform = "rotateZ(" + this.pinRot + "deg)";
            //this.cyl.style.transform = "rotateZ(" + this.cylRot + "deg)";
            //this.driver.style.transform = "rotateZ(" + this.cylRot + "deg)";
            gsap.to(this.$refs.pin.querySelector(".top"), 0, {
                rotationZ: 0,
                x: 0,
                y: 0,
                opacity: 1,
            });
            gsap.to(this.$refs.pin.querySelector(".bott"), 0, {
                rotationZ: 0,
                x: 0,
                y: 0,
                opacity: 1,
            });
        },

        outOfPins: function() {
            this.gameOver = true;
            window.console.log("outofpins");
            //$("#lose").css("display", "inline-block");
            //$("#modal").fadeIn();
        },

        unlock: function() {
            this.gameOver = true;
            window.console.log("unlock");
            //$("#win").css("display", "inline-block");
            //$("#modal").fadeIn();
        },
        // UTIL
        clamp: function(val, max, min) {
            return Math.min(Math.max(val, min), max);
        },
        convertRanges: function(OldValue, OldMin, OldMax, NewMin, NewMax) {
            return ((OldValue - OldMin) * (NewMax - NewMin)) / (OldMax - OldMin) + NewMin;
        },
        // Events
        onMouseMove: function(e) {
            if (this.lastMousePos && !this.gameOver && !this.gamePaused) {
                var pinRotChange = (e.clientX - this.lastMousePos) / this.mouseSmoothing;
                this.pinRot += pinRotChange;
                this.pinRot = this.clamp(this.pinRot, this.maxRot, this.minRot);

                this.$refs.pin.style.transform = "rotateZ(" + this.pinRot + "deg)";
            }
            this.lastMousePos = e.clientX;
        },
        onMouseLeave: function() {
            this.lastMousePos = 0;
        },
        onMouseDown: function() {
            if (!this.userPushingCyl && !this.gameOver && !this.gamePaused) {
                this.pushCyl();
            }
        },
        onMouseUp: function() {
            if (!this.gameOver) {
                this.unpushCyl();
            }
        },
    },
    mounted: function() {
        window.console.log('mounted')
        //this.pin = this.$refs.pin;
        //this.cyl = this.$refs.cylinder;
        //this.driver = this.$refs.driver;
    },
};
</script>

<style>
@import url("https://fonts.googleapis.com/css?family=Lato:400,700,300,900");

html,
body {
    width: 100%;
    height: 100%;
    background: #000;
    padding: 0;
    margin: 0;
    font-family: "Lato", helvetica, arial, sans-serif;
}
body {
    background: url("https://s3-us-west-2.amazonaws.com/s.cdpn.io/95637/safeBG2.jpg");
    background-size: cover;
    display: inline-block;
    overflow: hidden;
}
#wrap {
    display: block;
    position: relative;
    width: 12%;
    margin: 5% auto;
    overflow: visible;
}
p {
    color: #fde470;
    color: #22ff22;
    text-align: center;
    font-weight: 400;
    font-size: 1.2em;
    padding: 0;
    margin: 0.5em;
}
.disclaimer {
    position: absolute;
    bottom: 0;
    left: 0;
    opacity: 0.5;
    font-size: 0.9em;
    color: #000;
    font-weight: 300;
}
#collar {
    display: block;
    position: relative;
    width: 100%;
    height: 100%;
}
#cylinder {
    display: block;
    background: url("https://s3-us-west-2.amazonaws.com/s.cdpn.io/95637/cylinder.png");
    background-size: cover;
    width: 69.914%;
    height: 69.914%;
    position: absolute;
    top: 14.9%;
    left: 15%;
}
#driver {
    display: block;
    width: 172.1739%;
    height: 84%;
    background: url("https://s3-us-west-2.amazonaws.com/s.cdpn.io/95637/driver.png");
    background-size: cover;
    position: absolute;
    top: 57%;
    left: 46%;
    transform-origin: 3% -3%;
}
#pin {
    display: block;
    background-size: cover;
    width: 7.1304%;
    height: 146.4347%;
    position: absolute;
    left: 47.4%;
    top: -98%;
    transform-origin: 50% 99%;
}
#pin .top {
    display: block;
    width: 100%;
    height: 50%;
    position: absolute;
    top: 0;
    left: 0;
    background: url("https://s3-us-west-2.amazonaws.com/s.cdpn.io/95637/pinTop.png");
    background-size: cover;
}
#pin .bott {
    display: block;
    width: 100%;
    height: 50%;
    position: absolute;
    top: 50%;
    left: 0;
    background: url("https://s3-us-west-2.amazonaws.com/s.cdpn.io/95637/pinBott.png");
    background-size: cover;
}

#modal {
    display: none;
    overflow: auto;
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0, 0, 0, 0.8);
    text-align: center;
}
#modal div {
    margin-top: 5%;
    display: inline-block;
    background: #fff;
    border-radius: 20px;
    box-sizing: border-box;
    padding: 1%;
}
#modal div h1 {
    margin-bottom: 0.22em;
}
#modal div h2 {
    margin-top: 0;
    margin-bottom: 1.5em;
    font-size: 1.4em;
}

#modal div h3 {
    font-size: 1.1em;
}
#modal div h4 {
    font-size: 0.8em;
}
#win {
    display: none;
}
#lose {
    display: none;
}
</style>
