# Floorplan
[![Hex.pm Version](http://img.shields.io/hexpm/v/floorplan.svg?style=flat)](https://hex.pm/packages/floorplan)

Floorplan is a library for generating sitemaps.  It takes a index name and a stream of URLs to produce your site's sitemap.

It currently has built-in adapters for [ecto](https://github.com/elixir-lang/ecto) or [elasticsearch](https://www.elastic.co/) data sources.  See [Examples](https://github.com/househappy/floorplan/tree/master/examples) for usage.

## Installation

If [available in Hex](https://hex.pm/packages/floorplan), the package can be installed as:

  1. Add floorplan to your list of dependencies in `mix.exs`:

        def deps do
          [{:floorplan, "~> 0.1.0"}]
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

Example 1: From iex

  iex(1)> urls = [%Floorplan.Url{location: "/foo.html", change_freq: "weekly", priority: "0.9"}]
  [%Floorplan.Url{change_freq: "weekly", last_mod: "2016-02-08T21:21:01.609Z",
    location: "/foo.html", priority: "0.9"}]
  iex(2)> context = %Floorplan.Context{urls: urls, base_url: "http://example.com", target_directory: "tmp/sitemaps"}
  %Floorplan.Context{base_url: "http://example.com", sitemap_files: [],
   target_directory: "tmp/sitemaps",
   urls: [%Floorplan.Url{change_freq: "weekly",
     last_mod: "2016-02-08T21:21:01.609Z", location: "/foo.html",
     priority: "0.9"}], urls_per_file: 50000}
  iex(3)> Floorplan.generate(context)

  13:30:50.117 [info]  Generating sitemap in destination: 'tmp/sitemaps'

  13:30:50.118 [info]  Reading from datasources...

  13:30:50.118 [info]  Writing file tmp/sitemaps/sitemap1.xml.gz

  13:30:50.119 [info]  ✓ sitemap1.xml.gz  -- 1 urls

  13:30:50.119 [info]  Generating sitemap index file

  13:30:50.120 [info]  ✓ sitemap.xml.gz  -- 1 sitemap files
  {:ok,
   %Floorplan.Context{base_url: "http://example.com",
    sitemap_files: [%Floorplan.SitemapFilesBuilder.SitemapFile{index: 0,
      path: "tmp/sitemaps/sitemap1.xml.gz", url_count: 1}],
    target_directory: "tmp/sitemaps",
    urls: [%Floorplan.Url{change_freq: "weekly",
      last_mod: "2016-02-08T21:21:01.609Z", location: "/foo.html",
      priority: "0.9"}], urls_per_file: 50000}}


Example 2: Integrated with application

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

    iex> context = %Floorplan.Context{

    }
    iex> MySitemapGenerator.generate(%{"tmp/sitemap.xml"})

See [Examples](https://github.com/househappy/floorplan/tree/master/examples) for more usage.


## Contributions

Code is licensed under [BSD License](https://github.com/househappy/floorplan/tree/master/LICENSE.md).

PRs/Issues welcome!
