defmodule Floorplan.Queue do
  @docmodule """
  Takes UrlLink structs and keeps them in queue.
  Once queue size reaches limit (default 49_900) is reached, flush
  to FileWriter
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
  Pushes a UrlLink struct onto queue
  """
  def push(urllink) do
    GenServer.cast(__MODULE__, {:push, urllink})
  end

  @doc """
  Fetches full queue
  """
  def fetch do
    GenServer.call(__MODULE__, :fetch)
  end

  @doc """
  Notify queue there are no more results and to flush before max size,
  triggering IndexBuilder task
  """
  def done do
    GenServer.call(__MODULE__, :done, 60_000)
  end


  ## Server Callbacks

  def init(:ok) do
    {:ok, []}
  end

  def handle_call({:replace_queue, new_queue}, _from, _queue) do
    {:reply, :ok, new_queue}
  end
  def handle_call(:fetch, _from, queue) do
    {:reply, queue, queue}
  end
  def handle_call(:done, _from, queue) do
    Floorplan.FileBuilder.build(queue, true)
    {:reply, :ok, []}
  end

  def handle_cast({:push, struct}, queue), do: handle_cast({:push, struct, nil}, queue)
  def handle_cast({:push, struct, reply_pid}, queue) do
    if Dict.size(queue) >= Floorplan.config.queue_size do
      build_file(queue, reply_pid)

      {:noreply, [struct]}
    else
      {:noreply, [struct|queue]}
    end
  end

  @doc """
  Trigger a FileBuilder process to dump enqueued urls
  """
  def build_file(queue, reply_pid) do
    task = Task.async(fn -> Floorplan.FileBuilder.build(queue) end)
    # notify any listener build_file task has executed
    if reply_pid, do: send(reply_pid, {:build_file_start, task})
  end
end
