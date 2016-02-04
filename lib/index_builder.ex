require Logger

defmodule Floorplan.IndexBuilder do
  @moduledoc false

  alias Floorplan.Utilities

  def generate_index_file(context) do
    generate_index_file(context, context.sitemap_files)
  end

  def generate_index_file(context, sitemap_files) do
    Logger.info "Generating sitemap index file"

    Utilities.ensure_writeable_destination!(context.target_directory)

    basename = "sitemap.xml.gz"
    file_path = Path.join(context.target_directory, basename)

    stream = index_file_xml_stream(context.base_url, sitemap_files)

    Utilities.write_compressed(file_path, stream)

    Logger.info "✓ #{basename}  -- #{Enum.count(sitemap_files)} sitemap files"

    :ok
  end

  def index_file_xml_stream(base_url, sitemap_files) do
    [
      [xml_header],
      Stream.map(sitemap_files, &(build_index_entry base_url, &1)),
      [xml_footer]
    ] |> Stream.concat
  end

  def build_index_entry(base_url, sitemap_file) do
    build_url_entry(base_url, "/" <> Utilities.sitemap_file_basename(sitemap_file.index))
  end

  def build_url_entry(base_url, location) do
    last_mod = Utilities.current_time |> String.split("T") |> List.first
    loc = base_url <> location
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
