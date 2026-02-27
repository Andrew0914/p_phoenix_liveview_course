const BATTLE_SOUND = "/sounds/pokemon_battle.mp3";
const PokemonBattle = {
  battleData: null,
  battleSound: null,
  mounted() {
    // server event
    this.handleEvent("battle:start", (payload) => {
      this.battleData = payload;
    });
  },
  updated() {
    // client event
    const battleButton = document.getElementById("battle-button");
    battleButton?.removeEventListener("click", () => {
      this.battle();
    });
    battleButton?.addEventListener("click", () => {
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
    const id = player.id + "-pokemon";
    this.el.querySelector(`#${id}`).classList.add(animation);
    this.playSound(`/sounds/${player.pokemon.name.toLowerCase()}_cry.mp3`, 2);
  },
  battle() {
    this.battleSound = this.playSound(BATTLE_SOUND, 5);

    let countdown = 3;
    const countdownEl = document.createElement("div");
    countdownEl.classList.add("countdown");
    this.el.appendChild(countdownEl);

    const interval = setInterval(() => {
      countdownEl.textContent = countdown;
      countdown--;
      if (countdown < 0) {
        clearInterval(interval);
        countdownEl.remove();
        this.runBattle(); // 👉 aquí se ejecuta la batalla original
      }
    }, 1000);
  },

  runBattle() {
    if (this.battleData.status == "draw") {
      this.el.classList.add("draw-animation");
      setTimeout(() => {
        this.pushEvent("battle_finished", {});
      }, 1500);
    } else {
      this.applyBattleAnimation(this.battleData.loser, "loser-animation");
      setTimeout(() => {
        const loserId = this.battleData.loser.id + "-pokemon";
        this.el.querySelector(`#${loserId}`).style.display = "none";
      }, 2000);
      setTimeout(() => {
        this.applyBattleAnimation(this.battleData.winner, "winner-animation");
        // 👉 aquí avisamos al servidor que ya terminó
        this.pushEvent("battle_finished", {});
      }, 3000);
    }
  }
  ,
};

export default PokemonBattle;
