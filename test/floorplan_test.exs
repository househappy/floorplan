defmodule FloorplanTest do
  use ExUnit.Case

  setup do
    Path.wildcard("tmp/test*.xml*") |> Enum.map(&File.rm/1)

    on_exit fn ->
      Path.wildcard("tmp/test*.xml*") |> Enum.map(&File.rm/1)
    end

    :ok
  end

  test "follows the happy path" do
    files = Path.wildcard("tmp/test_sitemap*.xml.gz")
    assert Dict.size(files) == 0

    data_sources = [
      %Floorplan.UrlLink{location: "/foo"},
      %Floorplan.UrlLink{location: "/bar"}
    ]

    Floorplan.generate("tmp/test_sitemap.xml", data_sources)

    files = Path.wildcard("tmp/test_sitemap*.xml.gz")
    assert Dict.size(files) == 2
  end
end
