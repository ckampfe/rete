defmodule Rete.Network do
  alias Rete.AlphaMemory
  import Rete.Sigils

  defstruct [:alpha_memories]

  def new(rules) do
    alpha_memories =
      rules
      |> Enum.reduce(%{}, fn rule, memories ->
        adapt_memories_for_rule(memories, rule)
      end)

    %__MODULE__{alpha_memories: alpha_memories}
  end

  def run(network, facts) do
    fact_lookups = Enum.map(facts, &fact_to_lookup_path/1)

    alpha_memories =
      facts
      |> Enum.zip(fact_lookups)
      |> Enum.reduce(network.alpha_memories, fn {fact, lookup}, memories ->
        # this works for constants only:
        #
        if Kernel.get_in(memories, lookup) do
          Kernel.update_in(memories, lookup, fn memory ->
            %{memory | facts: [fact | memory.facts]}
          end)
        else
          memories
        end
      end)

    %{network | alpha_memories: alpha_memories}
  end

  # defp update_in_loop(memories, [key | keys], fact) do
  #   case Map.fetch(memories, key) do
  #     {:ok, m} when is_map(m) ->
  #       update_in_loop(memories, keys, fact)

  #     {:ok, %Rete.AlphaMemory{condition: condition, children: children} = mem} ->
  #       if condition.(fact) do
  #         if Enum.empty?(children) do
  #           %{mem | facts: [fact | mem.facts]}
  #         else
  #           raise "todo"
  #         end
  #       else
  #       end

  #     :error ->
  #       nil
  #   end
  # end

  defp fact_to_lookup_path({id, attribute, value}) do
    [
      if is_variable?(id) do
        :*
      else
        id
      end,
      if is_variable?(attribute) do
        :*
      else
        attribute
      end,
      if is_variable?(value) do
        :*
      else
        value
      end
    ]
  end

  # todo generate code to handle builtins
  defp is_builtin_fn(item) do
    match?({:in, _}, item) ||
      match?({:>, _}, item) ||
      match?({:<, _}, item) ||
      match?({:>=, _}, item) ||
      match?({:<=, _}, item)
  end

  defp generate_lookup_permutations_for_rule({id, attribute, value}) do
    if Enum.any?([id, attribute, value], &is_builtin_fn/1) do
      [
        case id do
          {:variable, _} -> :*
          _ -> id
        end,
        case attribute do
          {:variable, _} -> :*
          _ -> attribute
        end,
        case value do
          {:variable, _} -> :*
          _ -> value
        end
      ]
    else
      [
        case id do
          {:variable, _} -> :*
          _ -> id
        end,
        case attribute do
          {:variable, _} -> :*
          _ -> attribute
        end,
        case value do
          {:variable, _} -> :*
          _ -> value
        end
      ]
    end
  end

  defp put_or_update_lazy(map, keys, terminal_value) do
    put_or_update_lazy_loop(map, keys, terminal_value)
  end

  # defp put_or_update_lazy_loop(map, [final_key], terminal_value) do
  #   Map.put(map, final_key, terminal_value)
  # end

  # defp put_or_update_lazy_loop(map, [key | keys], terminal_value) do
  #   # case Map.fetch(map, key) do
  #   #   {:ok, m} ->
  #   #     Map.update!(map, key, fn v ->
  #   #       put_or_update_lazy_loop(v, keys, terminal_value)
  #   #     end)

  #   #   :error ->
  #   #     %{key => put_or_update_lazy_loop(%{}, keys, terminal_value)}
  #   # end
  #   if Map.has_key?(map, key) do
  #     put_or_update_lazy_loop(Map.fetch!(map, key), keys, terminal_value)
  #   else
  #     map = Map.put(map, key, %{})
  #     put_or_update_lazy_loop(Map.fetch!(map, key), keys, terminal_value)
  #   end
  # end
  defp put_or_update_lazy_loop(map, [], _terminal_value) do
    map
  end

  defp put_or_update_lazy_loop(map, [final_key], terminal_value) do
    Map.put(map, final_key, terminal_value)
  end

  defp put_or_update_lazy_loop(map, [key | keys], terminal_value) do
    case Map.fetch(map, key) do
      {:ok, inner} ->
        Map.update!(map, key, fn _ ->
          put_or_update_lazy_loop(inner, keys, terminal_value)
        end)

      :error ->
        Map.put(map, key, put_or_update_lazy_loop(%{}, keys, terminal_value))
    end
  end

  defp adapt_memories_for_rule(map, rule) do
    Kernel.put_in(%{}, [:a], 1)
    possible_keys = generate_lookup_permutations_for_rule(rule)
    put_or_update_lazy(map, possible_keys, AlphaMemory.new())
  end
end
