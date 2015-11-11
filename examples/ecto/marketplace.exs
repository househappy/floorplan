## Example for Ecto-based Marketplace data source

defmodule MarketplaceSource do
  import Floorplan.Adapters.Ecto.Search

  @change_freq "weekly"
  @priority "0.7"

  schema "marketplaces" do
    field :metro_area_name, String
    field :status,          String
  end

  def all do
    query = from m in __MODULE__,
      where: m.status = "active",
      select: m

    Repo.all(query)
  end

  def build_uri(marketplace) do
    Floorplan.Utilities.build_uri [
      "marketplaces",
      marketplace.metro_area_name
    ]
  end
end

defmodule SitemapGenerator do
  def generate do
    Floorplan.generate("tmp/sitemap.xml", MarketplaceSource.all_as_urls)
  end
end
