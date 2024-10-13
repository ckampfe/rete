defmodule Rete.Sigils do
  def sigil_v(string, []) do
    {:variable, string}
  end

  def is_variable?({:variable, _}), do: true
  def is_variable?(_), do: false
end
