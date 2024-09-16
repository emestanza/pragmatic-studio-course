defmodule Servy.BearController do
  alias Servy.Wildthings
  alias Servy.Bear
  import Servy.BearView,  only: [render: 3]

  @templates_path Path.expand("templates", __DIR__)

  def index(conv) do
    bears =
      Wildthings.list_bears()
      |> Enum.sort(&Bear.order_by_name(&1, &2))

    render(conv, "index.eex", bears: bears)
  end

  def show(conv, %{"id" => id}) do
    bear = Wildthings.get_bear(id)

    render(conv, "show.eex", bear: bear)
  end

  def create(conv, %{"name" => name, "type" => type}) do
    %{conv | status: 201, resp_body: "Created #{type} bear named #{name}"}
  end

  def delete(conv, _params) do
    %{conv | status: 403, resp_body: "Deleting a bear is forbidden!"}
  end

end
