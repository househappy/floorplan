defmodule Floorplan.FileList do
  @docmodule """
  Maintains a list of sitemap files and their completion state
  """

  use GenServer

  ## Client API

  @doc """
  Starts the queue
  """
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @doc """
  Replace queue with passed list
  """
  def replace_queue(new_queue) do
    GenServer.call(__MODULE__, {:replace_queue, new_queue})
  end

  @doc """
  Pushes a Path and its state onto queue

  iex> GenServer.cast(FileList, {:push, {"tmp/sitemap1.xml", :completed}})
  """
  def push(file_with_status) do
    GenServer.cast(__MODULE__, {:push, file_with_status})
  end

  @doc """
  Fetch files by status.
  Accepts :all, :completed, or :failed

  iex> GenServer.cast(FileList, {:fetch, :completed})
  """
  def fetch(status) do
    GenServer.call(__MODULE__, {:fetch, status})
  end

  ## Server callbacks

  def init(:ok) do
    {:ok, []}
  end

  def handle_call({:fetch, status}, _from, queue) do
    files = Enum.filter(queue, fn(file) ->
      {_filename, file_status} = file
      status == :all || file_status == status
    end)
    {:reply, files, files}
  end
  def handle_call({:replace_queue, new_queue}, _from, _queue) do
    {:reply, :ok, new_queue}
  end

  def handle_cast({:push, file_with_status}, file_list) do
    {:noreply, [file_with_status|file_list]}
  end
end