defmodule FloorplanTest do
  use ExUnit.Case

  setup do
    Logger.remove_backend(:console)

    Path.wildcard("tmp/test_sitemaps/*.xml*") |> Enum.map(&File.rm/1)

    on_exit fn ->
      Path.wildcard("tmp/test_sitemaps/*.xml*") |> Enum.map(&File.rm/1)
    end

    :ok
  end

  test "follows the happy path" do
    files = Path.wildcard("tmp/test_sitemaps/*.xml.gz")
    assert Dict.size(files) == 0

    data_sources = [
      %Floorplan.Url{location: "/foo"},
      %Floorplan.Url{location: "/bar"}
    ]

    Floorplan.generate("tmp/test_sitemaps", "http://example.com", data_sources)

    files = Path.wildcard("tmp/test_sitemaps/*.xml.gz")
    assert Dict.size(files) == 2
  end
end
