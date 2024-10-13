defmodule Rete.AlphaMemory do
  defstruct facts: [], children: [], condition: nil

  def new() do
    %__MODULE__{}
  end
end
