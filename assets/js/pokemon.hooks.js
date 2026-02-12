const PokemonBattle = {
  mounted() {
    this.handleEvent("battle:start", (payload) => {
      console.log(payload);
    });
  },
};

export default PokemonBattle;
