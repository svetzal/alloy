defmodule AlloyWeb.Router do
  use AlloyWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {AlloyWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :api_authenticated do
    plug AlloyWeb.Plugs.ApiAuth
  end

  scope "/", AlloyWeb do
    pipe_through :browser

    get "/", PageController, :home

    live "/projects", ProjectLive.Index, :index
    live "/projects/new", ProjectLive.Form, :new
    live "/projects/:key", ProjectLive.Show, :show
    live "/projects/:key/edit", ProjectLive.Form, :edit

    live "/projects/:project_key/intents", IntentRecordLive.Index, :index
    live "/projects/:project_key/intents/new", IntentRecordLive.Form, :new
    live "/projects/:project_key/intents/:slug", IntentRecordLive.Show, :show
    live "/projects/:project_key/intents/:slug/edit", IntentRecordLive.Form, :edit
  end

  scope "/api/v1", AlloyWeb.Api do
    pipe_through [:api, :api_authenticated]

    # The bearer token identifies the project, so it is not in the path.
    get "/project", ProjectController, :show
    patch "/project", ProjectController, :update
    put "/project", ProjectController, :update

    get "/intents", IntentRecordController, :index
    post "/intents", IntentRecordController, :create
    get "/intents/:slug", IntentRecordController, :show
    patch "/intents/:slug", IntentRecordController, :update
    put "/intents/:slug", IntentRecordController, :update
    delete "/intents/:slug", IntentRecordController, :delete

    post "/intents/:slug/accept", IntentRecordController, :accept
    post "/intents/:slug/activate", IntentRecordController, :activate
    post "/intents/:slug/deprecate", IntentRecordController, :deprecate
    post "/intents/:slug/contradict", IntentRecordController, :contradict
    post "/intents/:slug/supersede", IntentRecordController, :supersede
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:alloy, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: AlloyWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
