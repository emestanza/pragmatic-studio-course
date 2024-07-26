defmodule Servy.FileHandler do
  alias Servy.Conv, as: Conv
  @pages_path Path.expand("pages", __DIR__)

  def get_file(file_name, %Conv{} = conv) do
    @pages_path
    |> Path.join(file_name)
    |> File.read()
    |> handle_file(conv)
  end

  defp handle_file({:ok, content}, %Conv{} = conv) do
    %{conv | status: 200, resp_body: content}
  end

  defp handle_file({:error, :enoent}, %Conv{} = conv) do
    %{conv | status: 404, resp_body: "File Not Found"}
  end

  defp handle_file({:error, reason}, %Conv{} = conv) do
    %{conv | status: 500, resp_body: "File Error: #{reason}"}
  end
end
