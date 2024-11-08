defmodule Servy.Plugins do
  require Logger
  alias Servy.Conv, as: Conv

  def track(%Conv{status: 404, path: path} = conv) do
    Logger.warn("Path #{path} Not Found")
    conv
  end

  def track(%Conv{} = conv) do
    conv
  end

  def log(%Conv{} = conv) do
    IO.inspect(conv)
    conv
  end

  def rewrite_path(%Conv{path: path} = conv) do
    regex = ~r{\/(?<thing>\w+)\?id=(?<id>\d+)}
    captures = Regex.named_captures(regex, path)
    rewrite_path_captures(conv, captures)
  end

  def rewrite_path_captures(%Conv{} = conv, %{"thing" => thing, "id" => id}) do
    %{conv | path: "/#{thing}/#{id}"}
  end

  def rewrite_path_captures(%Conv{} = conv, nil), do: conv
end
