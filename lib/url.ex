defmodule Floorplan.Url do
  @docmodule "Represents a single URL in a sitemap"

  @doc """
  Each key:

  `location`: The path part of the URL: e.g. "/foo/bar.html". The base part of the
              URL is specified in %Floorplan.Context{}
  `last_mod`: Last modification datetime, in DateFormat.format("{ISOz}") format
  `change_freq`: one of: ~w(daily weekly monthly yearly)
  `priority`: value from 0.0 (lowest) to 1.0 (highest)
  """

  defstruct location: "", # /foo/bar.html
            last_mod: Floorplan.Utilities.current_time,
            change_freq: "daily",
            priority: "0.5"
end
