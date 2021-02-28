<template>
    <div id="container" @click="$refs.cmd.focus()">
        <div id="terminal" ref="terminal">
            <div id="inner">
                <output ref="output"></output>
                <div id="input-line" class="input-line">
                    <div class="prompt">
                        <div>&gt;</div>
                    </div>

                    <input
                        v-model="value"
                        ref="cmd"
                        @keydown.enter="onInput($event)"
                        @keydown.up="history_up()"
                        @keydown.down="history_down()"
                        @keydown.tab="onTab($event)"
                        class="cmdline"
                        autofocus="true"
                        spellcheck="false"
                    />
                </div>
            </div>
        </div>
    </div>
</template>

<script>
export default {
    name: "Computer",
    data: function() {
        return {
            value: "",
            history: [],
            history_pos: 0,
            history_temp: 0,
            commands: [
                { name: "info", desc: "Important survival instructions. READ THIS!!"},
                { name: "activate", desc: "Activate satellite communications.  DON'T DO THIS!!"},
                { name: "clear", desc: "Clear the terminal of all output" },
                { name: "exit", desc: "Exit this terminal" },
            ],
        };
    },
    methods: {
        onTab(e) {
            e.preventDefault();
        },
        onInput: function() {
            if (this.value) {
                this.history[this.history.length] = this.value;
                this.history_pos = this.history.length;
            }

            //   Duplicate current input and append to output section.
            var line = this.$refs.cmd.parentNode.cloneNode(true);
            line.removeAttribute("id");
            line.classList.add("line");
            var input = line.querySelector("input.cmdline");
            input.autofocus = false;
            input.readOnly = true;
            this.$refs.output.appendChild(line);

            if (this.value && this.value.trim()) {
                var args = this.value.split(" ").filter(function(val) {
                    return val;
                });
                var cmd = args[0].toLowerCase();
                args = args.splice(1);
            } else {
                // no command given
                this.value = "";
                this.scrollToEnd();
                return;
            }

            window.console.log(cmd);
            window.console.log(args);

            switch (cmd) {
                case "clear":
                    this.$refs.output.innerHTML = "";
                    break;
                case "help":
                case "?":
                    var commandsList = this.commands.map(({ name, desc }) => {
                        if (desc) {
                            return `<dt><b>${name}</b></dt><dd>${desc}</dd>`;
                        }
                        return name;
                    });
                    this.sendOutput(commandsList.join("<br />"));
                    break;
                case "activate":
                    this.CallEvent("ActivateSatellite");
                    this.sendOutput(`
                    <p>
                        Commencing satellite transmission... OK<br />
                        Waiting for signal acknowledgement... OK
                    </p>

                    <p>Signal received. Standby for response...</p>`)
                    break;
                case "info":
                    this.sendOutput(`
                    <p>READ THESE INSTRUCTIONS CAREFULLY!</p>

                    <p>
                        The surrounding area has been invaded by alien lifeform.
                        If you are reading this message, you may be the last of
                        the remaining human survivors. Follow these rules to
                        stay alive:
                    </p>

                    <ul>
                        <li>
                            This house and it's perimeter is a SAFE ZONE from
                            aliens.  We are not sure why.  However if the mothership
                            is nearby, there is no safe zone.
                        </li>

                        <li>
                            The mainland has been infected with radiation. DO
                            NOT ENTER THE OCEAN!
                        </li>

                        <li>
                            THERE ARE ALIENS ON THIS ISLAND! If you are being
                            chased, RUN TO SAFETY UNLESS YOU ARE ARMED!
                        </li>

                        <li>
                            WATCH FOR SUPPLY DROPS! They contain armor, health,
                            and weapons. You will see flares indicating where
                            they drop. You can also craft supplies from scrap
                            parts found on the island using the workbench in the
                            garage.
                        </li>

                        <li>
                            THE SATELLITE TERMINAL IS A DIRECT LINK TO THE MOTHERSHIP.
                            But you will need supplies before you can fight back! 
                            If you are unable to fight, running away is your best chance for
                            survival.
                        </li>
                    </ul>

                    <p>Good luck!</p>`)
                    break;
                case "exit":
                    this.CallEvent("ExitComputer");
                    this.sendOutput('Logging out...');
                    break;
                default:
                    this.sendOutput(`${cmd}: Command not found.  Type 'help' for commands.`);
            }
            this.value = "";
            this.scrollToEnd();
        },
        sendOutput(html) {
            this.$refs.output.insertAdjacentHTML("beforeEnd", "<p>" + html + "</p>");
        },
        history_up() {
            if (this.history.length) {
                if (this.history[this.history_pos]) {
                    this.history[this.history_pos] = this.value;
                } else {
                    this.history_temp = this.value;
                }
            }
            // up 38
            this.history_pos--;
            if (this.history_pos < 0) {
                this.history_pos = 0;
            }
            this.value = this.history[this.history_pos] ? this.history[this.history_pos] : this.history_temp;
        },
        history_down() {
            if (this.history.length) {
                if (this.history[this.history_pos]) {
                    this.history[this.history_pos] = this.value;
                } else {
                    this.history_temp = this.value;
                }
            }
            this.history_pos++;
            if (this.history_pos > this.history.length) {
                this.history_pos = this.history.length;
            }
            this.value = this.history[this.history_pos] ? this.history[this.history_pos] : this.history_temp;
        },
        scrollToEnd: function() {    	
            var container = this.$el.querySelector("#inner");
            container.scrollTop = container.scrollHeight;
        },
    },
    mounted: function() {
        this.$refs.cmd.focus();
        this.sendOutput(`
            %DECW-W-NODEVICE, No graphics device found on this system<br />
            %SET-I-INTSET, login interactive limit = 64<br /><br />
            %%%%%%%%% OPCOM ${new Date().toDateString()} %%%%%%%%%<br />
            <b>Message from user DECNET:</b><br />
            <em>Greetings survivor, we've left instruction documents in this terminal.
            Type 'info' command to access them or 'help' for other options.</em>
            <br /><br />
            ********************** IMPORTANT EMERGENCY INFORMATION
            *************************<br />
            ***************************** AUTHORIZED USE ONLY
            ******************************<br /><br />
            Login successful.`)
    },
};
</script>

