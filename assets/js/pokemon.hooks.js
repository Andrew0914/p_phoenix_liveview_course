const BATTLE_SOUND = "/sounds/pokemon_battle.mp3";
const PokemonBattle = {
  battleData: null,
  battleSound: null,
  mounted() {
    this.handleEvent("battle:start", (payload) => {
      this.battleData = payload;
      this.battleSound = this.playSound(BATTLE_SOUND, 5);
      
      // Wait for LiveView to finish rendering the results in the DOM
      // before starting the animations
      setTimeout(() => {
        this.battle();
      }, 100); 
    });
  },
  playSound(src, duration) {
    const audio = new Audio(src);
    audio.play();
    return audio;
  },
  applyBattleAnimation(player, animation) {
    const id = `${player.id}-pokemon`;
    const el = document.getElementById(id); // Use global search if this.el fails
    if (el) {
      el.classList.add(animation);
      this.playSound(`/sounds/${player.pokemon.name.toLowerCase()}_cry.mp3`, 2);
    }
  },
  battle() {
    if (!this.battleData) return;

    if (this.battleData.status === "draw") {
      this.el.classList.add("draw-animation");
    } else {
      // Loser animation
      this.applyBattleAnimation(this.battleData.loser, "loser-animation");
      
      setTimeout(() => {
        const loserId = `${this.battleData.loser.id}-pokemon`;
        const loserEl = document.getElementById(loserId);
        if (loserEl) loserEl.style.opacity = "0"; // Using opacity instead of display to avoid layout jumps
      }, 2000);

      // Winner animation
      setTimeout(() => {
        this.applyBattleAnimation(this.battleData.winner, "winner-animation");
      }, 2500);
    }
  },
};

export default PokemonBattle;