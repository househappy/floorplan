require Logger

defmodule Floorplan.IndexBuilder do
  @moduledoc """

  ## Examples

    iex> Floorplan.IndexBuilder.generate
    {:ok, "tmp/sitemap.xml.gz"}
  """

  alias Floorplan.FileList
  alias Floorplan.Utilities

  def generate(filename) do
    completed_urlsets = FileList.fetch(:completed)
    urlset_count      = Dict.size(completed_urlsets)

    case write_urlsets_to_file(filename, completed_urlsets) do
      {:ok, :ok} ->
        {:ok, compressed_filename} = Utilities.compress(filename)

        Logger.info "✓ #{compressed_filename}  -- #{urlset_count} urls"
        FileList.push({compressed_filename, :completed, urlset_count})
      _ ->
        Logger.error "✕ index failed to generate: #{filename} -- #{urlset_count} urls"
        FileList.push({filename, :failed, urlset_count})
    end
  end

  def write_urlsets_to_file(filename, urlsets) do
    File.open(filename, [:write], fn file ->
      IO.binwrite file, xml_header

      Enum.map(urlsets, fn {filename, _status, _url_count} ->
        basename = Path.basename(filename)
        IO.binwrite file, build_url_entry("/" <> basename)
        IO.binwrite file, "\n"
      end)

      IO.binwrite file, xml_footer
    end)
  end

  def build_url_entry(location) do
    last_mod = Utilities.current_time |> String.split("T") |> List.first
    loc = Floorplan.config.base_url <> location
    node = [{:loc,       nil, loc},
            {:lastmod,   nil, last_mod}]
    XmlBuilder.generate({:sitemap, nil, node})
  end

  def xml_header do
    """
    <?xml version="1.0" encoding="UTF-8"?>
    <sitemapindex xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/siteindex.xsd" xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
    """
  end

  def xml_footer do
    """
    \n</sitemapindex>
    """
  end
end
