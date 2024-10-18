defmodule Servy.Handler do
  @moduledoc """
  Servy.Handler is responsible for handling incoming requests and routing them to the appropriate handler.
  """

  import Servy.Plugins, only: [rewrite_path: 1, track: 1]
  import Servy.Parser, only: [parse: 1]
  import Servy.FileHandler, only: [get_file: 2]
  alias Servy.Conv, as: Conv
  alias Servy.BearController
  alias Servy.Api.BearController, as: ApiBearController

  @doc """
  Handle the incoming request by parsing it, rewriting the path, routing it, logging it, tracking it, emojifying it, and formatting the response.
  """
  def handle(request) do
    request
    |> parse
    |> rewrite_path
    |> route
    # |> log
    |> track
    # |> emojify
    |> put_content_length
    |> format_response
  end

  def emojify(%Conv{resp_body: body, status: 200} = conv) do
    body = "🎉 " <> body <> " 🎉"
    %{conv | resp_body: body}
  end

  def emojify(%Conv{} = conv) do
    conv
  end

  def route(%Conv{method: "GET", path: "/sensors"} = conv) do
    task = Task.async(fn -> Servy.Tracker.get_location("bigfoot") end)

    snapshots =
      ["cam1", "cam2", "cam3"]
      |> Enum.map(&Task.async(fn -> Servy.VideoCam.get_snapshot(&1) end))
      |> Enum.map(&Task.await/1)

    where_is_bigfoot = Task.await(task)

    %{conv | status: 200, resp_body: inspect({snapshots, where_is_bigfoot})}
  end

  def route(%Conv{method: "GET", path: "/hibernate/" <> time} = conv) do
    time |> String.to_integer() |> :timer.sleep()

    %{conv | status: 200, resp_body: "Awake!"}
  end

  def route(%Conv{method: "GET", path: "/kaboom"} = _conv) do
    raise "Kaboom!"
  end

  def route(%Conv{method: "GET", path: "/about"} = conv) do
    get_file("about.html", conv)
  end

  def route(%Conv{method: "GET", path: "/wildthings"} = conv) do
    %{conv | status: 200, resp_body: "Bears, Lions, Tigers"}
  end

  def route(%Conv{method: "GET", path: "/bears"} = conv) do
    BearController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/api/bears"} = conv) do
    ApiBearController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/bears/new"} = conv) do
    get_file("form.html", conv)
  end

  def route(%Conv{method: "GET", path: "/pages/" <> file} = conv) do
    get_file(file <> ".html", conv)
  end

  def route(%Conv{method: "GET", path: "/bears/" <> id} = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.show(conv, params)
  end

  def route(%{method: "DELETE", path: "/bears/" <> _id} = conv) do
    BearController.delete(conv, conv.params)
  end

  def route(%Conv{method: "POST", path: "/bears"} = conv) do
    BearController.create(conv, conv.params)
  end

  def route(%Conv{path: path} = conv) do
    %{conv | status: 404, resp_body: "No #{path} here"}
  end

  def format_response(%Conv{path: _path} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}
    Content-Type: #{conv.resp_headers["Content-Type"]}
    Content-Length: #{String.length(conv.resp_body)}

    #{conv.resp_body}
    """
  end

  def put_content_length(conv) do
    headers = Map.put(conv.resp_headers, "Content-Length", String.length(conv.resp_body))
    %{conv | resp_headers: headers}
  end
end
