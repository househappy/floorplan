## Example for Elasticsearch-based BlogPost data source

defmodule BlogPostSource do
  import Floorplan.Adapters.Elasticsearch.ScanScrollSearch

  @doc """
  Produces a consumable Stream of BlogPosts
  """
  def all do
    Stream.resource(
      fn -> start(start_scroll_url, scroll_start_dsl) end,
      &scroll_fetch/1,
      fn _ -> end)
  end

  @doc "Defines the index and type to be queried against"
  def start_scroll_url do
    "/my_index/BlogPost/_search?scroll=1m&search_type=scan"
  end

  @doc "Defines the query body DSL"
  def scroll_start_dsl do
    "{ \"query\" : { \"match_all\" : {} }"
  end

  # ex) "/blogposts/my-blog-post-title"
  def build_uri(blogpost) do
    Floorplan.Utilities.build_uri [
      "blogposts",
      blogpost["title"]
    ]
  end
end

defmodule SitemapGenerator do
  def generate do
    Floorplan.generate("tmp/sitemap.xml", BlogPostSource.all_as_urls)
  end
end

