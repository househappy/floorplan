require Logger

defmodule Floorplan do
  @moduledoc """
  Primary interface for generating a sitemap
  """

  @doc """
  takes the target location for the sitemap index and a collection of
  `urls`. `urls` can be either a stream or enum.

  ## Examples
    iex> urls = [ %Floorplan.UrlLink{} ]
    ...>Floorplan.generate("/tmp", "http://example.com", urls)
      Generated sitemap to destination: '/tmp'
      ✓ tmp/sitemap.xml.gz  -- 1 urls
      ✓ tmp/sitemap1.xml.gz  -- 1 urls
      Elapsed time: 10.533 milliseconds
    {:ok, [{"/tmp/sitemap.xml.gz", :completed}, {"/tmp/sitemap1.xml.gz", :completed}]}
  """
  def generate(target_directory, base_url, urls) do
    context = %Floorplan.SitemapFilesBuilder.Context{
      target_directory: target_directory,
      base_url: base_url,
      urls: urls
    }
    generate(context)
  end

  def generate(context) do
    Logger.info "Generating sitemap in destination: '#{context.target_directory}'"

    start_time = Timex.Time.now

    context = Floorplan.SitemapFilesBuilder.generate(context)
    :ok = Floorplan.IndexBuilder.generate_index_file(context)

    execution_time = Timex.Time.diff(Timex.Time.now, start_time) |> Timex.Format.Time.Formatter.format(:humanized)
    Logger.info "Elapsed time: #{execution_time}"

    {:ok, context}
  end
end
