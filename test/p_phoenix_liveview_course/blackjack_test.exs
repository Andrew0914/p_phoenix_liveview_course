defmodule PPhoenixLiveviewCourse.BlackjackTest do
  use ExUnit.Case

  # Simulamos la lógica de blackjack para probar escenarios (Logica)

  defp determine_winner(player, cpu, winning_value) do
    cond do
      player > winning_value -> :cpu
      cpu > winning_value -> :player
      player == cpu -> :tie
      player > cpu -> :player
      true -> :cpu
    end
  end

  test "player busts and cpu wins" do
    assert determine_winner(22, 18, 21) == :cpu
  end

  test "cpu busts and player wins" do
    assert determine_winner(18, 22, 21) == :player
  end

  test "tie when equal scores" do
    assert determine_winner(19, 19, 21) == :tie
  end

  test "higher score wins if no one busts" do
    assert determine_winner(20, 18, 21) == :player
  end
end
