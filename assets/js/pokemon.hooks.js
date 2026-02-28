const BATTLE_SOUND = "/sounds/pokemon_battle.mp3";
const PokemonBattle = {
    battleData: null,
    battleSound: null,
    countdown: 3,
    countdownInterval: null,
    mounted() {
        // server event
        this.handleEvent("battle:start", (payload) => {
            this.battleData = payload;
            this.battleSound = this.playSound(BATTLE_SOUND, 5);
        });
    },
    updated() {
        // client event
        const battleButton = document.getElementById("battle-button");
        battleButton?.removeEventListener("click", () => {
            this.startCountdown();
        });
        battleButton?.addEventListener("click", () => {
            this.startCountdown();
        });
    },
    playSound(src, duration) {
        const audio = new Audio(src);
        audio.duration = duration;
        audio.play();
        return audio;
    },
    applyBattleAnimation(player, animation) {
        const id = player.id + "-pokemon";
        this.el.querySelector(`#${id}`).classList.add(animation);
        this.playSound(
            `/sounds/${player.pokemon.name.toLowerCase()}_cry.mp3`,
            2,
        );
    },
    startCountdown() {
        // Reset countdown to 3
        this.countdown = 3;

        // Clear prev countdown if exists
        const existingCountdown = document.getElementById(
            "countdown-container",
        );
        if (existingCountdown) {
            existingCountdown.remove();
            clearInterval(this.countdownInterval);
        }

        const countdownContainer = document.createElement("div");
        countdownContainer.id = "countdown-container";
        countdownContainer.className = "countdown-container";

        const countdownLabel = document.createElement("span");
        countdownLabel.className = "countdown-label";
        countdownLabel.textContent = "Battle finalize in: ";

        const countdownDisplay = document.createElement("span");
        countdownDisplay.id = "countdown-display";
        countdownDisplay.className = "countdown-display";
        countdownDisplay.textContent = this.countdown;

        countdownContainer.appendChild(countdownLabel);
        countdownContainer.appendChild(countdownDisplay);
        this.el.appendChild(countdownContainer);

        this.countdownInterval = setInterval(() => {
            this.countdown--;
            countdownDisplay.textContent = this.countdown;

            if (this.countdown <= 0) {
                clearInterval(this.countdownInterval);
                countdownContainer.remove();

                this.battle();
            }
        }, 1000);
    },
    battle() {
        // stop battle sound
        if (this.battleSound) this.battleSound.pause();
        // when Draw
        if (this.battleData.status == "draw") {
            this.el.classList.add("draw-animation");
        } else {
            // set animation for loser first
            this.applyBattleAnimation(this.battleData.loser, "loser-animation");
            // hide loser
            setTimeout(() => {
                const loserId = this.battleData.loser.id + "-pokemon";
                this.el.querySelector(`#${loserId}`).style.display = "none";
            }, 2000);
            // set animation for winner
            setTimeout(() => {
                this.applyBattleAnimation(
                    this.battleData.winner,
                    "winner-animation",
                );
            }, 2500);
        }
    },
};

export default PokemonBattle;
