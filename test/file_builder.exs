defmodule Floorplan.FileBuilderTest do
  use ExUnit.Case

  alias Floorplan.FileBuilder

  test "build_node generates XML comforming to sitemap protocol" do
    valid_xml = """
    <url>
      <loc>https://www.househappy.org</loc>
      <lastmod>2004-12-23T18:00:15+00:00</lastmod>
      <changefreq>monthly</changefreq>
      <priority>0.8</priority>
    </url>
    """

    url_link = %Floorplan.Url{
      location: "",
      last_mod: "2004-12-23T18:00:15+00:00",
      change_freq: "monthly",
      priority: "0.8"
    }

    # remove whitespace
    generated_xml = String.replace(FileBuilder.build_node(url_link), ~r/\s/i, "")
    source_xml    = String.replace(valid_xml, ~r/\s/i, "")

    assert generated_xml == source_xml
  end
end
