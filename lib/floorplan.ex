require Logger

defmodule Floorplan do
  @moduledoc """
  Primary interface for generating a sitemap
  """

  alias Floorplan.FileList
  alias Floorplan.Queue

  @config %{
    base_url: Application.get_env(:floorplan, :base_url),
    queue_size: Application.get_env(:floorplan, :queue_size) || 49_900
  }
  def config, do: @config

  @doc """
  takes the target location for the sitemap index and a collection of
  `link_sources`. `link_sources` can be either a stream or enum.

  ## Examples
    iex> link_source = [ %Floorplan.UrlLink{} ]
    ...>Floorplan.generate("/tmp/sitemap.xml", link_source)
      Generated sitemap to destination: '/tmp'
      ✓ tmp/sitemap.xml.gz  -- 1 urls
      ✓ tmp/sitemap1.xml.gz  -- 1 urls
      Elapsed time: 10.533 milliseconds
    {:ok, [{"/tmp/sitemap.xml.gz", :completed}, {"/tmp/sitemap1.xml.gz", :completed}]}
  """
  def generate(index_name, link_sources) do
    Path.dirname(index_name) |> ensure_writeable_destination!
    Logger.info "Generating sitemap in destination: '#{Path.dirname(Path.absname(index_name))}'"

    start_time = Timex.Time.now

    link_sources
    |> Stream.map(&Queue.push/1)
    |> Stream.run

    notify_stream_finished

    completed?

    Floorplan.IndexBuilder.generate(index_name)

    file_list = FileList.fetch(:all)
    execution_time = Timex.Time.diff(Timex.Time.now, start_time) |> Timex.Format.Time.Formatter.format(:humanized)
    Logger.info "Elapsed time: #{execution_time}"

    {:ok, file_list}
  end

  @doc """
  Notify the queue the stream is finished and should be dumped to file before
  max queue size has been reached.
  """
  def notify_stream_finished, do: Queue.done

  def ensure_writeable_destination!(index_name) do
    File.mkdir_p!(index_name)
  end

  def completed? do
    if FileList.done?, do: true, else: completed?
  end
end
