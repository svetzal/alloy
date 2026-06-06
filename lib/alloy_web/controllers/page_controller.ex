defmodule AlloyWeb.PageController do
  use AlloyWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
