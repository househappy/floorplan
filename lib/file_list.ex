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
  """
  def push(file) do
    GenServer.cast(__MODULE__, {:push, file})
  end

  @doc """
  Swaps a file by filename with a new state
  """
  def replace(old_filename, new_state) do
    GenServer.cast(__MODULE__, {:replace, old_filename, new_state})
  end

  @doc """
  Fetch files by status.
  Accepts :all, :completed, or :failed

  iex> GenServer.cast(FileList, {:fetch, :completed})
  """
  def fetch(status) do
    GenServer.call(__MODULE__, {:fetch, status})
  end

  @doc """
  Returns true if no files w/ :in_progress status

  iex> GenServer.cast(FileList, {:fetch, :completed})
  """
  def done? do
    GenServer.call(__MODULE__, :done?)
  end

  ## Server callbacks

  def init(:ok) do
    {:ok, []}
  end

  def handle_call({:fetch, status}, _from, queue) do
    files = Enum.filter(queue, fn(file_state) ->
      {_filename, file_status, _link_count} = file_state
      status == :all || file_status == status
    end)
    {:reply, files, files}
  end

  def handle_call({:replace_queue, new_queue}, _from, _queue) do
    {:reply, :ok, new_queue}
  end

  @doc """
  Returns boolean if :in_progress jobs are empty

  iex> GenServer.call(FileList, :done?)
  """
  def handle_call(:done?, _from, queue) do
    none_in_progress? = Enum.all?(queue, fn({_, state, _})->
      :in_progress != state
    end)
    {:reply, none_in_progress?, queue}
  end

  @doc """
  Pushes a Path and its state onto queue

  iex> GenServer.cast(FileList, {:push, {"tmp/sitemap1.xml", :completed, 12}})
  """
  def handle_cast({:push, file_state}, file_list) do
    {:noreply, [file_state|file_list]}
  end

  @doc """
  Swaps a file by filename with a new state

  iex> GenServer.cast(FileList, {:replace, "tmp/sitemap1.xml", {"tmp/sitemap1.xml.gz", :completed, 12}})
  """
  def handle_cast({:replace, old_filename, new_state}, old_files) do
    matching_files = Enum.group_by(old_files, fn({filename, _, _}) -> filename == old_filename end)
    unchanged_files = Dict.get(matching_files, false) || []
    queue = [new_state|unchanged_files]
    {:noreply, queue}
  end
end

