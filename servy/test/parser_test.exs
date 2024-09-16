defmodule ParserTest do

  use ExUnit.Case
  alias Servy.Conv, as: Conv
  alias Servy.Parser

  test "parse" do
    request = "GET /bears HTTP/1.1\nHost: localhost:4000\n\n"
    conv = Parser.parse(request)
    assert conv.method == "GET"
    assert conv.path == "/bears"
    assert conv.headers == %{"Host" => "localhost:4000"}
    assert conv.params == %{}
  end

  test "parse_params" do
    params_string = "name=Baloo&type=Sloth"
    params = Parser.parse_params("application/x-www-form-urlencoded", params_string)
    assert params == %{"name" => "Baloo", "type" => "Sloth"}
  end

  test "parse_params with invalid content type" do
    params = Parser.parse_params("application/json", "")
    assert params == %{}
  end

  test "parse_headers" do
    header_lines = ["Host: localhost:4000", "Content-Type: application/x-www-form-urlencoded"]
    headers = Parser.parse_headers(header_lines, %{})
    assert headers == %{"Host" => "localhost:4000", "Content-Type" => "application/x-www-form-urlencoded"}
  end

  test "parse_headers with empty headers" do
    headers = Parser.parse_headers([], %{})
    assert headers == %{}
  end

end
