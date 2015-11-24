# Floorplan

Floorplan is a library for generating sitemaps.  It takes a index name and a collection of data sources to produce your site's sitemap.

It currently has built-in adapters for [ecto](https://github.com/elixir-lang/ecto) or [elasticsearch](https://www.elastic.co/) data sources.  See [Examples](https://github.com/househappy/floorplan/tree/master/examples) for usage.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add floorplan to your list of dependencies in `mix.exs`:

        def deps do
          [{:floorplan, "~> 0.0.1"}]
        end

  2. Ensure floorplan is started before your application:

        def application do
          [applications: [:floorplan]]
        end

  3. Define `base_url` within your applications config:

        ## within config.ex
        config :floorplan, base_url: "https://www.househappy.org"

  3b. Additional optional configuration:

        ## within config.ex
        config :floorplan, queue_size: 25_000
        config :floorplan, :elasticsearch, host: "http://localhost:9200"

## Usage

    defmodule MySitemapGenerator do
      def generate(index_name) do
        Floorplan.generate(index_name, data_sources)
      end

      def data_sources do
        [
          CoreLinks.all,
          ContentLinks.all
        ] |> Stream.concat
      end
    end

    iex> MySitemapGenerator.generate("tmp/sitemap.xml")

See [Examples](https://github.com/househappy/floorplan/tree/master/examples) for more usage.


## Contributions

Code is licensed under [BSD License](https://github.com/househappy/floorplan/tree/master/LICENSE.md).

PRs/Issues welcome!
