defmodule KicWeb.SignUpController do
  use KicWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def create(conn, params) do
    render conn, "create.html"
  end
end