defmodule MyAshBlog.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      MyAshBlogWeb.Telemetry,
      MyAshBlog.Repo,
      {DNSCluster, query: Application.get_env(:my_ash_blog, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: MyAshBlog.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: MyAshBlog.Finch},
      # Start a worker by calling: MyAshBlog.Worker.start_link(arg)
      # {MyAshBlog.Worker, arg},
      # Start to serve requests, typically the last entry
      MyAshBlogWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MyAshBlog.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MyAshBlogWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
