defmodule Floorplan.FileBuilder do
  @docmodule """
  Takes a list of UrlLink structs and writes to file
  """

  alias Floorplan.FileCounter
  alias Floorplan.FileList
  alias Floorplan.Utilities

  def build(url_links, is_last \\ false) do
    count = FileCounter.increment
    filename = if Mix.env == :test do
      "tmp/test_sitemap#{count}.xml"
    else
      "tmp/sitemap#{count}.xml"
    end

    case write_urlset_to_file(filename, url_links) do
      {:ok, :ok} ->
        {:ok, compressed_filename} = Utilities.compress(filename)
        FileList.push({compressed_filename, :completed})
      true ->
        FileList.push({filename, :failed})
    end

    if is_last do
      index_name = Agent.get(:index_filename, fn filename -> filename end)
      Floorplan.IndexBuilder.generate(index_name)
    end

    if compressed_filename do
      {:ok, compressed_filename}
    else
      {:error, filename}
    end
  end

  defp write_urlset_to_file(filename, url_links) do
    File.open(filename, [:write], fn file ->
      IO.binwrite file, xml_header

      Enum.map(url_links, fn url_link ->
        IO.binwrite file, build_node(url_link)
        IO.binwrite file, "\n"
      end)

      IO.binwrite file, xml_footer
    end)
  end

  def build_node(url_link) do
    loc = Floorplan.config.base_url <> to_string(url_link.location)
    node = [{:loc,       nil, loc},
            {:lastmod,   nil, url_link.last_mod},
            {:changefreq, nil, url_link.change_freq},
            {:priority,  nil, url_link.priority}]
    XmlBuilder.generate({:url, nil, node})
  end

  defp xml_header do
    """
    <?xml version="1.0" encoding="UTF-8"?>
    <urlset xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd" xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:image="http://www.google.com/schemas/sitemap-image/1.1" xmlns:video="http://www.google.com/schemas/sitemap-video/1.1" xmlns:geo="http://www.google.com/geo/schemas/sitemap/1.0" xmlns:news="http://www.google.com/schemas/sitemap-news/0.9" xmlns:mobile="http://www.google.com/schemas/sitemap-mobile/1.0" xmlns:pagemap="http://www.google.com/schemas/sitemap-pagemap/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml">
    """
  end

  defp xml_footer do
    """
    \n</urlset>
    """
  end
end
