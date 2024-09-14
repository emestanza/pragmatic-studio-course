defmodule Servy.BearController do
  alias Servy.Wildthings
  alias Servy.Bear

  defp bear_item(bear) do
    "<li>#{bear.name}</li>"
  end

  def index(conv) do
    bears = Wildthings.list_bears()

    resp_body =
      bears
      |> Enum.filter(&Bear.grizzly?(&1))
      |> Enum.sort(&Bear.order_by_name(&1, &2))
      |> Enum.map_join("\n", &bear_item(&1))

    %{conv | status: 200, resp_body: "<ul>#{resp_body}</ul>"}
  end

  def show(conv, %{"id" => id}) do
    %{conv | status: 200, resp_body: "Bear #{id}"}
  end

  def create(conv, %{"name" => name, "type" => type}) do
    %{conv | status: 201, resp_body: "Created #{type} bear named #{name}"}
  end

  def delete(conv, _params) do
    %{ conv | status: 403, resp_body: "Deleting a bear is forbidden!"}
  end
end
