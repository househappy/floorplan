defmodule Floorplan.Adapters.Elasticsearch.ScanScrollSearch do
  @docmodule """
  Adapter for building consumable streams from ElasticSearch collections

  See examples for usage

  ## caller must implement functions:
    - all()
    - build_uri()
    - @change_freq
    - @priority
  """

  defmacro __using__(opts) do
    quote do

      @es_host Application.get_env(:floorplan, :elasticsearch)[:host]
      def es_host, do: @es_host

      @doc """
      Produces a consumable Stream of Cities as UrlLink structs
      """
      def all_as_urls do
        Stream.map(all, fn hit ->
          %Floorplan.Url{
            location: build_uri(hit["_source"]),
            change_freq: @change_freq,
            priority: @priority
          }
        end)
      end

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
  end
end
