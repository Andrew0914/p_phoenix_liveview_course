const BATTLE_SOUND = "/sounds/pokemon_battle.mp3";
const PokemonBattle = {
    battleData: null,
    battleSound: null,
    mounted() {
        this.handleEvent("battle:start", (payload) => {
            this.battleData = payload;
            this.battleSound = this.playSound(BATTLE_SOUND, 5);

            this.battle();
        });
    },
    playSound(src, duration) {
        const audio = new Audio(src);
        audio.duration = duration;
        audio.play();
        return audio;
    },
    applyBattleAnimation(player, animation) {
        console.log(player);
        const id = player.player + "-pokemon";
        this.el.querySelector(`#${id}`).classList.add(animation);
        this.playSound(
            `/sounds/${player.pokemon.name.toLowerCase()}_cry.mp3`,
            2,
        );
    },
    battle() {
        // stop battle sound
        if (this.battleSound) this.battleSound.pause();

        // when Draw
        if (this.battleData.status == "draw") {
            this.el.classList.add("draw-animation");
        } else {
            // when there is a winner

            this.applyBattleAnimation(this.battleData.loser, "loser-animation");
            // hide loser
            setTimeout(() => {
                const loserId = this.battleData.loser.player + "-pokemon";
                this.querySelector(`#${loserId}`).style.display = "none";
            }, 2000);

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
