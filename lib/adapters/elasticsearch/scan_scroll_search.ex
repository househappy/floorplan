defmodule Floorplan.Adapters.Elasticsearch.ScanScrollSearch do
  @docmodule ~s|
  Adapter for building consumable streams from ElasticSearch collections

  ## Example usage for an ES-based data source

    defmodule City do
      import Floorplan.Adapters.Elasticsearch.ScanScrollSearch

      @doc """
      Produces a consumable Stream of Cities
      """
      def all_as_urls do
        Stream.map(all, fn hit ->
          build_url_link(hit["_source"])
        end)
      end

      def all do
        Stream.resource(
          fn -> start(start_scroll_url, scroll_start_dsl) end,
          &scroll_fetch/1,
          fn _ -> end)
      end

      @doc "Defines the index and type to be queried against"
      def start_scroll_url do
        "/my_index/City/_search?scroll=1m&search_type=scan"
      end

      @doc "Defines the query body DSL"
      def scroll_start_dsl do
        "{ \"query\" : { \"match_all\" : {} }"
      end

      def build_url_link(city) do
        %Floorplan.UrlLink{
          location: city["base_url"],
          change_freq: "weekly",
          priority: "0.7"
        }
      end
  end|

  @es_host Application.get_env(:floorplan, :elasticsearch)[:host]
  def es_host, do: @es_host

  def start(start_scroll_url, query) do
    scroll_start_response = HTTPotion.post(es_host <> start_scroll_url, [body: query])
    {nil, Poison.decode!(scroll_start_response.body)["_scroll_id"]}
  end

  def scroll_fetch({nil, nil}), do: {:halt, nil}
  def scroll_fetch({nil, scroll_id}) do
    fetch_results(scroll_id)
    |> scroll_fetch
  end
  def scroll_fetch({results, scroll_id}) do
    {results, {nil, scroll_id}}
  end

  def fetch_results(scroll_id) do
    search_url = search_url(scroll_id)

    response = HTTPotion.get(search_url)
    search_json = Poison.decode!(response.body)
    hits = search_json["hits"]["hits"]

    if Enum.empty?(hits) do
      {nil, nil}
    else
      {hits, search_json["_scroll_id"]}
    end
  end

  def search_url(scroll_id) do
    # counter for testing/debugging
    scroll_count = Floorplan.ScrollCounter.increment
    es_host <> "/_search/scroll?scroll=5m&scroll_id=#{scroll_id}&hh_scroll_count=#{scroll_count}"
  end
end
