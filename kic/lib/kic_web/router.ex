defmodule KicWeb.Router do
  use KicWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", KicWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/sign_up", SignUpController, :index
    post "/sign_up", SignUpController, :create
  end

  # Other scopes may use custom stacks.
  # scope "/api", KicWeb do
  #   pipe_through :api
  # end
end
