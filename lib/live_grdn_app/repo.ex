defmodule LiveGrdnApp.Repo do
  use Ecto.Repo,
    otp_app: :live_grdn_app,
    adapter: Ecto.Adapters.Postgres
end