<style scoped>
#container {
    display: flex;
    justify-content: center;
    flex-direction: column;
    align-items: center;
}
#terminal {
    width: 800px;
    background-color: black;
    background-image: radial-gradient(rgba(0, 150, 0, 0.75), black 120%);
    border-radius: 25px;
    border: 2px solid #73ad21;
    box-shadow: 5px 5px 15px #000;
    color: white;
    font: 1.1rem Inconsolata, monospace;
    text-shadow: 0 0 5px #304b0c;
    padding: 20px 20px;
    margin-top: 50px;
}
#inner {
    height:500px;
    overflow-x:hidden;
    overflow-y:auto;
}
.input-line {
    display: flex;
    box-orient: horizontal;
    box-align: stretch;
    clear: both;
}
.input-line > div:nth-child(2) {
    box-flex: 1;
}
.prompt {
    white-space: nowrap;
    color: #3a8b17;
    margin-right: 7px;
    display: flex;
    box-pack: center;
    box-orient: vertical;
    user-select: none;
}
.cmdline {
    outline: none;
    background-color: transparent;
    margin: 0;
    width: 100%;
    font: inherit;
    border: none;
    color: inherit;
}

*::-webkit-scrollbar {
  width: 16px;
}

*::-webkit-scrollbar-track {
  background: #1d4d09;
  border-radius: 20px;
}

*::-webkit-scrollbar-thumb {
  background-color: #ffffff;
  border-radius: 20px;
  border: 1px solid #1d4d09;
}
</style>
