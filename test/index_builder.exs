defmodule Floorplan.IndexBuilderTest do
  use ExUnit.Case

  alias Floorplan.FileList
  alias Floorplan.IndexBuilder

  setup do
    Logger.remove_backend(:console)

    Path.wildcard("tmp/test*.xml*") |> Enum.map(&File.rm/1)

    on_exit fn ->
      Path.wildcard("tmp/test*.xml*") |> Enum.map(&File.rm/1)
    end

    :ok
  end

  test "follows the happy path" do
    files = Path.wildcard("tmp/test_sitemap.xml.gz")
    assert Dict.size(files) == 0

    FileList.push({"herp1.xml.gz", :completed})
    FileList.push({"herp2.xml.gz", :completed})
    IndexBuilder.generate("tmp/test_sitemap.xml")

    files = Path.wildcard("tmp/test_sitemap.xml.gz")
    assert Dict.size(files) == 1

    file_contents = :zlib.gunzip(File.read!(files |> List.first))
    body_has_two_sitemaps = String.match?(file_contents, ~r/\<sitemap\>.*\<sitemap\>/s)
    assert body_has_two_sitemaps
  end

  test "builds url_entries with properly formatted lastmod date" do
    xml = Floorplan.IndexBuilder.build_url_entry("https://www.househappy.org/sitemap1.xml.gz")
    lastmod_date = Regex.run(~r/\<lastmod\>(.*)\<\/lastmod\>/s, xml) |> Enum.at(1)
    assert String.match?(lastmod_date, ~r/\d{4}\-\d{2}\-\d{2}/)
  end
end
