defmodule Rete.Syntax do
  @doc """
  defrule porsche_exclusions(
    make: "porsche",
    models: ["cayenne", "911 gt3rs", "panamera"]
  ) do
    :exclude
  end
  """
  defmacro defrule(name, rule, do: action) do
    id = :erlang.unique_integer()

    conditions =
      to_conditions(id, rule)

    quote do
      unquote(conditions)
    end
  end

  def to_conditions(id, rule) do
    Enum.map(rule, fn {attribute, value} ->
      value =
        case value do
          value when is_function(value) ->
            quote do
              value
            end

          value ->
            value
        end

      quote do: {unquote({:variable, id}), unquote(attribute), unquote(value)}
    end)
  end
end
