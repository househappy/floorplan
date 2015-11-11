defmodule Floorplan.FileCounter do
  @docmodule """
  Tracks total sitemap file count
  """

  use GenServer

  ## Client API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def increment do
    GenServer.call(__MODULE__, :increment)
  end

  def reset do
    GenServer.call(__MODULE__, :reset)
  end

  ## Server Callbacks

  def init(:ok) do
    {:ok, 1}
  end

  def handle_call(:increment, _from, total) do
    {:reply, total, total + 1}
  end

  def handle_call(:reset, _from, _total) do
    {:reply, 0, 1}
  end
end
