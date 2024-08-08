compile_overrides = Application.get_env(:phoenix_playground, PhoenixPlayground.Endpoint)
Application.put_env(:phoenix_playground, PhoenixPlayground.Endpoint, Keyword.merge([debug_errors: true], compile_overrides))
salt = Application.get_env(:phoenix_playground, PhoenixPlayground.Endpoint)[:signing_salt] || "ll+Leuc4"

defmodule PhoenixPlayground.Endpoint do
  @moduledoc false

  use Phoenix.Endpoint, otp_app: :phoenix_playground

  @signing_salt salt

  @session_options [
    store: :cookie,
    key: "_phoenix_playground_key",
    signing_salt: @signing_salt,
    same_site: "Lax",
    # 14 days
    max_age: 14 * 24 * 60 * 60
  ]

  socket "/live", Phoenix.LiveView.Socket

  plug Plug.Static, from: {:phoenix, "priv/static"}, at: "/assets/phoenix"
  plug Plug.Static, from: {:phoenix_live_view, "priv/static"}, at: "/assets/phoenix_live_view"

  if Application.compile_env(:phoenix_playground, :live_reload) do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader, reloader: &PhoenixPlayground.CodeReloader.reload/2
  end

  # TODO:
  # plug Phoenix.Ecto.CheckRepoStatus, otp_app: :phoenix_playground

  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.Session, @session_options
  plug PhoenixPlayground.Router
end
