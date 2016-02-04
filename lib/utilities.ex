defmodule Floorplan.Utilities do
  @moduledoc """
  Assorted helper functions
  """

  use Timex

  @doc """
  Helper for returning current time as a string
  """
  def current_time do
    elem(Date.local |> DateFormat.format("{ISOz}"), 1)
  end

  @doc """
  Generate a url-friendly string from component strings

  ## Examples

    iex> Floorplan.Utilities.build_uri ["FOO", "bar@ 42"]
    "/foo/bar-42"
  """
  def build_uri(components) do
    ["/" | components]
      |> Enum.filter(&present?/1)
      |> Enum.map(&parameterize/1)
      |> Enum.join("/")
  end

  @doc """
  Takes a string and returns a url-safe parameterized string

  ## Examples

    iex> Floorplan.Utilities.parameterize("A_bIg-@-ole'$%$Safe-string-**-")
    "a_big-ole-safe-string"
  """
  def parameterize(input_str, sep \\ "-") do
    safe_sep = Regex.escape(sep)
    input_str
      # remove non-normalized characters
      |> String.replace(~r/[^A-Za-z0-9\-_]/, sep)
      # ensure no more than 1 separator in a row
      |> String.replace(~r/#{safe_sep}{2,}/, sep)
      # remove trailing/leading sep
      |> String.replace(~r/\A#{safe_sep}|#{safe_sep}\z/, "")
      |> String.downcase
  end

  @doc """
  Returns true unless input is whitespace-string, empty-string, or nil

  ## Examples

    iex> Floorplan.Utilities.present?(" ")
    false
    iex> Floorplan.Utilities.present?(" a ")
    true
    iex> Floorplan.Utilities.present?("  ")
    false
    iex> Floorplan.Utilities.present?(nil)
    false
  """
  def present?(input_str) do
    if is_nil(input_str) do
      false
    else
      !Regex.match?(~r/\A\s*\z/, input_str)
    end
  end

  def ensure_writeable_destination!(target_directory) do
    File.mkdir_p!(target_directory)
  end

  def write_compressed(path, stream) do
    File.open!(path, [:write, :compressed], fn(file) ->
      stream |> Enum.each(&(IO.binwrite(file, &1)))
    end)
  end

  def sitemap_file_basename(file_index) do
    "sitemap#{file_index + 1}.xml.gz"
  end
end
