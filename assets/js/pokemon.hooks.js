const BATTLE_SOUND = "/sounds/pokemon_battle.mp3";
const PokemonBattle = {
  battleData: null,
  battleSound: null,
  mounted() {
    this.handleEvent("battle:start", (payload) => {
      this.battleData = payload;
      this.battleSound = this.playSound(BATTLE_SOUND, 5);
    });
  },
  playSound(src, duration) {
    const audio = new Audio(src);
    audio.duration = duration;
    audio.play();
    return audio;
  },
};

export default PokemonBattle;
