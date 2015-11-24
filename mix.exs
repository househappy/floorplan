defmodule Floorplan.Mixfile do
  use Mix.Project

  def project do
    [app: :floorplan,
     version: "0.0.1",
     elixir: "~> 1.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description,
     package: package,
     deps: deps]
  end

  def description do
    "A module for generating sitemaps from a variety of data sources"
  end

  def package do
    [
      maintainers: ["Lucas Charles"],
      licenses: ["BSD Revised"],
      links: %{"GitHub" => "https://github.com/househappy/floorplan"}
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [mod: {Floorplan.App, []},
     applications: [
      :logger,
      :tzdata,
      :httpotion,
      :poison]]
  end

  defp deps do
    [{:httpotion, "~> 2.1.0"},
     {:ibrowse, github: "cmullaparthi/ibrowse", tag: "v4.1.2"},
     {:poison, "~> 1.5"},
     {:postgrex, ">= 0.0.0"},
     {:timex, "~> 0.19.2"},
     # see https://github.com/bitwalker/timex/issues/86
     {:tzdata, "== 0.1.8", override: true},
     {:xml_builder, "~> 0.0.6"}]
  end
end
