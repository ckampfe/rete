defmodule Rete.NodeServer do
  use GenServer

  defstruct condition: :none,
            test: nil,
            comparing: nil,
            alpha_memory: [],
            children: [],
            conditions_this_node_cares_about: [],
            logical_parent: nil

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  @impl GenServer
  def init(args) do
    {:ok, %__MODULE__{condition: args[:condition]}}
  end
end
