defmodule ReteTest do
  use ExUnit.Case
  doctest Rete
  import Rete.Sigils
  alias Rete.Network2

  test "greets the world" do
    assert Rete.hello() == :world
  end

  test "alpha" do
    rules = [
      {~v<x>, :on, ~v<y>},
      {~v<y>, :left_of, ~v<z>},
      {~v<z>, :color, :red},
      {~v<a>, :color, :maize},
      {~v<b>, :color, :blue},
      {~v<c>, :color, :green},
      {~v<d>, :color, :white},
      {~v<s>, :on, :table},
      {~v<y>, ~v<a>, ~v<b>},
      {~v<a>, :left_of, ~v<d>},
      {~v<g>, :color, fn color -> color in [:pink, :yellow, :black] end},
      {~v<h>, :size, fn size -> size > 30 end},
      {~v<e>, :size, 29}
      #
      # {~v<anything>, :color, {:in, [:yellow, :black, :pink]}}
    ]

    network = Network2.new(rules) |> IO.inspect(label: "with rules")

    facts = [
      {~v<B1>, :on, ~v<B2>},
      {~v<B1>, :on, ~v<B3>},
      {~v<B1>, :color, :red},
      {~v<B2>, :on, :table},
      {~v<B2>, :left_of, ~v<B3>},
      {~v<B2>, :color, :blue},
      {~v<B3>, :left_of, ~v<B4>},
      {~v<B3>, :on, :table},
      {~v<B3>, :color, :red},
      #
      {~v<B4>, :color, :pink},
      {~v<B8>, :color, :yellow},
      {~v<B8>, :size, 10},
      {~v<B8>, :size, 70}
    ]

    Network2.run(network, facts) |> IO.inspect(label: "after adding facts")
  end
end
