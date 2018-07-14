defmodule Kic.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string, null: false
      add :email, :string, null: false
      add :encrypted_password, :string, null: false
      add :timezone, :string, null: false
      add :client_id, references(:clients), null: false

      timestamps()
    end

  end
end
