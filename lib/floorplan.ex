require Logger

defmodule Floorplan do
  @moduledoc """
  Primary interface for generating a sitemap
  """

  @doc """
  takes the target location for the sitemap index and a collection of
  `urls`. `urls` can be either a stream or enum.

  ## Examples

    iex(1)> Floorplan.generate("tmp", "http://example.com", [%{location: "/foo.html"}])

    11:38:01.527 [info]  Generating sitemap in destination: 'tmp'

    11:38:01.530 [info]  Reading from datasources...

    11:38:01.531 [info]  Writing file tmp/sitemap1.xml.gz

    11:38:01.534 [info]  ✓ sitemap1.xml.gz  -- 1 urls

    11:38:01.535 [info]  Generating sitemap index file

    11:38:01.675 [info]  ✓ sitemap.xml.gz  -- 1 sitemap files

    11:38:01.680 [info]  Elapsed time: 146.374 milliseconds
    {:ok,
     %Floorplan.Context{base_url: "http://example.com",
      sitemap_files: [%Floorplan.SitemapFilesBuilder.SitemapFile{index: 0,
        path: "tmp/sitemap1.xml.gz", url_count: 1}], target_directory: "tmp",
      urls: [%{location: "/foo.html"}], urls_per_file: 50000}}
  """
  def generate(target_directory, base_url, urls) do
    context = %Floorplan.Context{
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
