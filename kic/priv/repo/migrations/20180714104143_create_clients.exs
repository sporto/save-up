defmodule Kic.Repo.Migrations.CreateClients do
  use Ecto.Migration

  def change do
    create table(:clients) do

      timestamps()
    end

  end
end
