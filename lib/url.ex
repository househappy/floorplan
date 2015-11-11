defmodule Floorplan.Url do
  defstruct location: nil,
            last_mod: Floorplan.Utilities.current_time,
            change_freq: "daily",
            priority: "0.5"
end
