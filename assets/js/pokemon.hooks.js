const BATTLE_SOUND = "/sounds/pokemon_battle.mp3";
const DRAW_ANIMATION_DURATION = 1300; // Duration of shake animation (CSS)
const LOSER_HIDE_DELAY = 2000;
const WINNER_ANIMATION_START = 2500;

const PokemonBattle = {
  battleData: null,
  battleSound: null,
  mounted() {
    // Music starts when countdown begins
    this.handleEvent("battle:countdown_start", (payload) => {
      this.battleSound = this.playSound(BATTLE_SOUND, 5);
    });

    // Animations when countdown finishes
    this.handleEvent("battle:start", (payload) => {
      this.battleData = payload;
      // Start animations automatically
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
      }, LOSER_HIDE_DELAY);
      // set animation for winner
      setTimeout(() => {
        this.applyBattleAnimation(this.battleData.winner, "winner-animation");
      }, WINNER_ANIMATION_START);
    }
  },
};

export default PokemonBattle;
