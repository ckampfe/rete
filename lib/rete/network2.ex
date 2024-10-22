defmodule Rete.AlphaNode do
  defstruct [:field_to_test, :test, memory: [], children: []]
end

defmodule Rete.Network2 do
  alias Rete.AlphaNode

  defstruct [:hash_network]

  def new(rules) do
    %__MODULE__{hash_network: build_network(rules)}
  end

  def run(network, facts) do
    fact_lookups = Enum.map(facts, &to_lookup_path/1)

    hash_network =
      facts
      |> Enum.zip(fact_lookups)
      |> Enum.reduce(network.hash_network, fn {fact, lookup}, memories ->
        if Kernel.get_in(memories, lookup) do
          # IO.inspect(Kernel.get_in(memories, lookup), label: "GET IN")

          Kernel.update_in(memories, lookup, fn memory ->
            %{memory | memory: [fact | memory.memory]}
          end)
        else
          memories
        end
      end)

    %__MODULE__{hash_network: hash_network}
  end

  defp build_network(rules) do
    rules
    |> Enum.reduce(%{}, fn rule, memories ->
      adapt_memories_for_rule(memories, rule)
    end)
  end

  defp to_lookup_path({id, attribute, value}) do
    [
      field_to_lookup(id),
      field_to_lookup(attribute),
      field_to_lookup(value)
    ]
  end

  defp field_to_lookup(field) do
    case field do
      {:variable, _} ->
        :*

      # and now for the tricky bit
      #
      # if the actual field is there as a constant, use it
      # if not, try to see if there are :internal fns
      # iterate through the internal fns,
      # if one matches, use it
      # otherwise, return nil
      _ ->
        fn
          :get, data, next ->
            to_lookup =
              Map.get_lazy(data, field, fn ->
                case Map.fetch(data, {:internal, :fn}) do
                  {:ok, ids_and_nodes} ->
                    Enum.find_value(ids_and_nodes, fn {_node_id, node} ->
                      if node.test.(field) do
                        node
                      else
                        false
                      end
                    end)

                  :error ->
                    nil
                end
              end)

            next.(to_lookup)

          :get_and_update, data, next ->
            value =
              Map.get_lazy(data, field, fn ->
                case Map.fetch(data, {:internal, :fn}) do
                  {:ok, fns_and_nodes} ->
                    Enum.find_value(fns_and_nodes, fn {node_id, node} ->
                      if node.test.(field) do
                        {[{:internal, :fn}, node_id], node}
                      else
                        false
                      end
                    end)

                  :error ->
                    nil
                end
              end)

            case value do
              {[{:internal, :fn}, node_id], node} ->
                internal_fn_nodes = Map.get(data, {:internal, :fn})

                case next.(node) do
                  {get, update} -> {get, Map.put(internal_fn_nodes, node_id, update)}
                  :pop -> {value, Map.delete(data, field)}
                end

              _ ->
                case next.(value) do
                  {get, update} -> {get, Map.put(data, field, update)}
                  :pop -> {value, Map.delete(data, field)}
                end
            end
        end
    end
  end

  defp to_insert_path({id, attribute, value}) do
    [
      field_to_insert(id),
      field_to_insert(attribute),
      field_to_insert(value)
    ]
    |> Enum.concat()
  end

  defp field_to_insert(field) do
    case field do
      {:variable, _} -> [:*]
      field when is_function(field) -> [{:internal, :fn}, :erlang.phash2(field)]
      _ -> [field]
    end
  end

  defp adapt_memories_for_rule(map, rule) do
    possible_keys = to_insert_path(rule)
    put_or_update_lazy(map, rule, possible_keys, %AlphaNode{})
  end

  defp put_or_update_lazy(map, rule, keys, terminal_value) do
    put_or_update_lazy_loop(map, rule, keys, terminal_value)
  end

  defp put_or_update_lazy_loop(map, _rule, [], _terminal_value) do
    map
  end

  defp put_or_update_lazy_loop(map, {_id, _attribute, value}, [final_key], terminal_value) do
    Map.put(map, final_key, %{terminal_value | test: value, field_to_test: :value})
  end

  defp put_or_update_lazy_loop(map, rule, [key | keys], terminal_value) do
    case Map.fetch(map, key) do
      {:ok, inner} ->
        Map.update!(map, key, fn _ ->
          put_or_update_lazy_loop(inner, rule, keys, terminal_value)
        end)

      :error ->
        Map.put(map, key, put_or_update_lazy_loop(%{}, rule, keys, terminal_value))
    end
  end
end
