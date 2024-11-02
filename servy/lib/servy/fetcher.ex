defmodule Servy.Fetcher do
  def async(func) do
    parent = self()
    spawn(fn -> send(parent, {self(), :result, func.()}) end)
  end

  def get_result(pid) do
    receive do
      {^pid, :result, filename} -> filename
    after
      2000 ->
        raise "Timed out!"
    end
  end
end
