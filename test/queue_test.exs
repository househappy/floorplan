defmodule Floorplan.QueueTest do
  use ExUnit.Case, async: false

  alias Floorplan.Queue

  setup do
    Queue.replace_queue([])

    # TODO: mock something so this isn't necessary
    on_exit fn ->
      Path.wildcard("tmp/test*.xml") |> Enum.map(&File.rm/1)
    end

    :ok
  end

  test "push() appends to queue" do
    url_link = %Floorplan.UrlLink{}

    # queue is initially empty
    queue = Queue.fetch
    assert Dict.size(queue) == 0

    # queue can receive items
    Queue.push(url_link)

    # queue contains received items
    queue = Queue.fetch
    assert List.first(queue) === url_link
  end

  test "push() triggers call to FileBuilder if queue over 49_900" do
    maxed_out_queue = Enum.to_list(1..49_900)
    Queue.handle_cast({:push, %Floorplan.UrlLink{}, self}, maxed_out_queue)
    assert_receive {:build_file_start, _task}, 1000
  end

  test "done() empties queue" do
    Agent.start_link(fn -> "tmp/test_sitemap.xml" end, name: :index_filename)

    # populate queue
    Queue.push(%Floorplan.UrlLink{})
    queue = Queue.fetch
    assert Dict.size(queue) > 0

    # empty queue
    Queue.done

    # ensure empty
    queue = Queue.fetch
    assert Dict.size(queue) == 0
  end
end
