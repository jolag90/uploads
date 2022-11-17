defmodule Upload17Web.Router do
  use Upload17Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {Upload17Web.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Upload17Web do
    pipe_through :browser

    get "/", PageController, :home

    live "/people", UserLive.Index, :index
    live "/people/new", UserLive.Index, :new
    live "/people/:id/edit", UserLive.Index, :edit

    live "/people/:id", UserLive.Show, :show
    live "/people/:id/show/edit", UserLive.Index, :edit
  end

  # Other scopes may use custom stacks.
  # scope "/api", Upload17Web do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:upload17, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: Upload17Web.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
