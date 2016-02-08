defmodule Floorplan.Context do
  defstruct target_directory: "tmp",
            urls_per_file: 50_000,
            base_url: "", # http://www.example.com
            sitemap_files: [], # Set by Generator
            urls: [ # A Stream or Enum of Floorplan.Url structs
              %Floorplan.Url{} # location: "/foo/foo.html"
            ]
end
