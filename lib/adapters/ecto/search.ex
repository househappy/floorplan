defmodule Floorplan.Adapters.Ecto.Search do
  @docmodule """
  Adapter for building consumable streams from Ecto collections


  ## caller must implement functions:
    - all()
    - build_uri()
    - @change_freq
    - @priority
  """

  defmacro __using__(_opts) do
    quote do
      use Ecto.Model
      import Ecto.Query, only: [from: 2]

      @change_freq "weekly"
      @priority "0.5"

      def all_as_urls do
        Enum.map(all, fn item ->
          %Floorplan.Url{
            location: build_uri(item),
            change_freq: @change_freq,
            priority: @priority
          }
        end)
      end
    end
  end
end
