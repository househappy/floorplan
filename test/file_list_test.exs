defmodule Floorplan.FileListTest do
  use ExUnit.Case, async: false

  alias Floorplan.FileList

  def completed_file, do: {"tmp/derp1.xml", :completed}
  def failed_file,    do: {"tmp/derp2.xml", :failed}

  setup do
    FileList.replace_queue([])
    :ok
  end

  test "push() appends to queue" do
    # file_list is initially empty
    file_list = FileList.fetch(:all)
    assert Dict.size(file_list) == 0

    # file_list can receive items
    FileList.push(completed_file)

    # file_list contains received items
    file_list = FileList.fetch(:all)
    assert List.first(file_list) === completed_file
  end

  test "fetch() retrieves all files by status :all" do
    [completed_file, failed_file] |> Enum.map(&FileList.push/1)

    file_list = FileList.fetch(:all)
    assert Dict.size(file_list) == 2
  end

  test "fetch() retrieves complete files by status :completed" do
    [completed_file, failed_file] |> Enum.map(&FileList.push/1)

    file_list = FileList.fetch(:completed)
    assert Dict.size(file_list) == 1
  end
end
