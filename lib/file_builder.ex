require Logger

defmodule Floorplan.FileBuilder do
  @docmodule """
  Takes a list of UrlLink structs and writes to file
  """

  alias Floorplan.Utilities

  defmodule Context do
    defstruct target_directory: "tmp",
              urls_per_file: 50_000,
              base_url: "http://www.example.com",
              sitemap_files: [], # Set by Generator
              urls: [
                %Floorplan.Url{location: "/foo/bar.html"}
              ]
  end

  defmodule SitemapFile do
    defstruct index: 0,
              url_count: 0,
              path: nil
  end

  def generate do
    generate(%Context{})
  end

  def generate(context) when is_map(context) do
    Utilities.ensure_writeable_destination!(context.target_directory)
    sitemap_files = write_sitemap_files(context)
    %Context{context | sitemap_files: sitemap_files}
  end

  def write_sitemap_files(context) do
    chunks = Stream.chunk(context.urls, context.urls_per_file, context.urls_per_file, [])
    Logger.info "Reading from datasources..."
    chunks |> Stream.with_index |> Enum.map(fn({file_urls, index}) ->
      write_file(context, index, file_urls)
    end)
  end

  def write_file(context, file_index, file_urls) do
    basename = Utilities.sitemap_file_basename(file_index)
    path = Path.join(context.target_directory, basename)

    Logger.info "Writing file #{path}"

    stream = sitemap_file_xml_stream(context.base_url, file_urls)
    Utilities.write_compressed(path, stream)

    url_count = Enum.count(file_urls)
    Logger.info "✓ #{basename}  -- #{url_count} urls"

    %SitemapFile{index: file_index, path: path, url_count: url_count}
  end

  def sitemap_file_xml_stream(base_url, file_urls) do
    urls_xml_stream = file_urls
      |> Stream.map(&(build_node(base_url, &1)))

    [
      [xml_header],
      urls_xml_stream,
      [xml_footer]
    ] |> Stream.concat
  end

  def build_node(base_url, url_link) do
    loc = base_url <> to_string(url_link.location)
    node = [{:loc,        nil, loc},
            {:lastmod,    nil, url_link.last_mod},
            {:changefreq, nil, url_link.change_freq},
            {:priority,   nil, url_link.priority}]
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
