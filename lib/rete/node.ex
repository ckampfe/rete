defmodule Rete.Node do
  # defstruct condition: :none,
  #           test: nil,
  #           comparing: nil,
  #           alpha_memory: [],
  #           children: [],
  #           conditions_this_node_cares_about: []

  # def new(condition) do
  #   %__MODULE__{condition: condition}
  # end

  # # are we comparing the attributes?
  # # this is a constant equality test
  # def new({_, test_attribute, _} = condition, :attribute) do
  #   %__MODULE__{
  #     condition: condition,
  #     comparing: :attribute,
  #     test: fn {_, challenge_attribute, _} ->
  #       test_attribute == challenge_attribute
  #     end
  #   }
  # end

  # # are we comparing the values?
  # # this is not necessarily a constant equality test, though it can be
  # def new({_, test_attribute, test_value} = condition, :value) do
  #   %__MODULE__{
  #     condition: condition,
  #     comparing: :value,
  #     test: fn {_, _challenge_attribute, challenge_value} ->
  #       case test_attribute do
  #         := -> test_value == challenge_value
  #         :> -> test_value > challenge_value
  #         :< -> test_value < challenge_value
  #         :>= -> test_value >= challenge_value
  #         :<= -> test_value <= challenge_value
  #         :!= -> test_value != challenge_value
  #       end
  #     end
  #   }
  # end

  # def try_add_fact(%__MODULE__{} = node, {_id, _attribute, _value} = fact) do
  # end

  # def try_add_child_condition(
  #       %__MODULE__{} = node,
  #       {_id, new_attribute, new_value} = condition
  #     ) do
  #   case {node.comparing, node.condition} do
  #     {:attribute, {_, this_attribute, _}} when this_attribute == new_attribute ->
  #       new_node = new(condition, :value)
  #       %{node | children: [new_node | node.children]}

  #     {:attribute, {_, this_attribute, _}} when this_attribute == new_attribute ->
  #       new_node = new(condition, :attribute)

  #     # :value ->
  #     #   nil

  #     # {_, ^new_attribute, different_value} when different_value != new_value ->
  #     #   %{
  #     #     node
  #     #     | children: [new(condition)],
  #     #       conditions_this_node_cares_about: [condition | node.conditions_this_node_cares_about]
  #     #   }

  #     # {_, _, ^new_value} ->
  #     #   nil

  #     # _ ->
  #     #   node
  #     _ ->
  #       node
  #   end
  # end
end
